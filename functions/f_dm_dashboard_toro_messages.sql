
-- Память (GP/ADB runaway VMEM): один INSERT с цепочкой CTE + self-join b⋈b
-- раздувал group memory. Стадийная материализация узких temp-таблиц
-- (DISTRIBUTED BY), self-join только по узкой проекции, TM-префиксы заранее.
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_messages() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint;
BEGIN
    -- Раньше уходим в workfiles, чем копим VMEM группы сегментов
    BEGIN
        PERFORM set_config('statement_mem', '128MB', true);
        PERFORM set_config('gp_workfile_compression', 'on', true);
    EXCEPTION WHEN OTHERS THEN
        NULL; -- GUC может отсутствовать на части сборок
    END;

    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages;

    DROP TABLE IF EXISTS tmp_toro_msg_base;
    DROP TABLE IF EXISTS tmp_toro_msg_fl;
    DROP TABLE IF EXISTS tmp_toro_msg_a_d;
    DROP TABLE IF EXISTS tmp_toro_msg_t_d;
    DROP TABLE IF EXISTS tmp_toro_msg_cnt_d;
    DROP TABLE IF EXISTS tmp_toro_msg_names;
    DROP TABLE IF EXISTS tmp_toro_msg_ord;

    -- Справочник ТМ: один раз, без повторного скана view на 5 join'ах
    CREATE TEMP TABLE tmp_toro_msg_fl ON COMMIT DROP AS
    SELECT func_location, fl_name
    FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location
    DISTRIBUTED BY (func_location);
    ANALYZE tmp_toro_msg_fl;

    -- Узкие поля заказа (не тянем всю dm_dashboard_toro_orders)
    CREATE TEMP TABLE tmp_toro_msg_ord ON COMMIT DROP AS
    SELECT order_num, mvz_sum, work_fact_h
    FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders
    DISTRIBUTED BY (order_num);
    ANALYZE tmp_toro_msg_ord;

    ------------------------------------------------------------------
    -- 1) База: сообщения + заказ/вирт.ТМ/ОРМ + флаги + TM2..TM6 + тип исполнителя
    --    DISTRIBUTED BY (equipment) — локальный join для «Кол-во для D»
    ------------------------------------------------------------------
    CREATE TEMP TABLE tmp_toro_msg_base ON COMMIT DROP AS
    SELECT  m.equipment,
            m.notification,
            m.order_num,
            m.notif_type,
            m.req_start_date,
            m.req_end_date,
            m.user_status,
            m.sys_status,
            m.detection_code,
            m.failure_reason_code,
            m.work_plan_h,
            m.work_fact_h,
            m.work_fact_h_raw,
            m.do_code,
            m.created_date,
            m.description,
            m.func_location,
            m.toro_work_type,
            m.analysis_required,
            m.analysis_done,
            m.performer,
            m.equipment_part,
            m.failure_reason_name,
            m.failure_mode_text,
            m.failure_mechanism,
            m.failure_crit_code,
            m.failure_crit_name,
            m.failure_crit_sort,
            m.resp_workcenter,
            CASE WHEN date_trunc('month', m.created_date) > date_trunc('month', m.req_start_date)
                 THEN 0 ELSE 1 END                                      AS filter_by_create,
            CASE WHEN coalesce(m.sys_status  ILIKE ANY (ARRAY['%УДАЛ%','%МТКУ%']), false)
                   OR coalesce(m.user_status ILIKE ANY (ARRAY['%УДАЛ%']), false)
                 THEN 0 ELSE 1 END                                      AS filter_no_mtku,
            CASE WHEN coalesce(m.sys_status  ILIKE ANY (ARRAY['%МТКУ%']), false)
                   OR coalesce(m.user_status ILIKE ANY (ARRAY['%УДАЛ%','%НПДТ%']), false)
                 THEN 1 ELSE 0 END                                      AS flag_mtku_udal,
            CASE WHEN m.detection_code = 'NOVALUE' THEN 'Не указано'
                 ELSE CASE right(m.detection_code, 1)
                          WHEN 'D' THEN 'Дефектоскопист'   WHEN 'R' THEN 'Ремонт. персонал'
                          WHEN 'T' THEN 'Технол. персонал' WHEN 'A' THEN 'Случайное наблюдение' END
            END                                                         AS detection_method,
            CASE WHEN coalesce(m.user_status ILIKE ANY (ARRAY['%РОТМ%']), false)
                 THEN 1 ELSE 0 END                                      AS flag_otm,
            CASE WHEN coalesce(m.sys_status ILIKE ANY (ARRAY['%МТКУ%']), false)
                  AND m.created_date >= date '2025-01-01'
                 THEN 1 ELSE 0 END                                      AS filter_mtku_2025,
            CASE m.notif_type WHEN 'R1' THEN 'Плановая' WHEN 'R2' THEN 'Аварийная'
                              WHEN 'R3' THEN 'Внеплановая' END          AS work_kind,
            coalesce(w.workcenter_name, 'Не указан')                    AS resp_workcenter_name,
            o.order_num        AS ord_order_num,
            o.sys_status       AS ord_sys_status,
            o.fact_end_date    AS ord_fact_end_date,
            o.plan_end_date    AS ord_plan_end_date,
            o.plan_start_date  AS ord_plan_start_date,
            o.fact_start_date  AS ord_fact_start_date,
            o.fact_start_time  AS ord_fact_start_time,
            o.fact_end_time    AS ord_fact_end_time,
            o.entry_date       AS ord_entry_date,
            CASE WHEN v.func_location IS NOT NULL THEN 1 ELSE 0 END     AS is_virtual_fl,
            coalesce(m.sys_status  ILIKE ANY (ARRAY['%УДАЛ%','%МТКУ%']), false) AS c_a,
            coalesce(o.sys_status  ILIKE ANY (ARRAY['%НЕВЫ%','%МТКУ%']), false) AS c_b,
            coalesce(m.user_status ILIKE ANY (ARRAY['%УДАЛ%','%НЕВЫ%']), false) AS c_c,
            coalesce(m.user_status ILIKE ANY (ARRAY['%ПДТВ%']), false)          AS c_p,
            CASE WHEN m.func_location IS NOT NULL
                  AND (length(m.func_location) - length(replace(m.func_location, '-', ''))) >= 1
                 THEN array_to_string((string_to_array(m.func_location, '-'))[1:2], '-') END AS tm2,
            CASE WHEN m.func_location IS NOT NULL
                  AND (length(m.func_location) - length(replace(m.func_location, '-', ''))) >= 2
                 THEN array_to_string((string_to_array(m.func_location, '-'))[1:3], '-') END AS tm3,
            CASE WHEN m.func_location IS NOT NULL
                  AND (length(m.func_location) - length(replace(m.func_location, '-', ''))) >= 3
                 THEN array_to_string((string_to_array(m.func_location, '-'))[1:4], '-') END AS tm4,
            CASE WHEN m.func_location IS NOT NULL
                  AND (length(m.func_location) - length(replace(m.func_location, '-', ''))) >= 4
                 THEN array_to_string((string_to_array(m.func_location, '-'))[1:5], '-') END AS tm5,
            CASE WHEN m.func_location IS NOT NULL
                  AND (length(m.func_location) - length(replace(m.func_location, '-', ''))) >= 5
                 THEN array_to_string((string_to_array(m.func_location, '-'))[1:6], '-') END AS tm6,
            CASE WHEN     coalesce(m.performer ILIKE ANY (ARRAY['%RDB%']), false)
                      AND     coalesce(m.performer ILIKE ANY (ARRAY['%RDS%']), false) THEN 'Смешан'
                 WHEN     coalesce(m.performer ILIKE ANY (ARRAY['%RDB%']), false)
                      AND NOT coalesce(m.performer ILIKE ANY (ARRAY['%RDS%']), false) THEN 'RDB'
                 WHEN NOT coalesce(m.performer ILIKE ANY (ARRAY['%RDB%']), false)
                      AND     coalesce(m.performer ILIKE ANY (ARRAY['%RDS%']), false) THEN 'RDS'
                 ELSE 'Не указан' END AS performer_type,
            CASE WHEN m.performer IS NULL THEN 1
                 ELSE (length(m.performer) - length(replace(m.performer, ',', ''))) / NULLIF(length(','), 0) + 1
            END AS n_performers,
            CASE WHEN m.performer IS NULL THEN 0
                 ELSE (length(m.performer) - length(replace(m.performer, 'RDB', ''))) / NULLIF(length('RDB'), 0)
            END AS n_rdb,
            CASE WHEN m.performer IS NULL THEN 0
                 ELSE (length(m.performer) - length(replace(m.performer, 'RDS', ''))) / NULLIF(length('RDS'), 0)
            END AS n_rds
    FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages m
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders o
           ON o.order_num = m.order_num
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_virtual_fl v
           ON v.func_location = m.func_location
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_workcenter_map w
           ON w.map_key = coalesce(m.do_code,'') || coalesce(m.resp_workcenter,'')
    DISTRIBUTED BY (equipment);
    ANALYZE tmp_toro_msg_base;

    ------------------------------------------------------------------
    -- 2) «Кол-во для D»: self-join только узких проекций, colocated по equipment
    ------------------------------------------------------------------
    CREATE TEMP TABLE tmp_toro_msg_a_d ON COMMIT DROP AS
    SELECT equipment, notification, created_date
    FROM tmp_toro_msg_base
    WHERE coalesce(performer ILIKE ANY (ARRAY['%RDS%']), false)
      AND coalesce(failure_reason_code ILIKE ANY (ARRAY['%OP3%']), false)
      AND coalesce(notif_type ILIKE ANY (ARRAY['%R2%']), false)
    DISTRIBUTED BY (equipment);
    ANALYZE tmp_toro_msg_a_d;

    CREATE TEMP TABLE tmp_toro_msg_t_d ON COMMIT DROP AS
    SELECT equipment, notification, ord_fact_end_date
    FROM tmp_toro_msg_base
    WHERE ord_fact_end_date IS NOT NULL
    DISTRIBUTED BY (equipment);
    ANALYZE tmp_toro_msg_t_d;

    CREATE TEMP TABLE tmp_toro_msg_cnt_d ON COMMIT DROP AS
    SELECT a.equipment, a.notification, count(*)::bigint AS cnt_for_d
    FROM tmp_toro_msg_a_d a
    JOIN tmp_toro_msg_t_d t
      ON t.equipment = a.equipment
     AND t.notification <> a.notification
     AND t.ord_fact_end_date >= a.created_date - 14
     AND t.ord_fact_end_date <= a.created_date
    GROUP BY a.equipment, a.notification
    DISTRIBUTED BY (equipment, notification);
    ANALYZE tmp_toro_msg_cnt_d;

    DROP TABLE IF EXISTS tmp_toro_msg_a_d;
    DROP TABLE IF EXISTS tmp_toro_msg_t_d;

    ------------------------------------------------------------------
    -- 3) Имена исполнителей: unnest вместо regexp_split_to_table
    ------------------------------------------------------------------
    CREATE TEMP TABLE tmp_toro_msg_names ON COMMIT DROP AS
    SELECT do_code, notification,
           string_agg(nm, ', ' ORDER BY nm) AS performer_names
    FROM (
        SELECT x.do_code, x.notification,
               coalesce(w.workcenter_name, 'Не указан') AS nm
        FROM (
            SELECT b.do_code, b.notification,
                   btrim(code) AS code
            FROM tmp_toro_msg_base b,
                 unnest(string_to_array(coalesce(b.performer, ''), ',')) AS code
        ) x
        LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_workcenter_map w
               ON w.map_key = coalesce(x.do_code, '') || x.code
    ) y
    GROUP BY do_code, notification
    DISTRIBUTED BY (notification);
    ANALYZE tmp_toro_msg_names;

    ------------------------------------------------------------------
    -- 4) Финальная сборка КПЭ + справочники
    ------------------------------------------------------------------
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages
    SELECT
        coalesce(k.notification,'X')||coalesce(k.order_num,'X') AS key_ord_note,
        k.equipment, k.notification, k.order_num, k.notif_type, k.req_start_date, k.req_end_date,
        k.user_status, k.sys_status, k.detection_code, k.failure_reason_code, k.work_plan_h, k.work_fact_h,
        k.work_fact_h_raw, k.do_code, k.created_date, k.description, k.func_location, k.toro_work_type,
        k.analysis_required, k.analysis_done, k.performer, k.equipment_part, k.failure_reason_name,
        k.failure_mode_text, k.failure_mechanism, k.failure_crit_code, k.failure_crit_name, k.failure_crit_sort,
        k.resp_workcenter,
        k.filter_by_create, k.filter_no_mtku, k.flag_mtku_udal, k.detection_method, k.flag_otm,
        k.filter_mtku_2025, k.work_kind, k.resp_workcenter_name,
        k.ord_order_num, k.ord_sys_status, k.ord_fact_end_date, k.ord_plan_end_date, k.ord_plan_start_date,
        k.ord_fact_start_date, k.ord_fact_start_time, k.ord_fact_end_time, k.ord_entry_date, k.is_virtual_fl,
        k.kpi11, k.kpi10, k.kpi15_17, k.kpi15_17_overdue_name, k.kpi15_17_overdue_code, k.kpi15_17_no_mtku,
        k.kpi28, k.kpi_x_not_done, k.kpi14, k.kpi32_a, k.kpi32_b, k.kpi32_eadd, k.no_order, k.notif_type_dssp,
        CASE WHEN extract(year FROM k.req_end_date) =  extract(year FROM k.ord_fact_end_date) AND k.kpi_x_not_done = 0
             THEN 1 ELSE 0 END AS kpi11_in_time,
        CASE WHEN extract(year FROM k.req_end_date) <> extract(year FROM k.ord_fact_end_date) AND k.kpi_x_not_done = 0
             THEN 1 ELSE 0 END AS kpi11_overdue,
        CASE WHEN k.ord_fact_end_date <= k.ord_plan_end_date AND k.kpi_x_not_done = 0 THEN 1 ELSE 0 END AS kpi10_in_time,
        CASE WHEN k.ord_fact_end_date >  k.ord_plan_end_date AND k.kpi_x_not_done = 0 THEN 1 ELSE 0 END AS kpi10_overdue,
        CASE WHEN date_trunc('month', k.req_end_date) = date_trunc('month', k.ord_fact_end_date) AND k.kpi_x_not_done = 0
             THEN 1 ELSE 0 END AS kpi15_17_in_time,
        CASE WHEN date_trunc('month', k.req_end_date) <> date_trunc('month', k.ord_fact_end_date) AND k.kpi_x_not_done = 0
             THEN 1 ELSE 0 END AS kpi15_17_overdue,
        fr.reason_group,
        fr.reason_name,
        k.tm2, k.tm3, k.tm4, k.tm5, k.tm6,
        f2.fl_name AS tm2_name, f3.fl_name AS tm3_name, f4.fl_name AS tm4_name,
        f5.fl_name AS tm5_name, f6.fl_name AS tm6_name,
        CASE WHEN k.func_location IS NULL THEN NULL
             WHEN coalesce(k.tm3 ILIKE ANY (ARRAY['%DRT%','%DRB%']), false) THEN 1
             ELSE 0 END AS drt_drb,
        d.cnt_for_d,
        k.performer_type,
        CASE k.performer_type WHEN 'RDB'    THEN k.work_fact_h
                              WHEN 'Смешан' THEN k.work_fact_h * k.n_rdb / k.n_performers
                              ELSE 0 END AS work_fact_own_h,
        CASE k.performer_type WHEN 'RDS'    THEN k.work_fact_h
                              WHEN 'Смешан' THEN k.work_fact_h * k.n_rds / k.n_performers
                              ELSE 0 END AS work_fact_contr_h,
        CASE WHEN k.performer_type = 'Не указан' THEN k.work_fact_h ELSE 0 END AS work_fact_unknown_h,
        ord.mvz_sum,
        ord.work_fact_h AS order_work_fact_h,
        ord.mvz_sum * (CASE k.performer_type WHEN 'RDB' THEN k.work_fact_h
                          WHEN 'Смешан' THEN k.work_fact_h * k.n_rdb / k.n_performers
                          ELSE 0 END) / nullif(ord.work_fact_h, 0) AS cost_own,
        ord.mvz_sum * (CASE k.performer_type WHEN 'RDS' THEN k.work_fact_h
                          WHEN 'Смешан' THEN k.work_fact_h * k.n_rds / k.n_performers
                          ELSE 0 END) / nullif(ord.work_fact_h, 0) AS cost_contr,
        ord.mvz_sum * (CASE WHEN k.performer_type = 'Не указан' THEN k.work_fact_h ELSE 0 END)
                  / nullif(ord.work_fact_h, 0) AS cost_unknown,
        n.performer_names,
        CASE WHEN k.sys_status LIKE '%МТКУ%' THEN 1 ELSE 0 END AS sys_status_no_mtku,
        CASE WHEN k.user_status LIKE '%УДАЛ%' THEN 1 ELSE 0 END AS user_status_no_udal
    FROM (
        SELECT b.*,
            CASE WHEN b.filter_by_create = 1 THEN
                CASE WHEN b.c_a OR b.c_b OR b.c_c OR b.order_num IS NULL OR b.ord_fact_end_date IS NULL THEN 'Не выполнено'
                     WHEN extract(year FROM b.req_end_date) =  extract(year FROM b.ord_fact_end_date) THEN 'В срок'
                     WHEN extract(year FROM b.req_end_date) <> extract(year FROM b.ord_fact_end_date) THEN 'Просрочено'
                END
            END AS kpi11,
            CASE WHEN b.filter_by_create = 1 AND b.filter_no_mtku = 1 THEN
                CASE WHEN b.c_b OR b.order_num IS NULL OR b.ord_fact_end_date IS NULL THEN 'Не выполнено'
                     WHEN b.ord_fact_end_date <= b.ord_plan_end_date + 3
                      AND b.ord_fact_end_date >= b.ord_plan_end_date - 3 THEN 'В срок'
                     WHEN b.ord_fact_end_date >  b.ord_plan_end_date + 3
                       OR b.ord_fact_end_date <  b.ord_plan_end_date - 3 THEN 'Просрочено'
                END
            END AS kpi10,
            CASE WHEN b.filter_by_create = 1 THEN
                CASE WHEN b.c_a OR b.c_b OR b.c_c OR (b.ord_fact_end_date IS NULL AND NOT b.c_p) THEN 'Не выполнено'
                     WHEN date_trunc('month', b.req_end_date) = date_trunc('month', b.ord_fact_end_date) THEN 'В срок'
                     ELSE 'Просрочено'
                END
            END AS kpi15_17,
            CASE WHEN b.filter_by_create = 1 THEN
                CASE WHEN b.c_a OR b.c_b OR b.c_c OR (b.ord_fact_end_date IS NULL AND NOT b.c_p) THEN NULL
                     WHEN date_trunc('month', b.req_end_date) = date_trunc('month', b.ord_fact_end_date) THEN NULL
                     WHEN b.ord_fact_end_date <  date_trunc('month', b.req_end_date) + interval '2 month'
                      AND b.ord_fact_end_date >  date_trunc('month', b.req_end_date) - interval '1 month' THEN '1 месяц'
                     WHEN b.ord_fact_end_date <  date_trunc('month', b.req_end_date) + interval '3 month'
                      AND b.ord_fact_end_date >  date_trunc('month', b.req_end_date) - interval '2 month' THEN '2 месяца'
                     ELSE '3 и более'
                END
            END AS kpi15_17_overdue_name,
            CASE WHEN b.filter_by_create = 1 THEN
                CASE WHEN b.c_a OR b.c_b OR b.c_c OR (b.ord_fact_end_date IS NULL AND NOT b.c_p) THEN NULL
                     WHEN date_trunc('month', b.req_end_date) = date_trunc('month', b.ord_fact_end_date) THEN NULL
                     WHEN b.ord_fact_end_date <  date_trunc('month', b.req_end_date) + interval '2 month'
                      AND b.ord_fact_end_date >  date_trunc('month', b.req_end_date) - interval '1 month' THEN 1
                     WHEN b.ord_fact_end_date <  date_trunc('month', b.req_end_date) + interval '3 month'
                      AND b.ord_fact_end_date >  date_trunc('month', b.req_end_date) - interval '2 month' THEN 2
                     ELSE 3
                END
            END AS kpi15_17_overdue_code,
            CASE WHEN b.filter_by_create = 1 AND b.filter_no_mtku = 1 THEN
                CASE WHEN b.c_b OR b.c_c OR (b.ord_fact_end_date IS NULL AND NOT b.c_p) THEN 'Не выполнено'
                     WHEN date_trunc('month', b.req_end_date) = date_trunc('month', b.ord_fact_end_date) THEN 'В срок'
                     ELSE 'Просрочено'
                END
            END AS kpi15_17_no_mtku,
            CASE WHEN b.filter_no_mtku = 1 THEN
                CASE WHEN b.ord_entry_date - b.created_date > 5 THEN 1 ELSE 0 END
            ELSE 0 END AS kpi28,
            CASE WHEN b.filter_by_create = 1 THEN
                CASE WHEN b.c_a OR b.c_b OR b.c_c OR (b.ord_fact_end_date IS NULL AND NOT b.c_p) THEN 1 ELSE 0 END
            END AS kpi_x_not_done,
            CASE WHEN b.c_a OR b.c_b OR b.c_c OR b.ord_fact_end_date IS NULL THEN 0 ELSE 1 END AS kpi14,
            CASE WHEN b.c_a OR b.c_b OR b.c_c OR b.ord_fact_end_date IS NULL OR b.created_date > b.req_start_date
                 THEN 0 ELSE 1 END AS kpi32_a,
            CASE WHEN b.c_a OR b.c_b OR b.c_c OR b.created_date > b.req_start_date
                 THEN 0 ELSE 1 END AS kpi32_b,
            CASE WHEN extract(month FROM b.req_end_date) = extract(month FROM b.ord_fact_end_date)
                 THEN 1 ELSE 0 END AS kpi32_eadd,
            CASE WHEN b.ord_order_num IS NULL THEN 1 ELSE 0 END AS no_order,
            CASE WHEN coalesce(b.user_status ILIKE ANY (ARRAY['%ДССП%']), false)
                  AND extract(year FROM b.created_date) < extract(year FROM b.ord_fact_end_date)
                 THEN 'R1' ELSE b.notif_type END AS notif_type_dssp
        FROM tmp_toro_msg_base b
    ) k
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_failure_reason fr
           ON fr.reason_code = k.failure_reason_code
    LEFT JOIN tmp_toro_msg_fl f2 ON f2.func_location = k.tm2
    LEFT JOIN tmp_toro_msg_fl f3 ON f3.func_location = k.tm3
    LEFT JOIN tmp_toro_msg_fl f4 ON f4.func_location = k.tm4
    LEFT JOIN tmp_toro_msg_fl f5 ON f5.func_location = k.tm5
    LEFT JOIN tmp_toro_msg_fl f6 ON f6.func_location = k.tm6
    LEFT JOIN tmp_toro_msg_cnt_d d
           ON d.notification = k.notification AND d.equipment = k.equipment
    LEFT JOIN tmp_toro_msg_ord ord ON ord.order_num = k.order_num
    LEFT JOIN tmp_toro_msg_names n
           ON n.notification = k.notification
          AND coalesce(n.do_code, '') = coalesce(k.do_code, '');

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    DROP TABLE IF EXISTS tmp_toro_msg_base;
    DROP TABLE IF EXISTS tmp_toro_msg_fl;
    DROP TABLE IF EXISTS tmp_toro_msg_cnt_d;
    DROP TABLE IF EXISTS tmp_toro_msg_names;
    DROP TABLE IF EXISTS tmp_toro_msg_ord;

    ANALYZE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages;
    RETURN v_rows;
END;
$$;
