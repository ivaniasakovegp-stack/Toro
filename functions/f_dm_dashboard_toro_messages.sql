

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_messages() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint;
BEGIN
    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages
    WITH b AS (            -- 02.02 + Left Join заказов/вирт. ТМ (04.01.01)
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
               -- [Фильтр по дате создания]: 0, если сообщение создано в более позднем месяце, чем плановое начало
               CASE WHEN date_trunc('month', m.created_date) > date_trunc('month', m.req_start_date) THEN 0 ELSE 1 END
                                                                          AS filter_by_create,
               -- [Фильтр без МТКУ]
               CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(m.sys_status, ARRAY['%УДАЛ%','%МТКУ%'])
                      OR dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(m.user_status, ARRAY['%УДАЛ%']) THEN 0 ELSE 1 END
                                                                          AS filter_no_mtku,
               -- [Признак МТКУ/УДАЛ]
               CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(m.sys_status, ARRAY['%МТКУ%'])
                      OR dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(m.user_status, ARRAY['%УДАЛ%','%НПДТ%']) THEN 1 ELSE 0 END
                                                                          AS flag_mtku_udal,
               -- [Способ обнаружения]
               CASE WHEN m.detection_code = 'NOVALUE' THEN 'Не указано'
                    ELSE CASE right(m.detection_code, 1)
                             WHEN 'D' THEN 'Дефектоскопист'   WHEN 'R' THEN 'Ремонт. персонал'
                             WHEN 'T' THEN 'Технол. персонал' WHEN 'A' THEN 'Случайное наблюдение' END
               END                                                        AS detection_method,
               CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(m.user_status, ARRAY['%РОТМ%']) THEN 1 ELSE 0 END
                                                                          AS flag_otm,         -- Признак ОТМ
               -- требование 1127 (2025): МТКУ с 01.01.2025 по дате создания
               CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(m.sys_status, ARRAY['%МТКУ%']) AND m.created_date >= date '2025-01-01'
                    THEN 1 ELSE 0 END                                     AS filter_mtku_2025, -- Фильтр с МТКУ 2025
               CASE m.notif_type WHEN 'R1' THEN 'Плановая' WHEN 'R2' THEN 'Аварийная'
                                 WHEN 'R3' THEN 'Внеплановая' END         AS work_kind,        -- Вид работы
               coalesce(w.workcenter_name, 'Не указан')                   AS resp_workcenter_name, -- ОРМ_наименование
               -- поля заказа
               o.order_num        AS ord_order_num,        -- Заказ.temp
               o.sys_status       AS ord_sys_status,       -- Системный статус
               o.fact_end_date    AS ord_fact_end_date,    -- Дата завершения выполнения (факт)
               o.plan_end_date    AS ord_plan_end_date,    -- Дата завершения выполнения (план)
               o.plan_start_date  AS ord_plan_start_date,  -- Дата начала выполнения (план)
               o.fact_start_date  AS ord_fact_start_date,  -- Дата начала выполнения (факт)
               o.fact_start_time  AS ord_fact_start_time,  -- Время начала выполнения (факт)
               o.fact_end_time    AS ord_fact_end_time,    -- Время завершения выполнения (факт)
               o.entry_date       AS ord_entry_date,       -- Дата ввода заказа
               CASE WHEN v.func_location IS NOT NULL THEN 1 ELSE 0 END AS is_virtual_fl, -- Признак вирттехместа
               -- служебные булевы
               dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(m.sys_status,  ARRAY['%УДАЛ%','%МТКУ%']) AS c_a,
               dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.sys_status,  ARRAY['%НЕВЫ%','%МТКУ%']) AS c_b,
               dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(m.user_status, ARRAY['%УДАЛ%','%НЕВЫ%']) AS c_c,
               dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(m.user_status, ARRAY['%ПДТВ%'])          AS c_p
        FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages m
        LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders o          ON o.order_num = m.order_num
        LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_virtual_fl v      ON v.func_location = m.func_location
        LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_workcenter_map w  ON w.map_key = coalesce(m.do_code,'') || coalesce(m.resp_workcenter,'')
    ),
    k AS (                 -- [Сообщ_3.temp]
        SELECT b.*,
            -- КПЭ11
            CASE WHEN filter_by_create = 1 THEN
                CASE WHEN c_a OR c_b OR c_c OR order_num IS NULL OR ord_fact_end_date IS NULL THEN 'Не выполнено'
                     WHEN extract(year FROM req_end_date) =  extract(year FROM ord_fact_end_date) THEN 'В срок'
                     WHEN extract(year FROM req_end_date) <> extract(year FROM ord_fact_end_date) THEN 'Просрочено'
                END
            END AS kpi11,
            -- КПЭ10 (±3 дня от планового завершения заказа)
            CASE WHEN filter_by_create = 1 AND filter_no_mtku = 1 THEN
                CASE WHEN c_b OR order_num IS NULL OR ord_fact_end_date IS NULL THEN 'Не выполнено'
                     WHEN ord_fact_end_date <= ord_plan_end_date + 3
                      AND ord_fact_end_date >= ord_plan_end_date - 3 THEN 'В срок'
                     WHEN ord_fact_end_date >  ord_plan_end_date + 3
                       OR ord_fact_end_date <  ord_plan_end_date - 3 THEN 'Просрочено'
                END
            END AS kpi10,
            -- КПЭ15_17
            CASE WHEN filter_by_create = 1 THEN
                CASE WHEN c_a OR c_b OR c_c OR (ord_fact_end_date IS NULL AND NOT c_p) THEN 'Не выполнено'
                     WHEN date_trunc('month', req_end_date) = date_trunc('month', ord_fact_end_date) THEN 'В срок'
                     ELSE 'Просрочено'
                END
            END AS kpi15_17,
            -- требование 1126: оценка просрочки (<1 мес / 1..3 мес / >=3 мес) — Dual(текст, код)
            CASE WHEN filter_by_create = 1 THEN
                CASE WHEN c_a OR c_b OR c_c OR (ord_fact_end_date IS NULL AND NOT c_p) THEN NULL
                     WHEN date_trunc('month', req_end_date) = date_trunc('month', ord_fact_end_date) THEN NULL
                     WHEN ord_fact_end_date <  date_trunc('month', req_end_date) + interval '2 month'
                      AND ord_fact_end_date >  date_trunc('month', req_end_date) - interval '1 month' THEN '1 месяц'
                     WHEN ord_fact_end_date <  date_trunc('month', req_end_date) + interval '3 month'
                      AND ord_fact_end_date >  date_trunc('month', req_end_date) - interval '2 month' THEN '2 месяца'
                     ELSE '3 и более'
                END
            END AS kpi15_17_overdue_name,
            CASE WHEN filter_by_create = 1 THEN
                CASE WHEN c_a OR c_b OR c_c OR (ord_fact_end_date IS NULL AND NOT c_p) THEN NULL
                     WHEN date_trunc('month', req_end_date) = date_trunc('month', ord_fact_end_date) THEN NULL
                     WHEN ord_fact_end_date <  date_trunc('month', req_end_date) + interval '2 month'
                      AND ord_fact_end_date >  date_trunc('month', req_end_date) - interval '1 month' THEN 1
                     WHEN ord_fact_end_date <  date_trunc('month', req_end_date) + interval '3 month'
                      AND ord_fact_end_date >  date_trunc('month', req_end_date) - interval '2 month' THEN 2
                     ELSE 3
                END
            END AS kpi15_17_overdue_code,
            -- КПЭ15_17_БезМТКУ (требование от 15.02.23)
            CASE WHEN filter_by_create = 1 AND filter_no_mtku = 1 THEN
                CASE WHEN c_b OR c_c OR (ord_fact_end_date IS NULL AND NOT c_p) THEN 'Не выполнено'
                     WHEN date_trunc('month', req_end_date) = date_trunc('month', ord_fact_end_date) THEN 'В срок'
                     ELSE 'Просрочено'
                END
            END AS kpi15_17_no_mtku,
            -- КПЭ 28: заказ создан позднее 5 дней после сообщения
            CASE WHEN filter_no_mtku = 1 THEN
                CASE WHEN ord_entry_date - created_date > 5 THEN 1 ELSE 0 END
            ELSE 0 END AS kpi28,
            -- общий признак "не выполнено"
            CASE WHEN filter_by_create = 1 THEN
                CASE WHEN c_a OR c_b OR c_c OR (ord_fact_end_date IS NULL AND NOT c_p) THEN 1 ELSE 0 END
            END AS kpi_x_not_done,
            -- КПЭ 14
            CASE WHEN c_a OR c_b OR c_c OR ord_fact_end_date IS NULL THEN 0 ELSE 1 END AS kpi14,
            -- КПЭ 32
            CASE WHEN c_a OR c_b OR c_c OR ord_fact_end_date IS NULL OR created_date > req_start_date
                 THEN 0 ELSE 1 END AS kpi32_a,
            CASE WHEN c_a OR c_b OR c_c OR created_date > req_start_date
                 THEN 0 ELSE 1 END AS kpi32_b,
            -- только месяц, без года — как в исходнике
            CASE WHEN extract(month FROM req_end_date) = extract(month FROM ord_fact_end_date)
                 THEN 1 ELSE 0 END AS kpi32_eadd,
            CASE WHEN ord_order_num IS NULL THEN 1 ELSE 0 END AS no_order,          -- Нет заказа
            CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(user_status, ARRAY['%ДССП%'])
                  AND extract(year FROM created_date) < extract(year FROM ord_fact_end_date)
                 THEN 'R1' ELSE notif_type END AS notif_type_dssp                   -- Вид сообщения ДССП
        FROM b
    ),
    cnt_d AS (             -- 04.01.02: [Кол-во для D]
        -- аварийные (R2) сообщения подрядчика (RDS) по причине OP3:
        -- сколько ДРУГИХ сообщений этой ЕО завершены (факт заказа) в окне [создание-14 дн; создание]
        SELECT a.equipment, a.notification, count(*) AS cnt_for_d
        FROM b a
        JOIN b t ON t.equipment = a.equipment AND t.notification <> a.notification
        WHERE dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(a.performer,           ARRAY['%RDS%'])
          AND dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(a.failure_reason_code, ARRAY['%OP3%'])
          AND dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(a.notif_type,          ARRAY['%R2%'])
          AND t.ord_fact_end_date >= a.created_date - 14
          AND t.ord_fact_end_date <= a.created_date
        GROUP BY a.equipment, a.notification
    ),
    kpi AS (            -- итог 04.01.01 + 04.01.02
        SELECT k.*,
            -- второй проход [Сообщ.temp] (04.01.01, нижний блок)
            CASE WHEN extract(year FROM req_end_date) =  extract(year FROM ord_fact_end_date) AND kpi_x_not_done = 0
                 THEN 1 ELSE 0 END AS kpi11_in_time,
            CASE WHEN extract(year FROM req_end_date) <> extract(year FROM ord_fact_end_date) AND kpi_x_not_done = 0
                 THEN 1 ELSE 0 END AS kpi11_overdue,
            CASE WHEN ord_fact_end_date <= ord_plan_end_date AND kpi_x_not_done = 0 THEN 1 ELSE 0 END AS kpi10_in_time,
            CASE WHEN ord_fact_end_date >  ord_plan_end_date AND kpi_x_not_done = 0 THEN 1 ELSE 0 END AS kpi10_overdue,
            CASE WHEN date_trunc('month', req_end_date) = date_trunc('month', ord_fact_end_date) AND kpi_x_not_done = 0
                 THEN 1 ELSE 0 END AS kpi15_17_in_time,
            CASE WHEN date_trunc('month', req_end_date) <> date_trunc('month', ord_fact_end_date) AND kpi_x_not_done = 0
                 THEN 1 ELSE 0 END AS kpi15_17_overdue,
            -- Left Join [Reason for refuse]
            fr.reason_group,                                   -- Причина отказа_загл
            fr.reason_name,                                    -- Причина отказа
            -- технические места (TM2..TM6) + описания
            dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(k.func_location, 2) AS tm2,     -- Месторождение
            dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(k.func_location, 3) AS tm3,     -- Объект
            dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(k.func_location, 4) AS tm4,     -- Оборудование
            dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(k.func_location, 5) AS tm5,     -- Уровень5
            dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(k.func_location, 6) AS tm6,     -- Уровень6
            f2.fl_name AS tm2_name, f3.fl_name AS tm3_name, f4.fl_name AS tm4_name,
            f5.fl_name AS tm5_name, f6.fl_name AS tm6_name,
            CASE WHEN k.func_location IS NULL THEN NULL
                 WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(k.func_location, 3), ARRAY['%DRT%','%DRB%']) THEN 1
                 ELSE 0 END AS drt_drb,
            d.cnt_for_d                                        -- Кол-во для D
        FROM k
        LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_failure_reason fr ON fr.reason_code = k.failure_reason_code
        LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location f2  ON f2.func_location = dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(k.func_location, 2)
        LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location f3  ON f3.func_location = dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(k.func_location, 3)
        LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location f4  ON f4.func_location = dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(k.func_location, 4)
        LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location f5  ON f5.func_location = dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(k.func_location, 5)
        LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location f6  ON f6.func_location = dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(k.func_location, 6)
        LEFT JOIN cnt_d d ON d.notification = k.notification AND d.equipment = k.equipment
    ),
    p AS (                                   -- [Исполнитель_Тип]
        SELECT k.*,
               CASE WHEN     dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(performer, ARRAY['%RDB%']) AND     dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(performer, ARRAY['%RDS%']) THEN 'Смешан'
                    WHEN     dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(performer, ARRAY['%RDB%']) AND NOT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(performer, ARRAY['%RDS%']) THEN 'RDB'
                    WHEN NOT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(performer, ARRAY['%RDB%']) AND     dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(performer, ARRAY['%RDS%']) THEN 'RDS'
                    ELSE 'Не указан' END AS performer_type,
               dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_substr_count(performer, ',') + 1 AS n_performers
        FROM kpi k
    ),
    names AS (                                    -- [CообщИсполнитель]: коды ОРМ исполнителей -> наименования
        SELECT do_code, notification,
               string_agg(nm, ', ' ORDER BY nm) AS performer_names
        FROM (SELECT x.do_code, x.notification,
                     coalesce(w.workcenter_name, 'Не указан') AS nm
              FROM (SELECT do_code, notification,
                           btrim(regexp_split_to_table(coalesce(performer, ''), ',')) AS code
                    FROM kpi) x
              LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_workcenter_map w
                     ON w.map_key = coalesce(x.do_code, '') || x.code) y
        GROUP BY do_code, notification
    )
    SELECT
        coalesce(p.notification,'X')||coalesce(p.order_num,'X') as key_ord_note,
        p.equipment, p.notification, p.order_num, p.notif_type, p.req_start_date, p.req_end_date,
        p.user_status, p.sys_status, p.detection_code, p.failure_reason_code, p.work_plan_h, p.work_fact_h,
        p.work_fact_h_raw, p.do_code, p.created_date, p.description, p.func_location, p.toro_work_type,
        p.analysis_required, p.analysis_done, p.performer, p.equipment_part, p.failure_reason_name,
        p.failure_mode_text, p.failure_mechanism, p.failure_crit_code, p.failure_crit_name, p.failure_crit_sort,
        p.resp_workcenter,
        p.filter_by_create, p.filter_no_mtku, p.flag_mtku_udal, p.detection_method, p.flag_otm,
        p.filter_mtku_2025, p.work_kind, p.resp_workcenter_name,
        p.ord_order_num, p.ord_sys_status, p.ord_fact_end_date, p.ord_plan_end_date, p.ord_plan_start_date,
        p.ord_fact_start_date, p.ord_fact_start_time, p.ord_fact_end_time, p.ord_entry_date, p.is_virtual_fl,
        p.kpi11, p.kpi10, p.kpi15_17, p.kpi15_17_overdue_name, p.kpi15_17_overdue_code, p.kpi15_17_no_mtku,
        p.kpi28, p.kpi_x_not_done, p.kpi14, p.kpi32_a, p.kpi32_b, p.kpi32_eadd, p.no_order, p.notif_type_dssp,
        p.kpi11_in_time, p.kpi11_overdue, p.kpi10_in_time, p.kpi10_overdue, p.kpi15_17_in_time, p.kpi15_17_overdue,
        p.reason_group, p.reason_name,
        p.tm2, p.tm3, p.tm4, p.tm5, p.tm6, p.tm2_name, p.tm3_name, p.tm4_name, p.tm5_name, p.tm6_name,
        p.drt_drb, p.cnt_for_d,
        p.performer_type,
        -- разнесение трудозатрат: доля кодов RDB/RDS в списке исполнителей
        CASE p.performer_type WHEN 'RDB'    THEN p.work_fact_h
                              WHEN 'Смешан' THEN p.work_fact_h * dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_substr_count(p.performer, 'RDB') / p.n_performers
                              ELSE 0 END                                         AS work_fact_own_h,
        CASE p.performer_type WHEN 'RDS'    THEN p.work_fact_h
                              WHEN 'Смешан' THEN p.work_fact_h * dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_substr_count(p.performer, 'RDS') / p.n_performers
                              ELSE 0 END                                         AS work_fact_contr_h,
        CASE WHEN p.performer_type = 'Не указан' THEN p.work_fact_h ELSE 0 END    AS work_fact_unknown_h,
        o.mvz_sum,
        o.work_fact_h                                                           AS order_work_fact_h,
        -- затраты заказа пропорционально трудозатратам (деление на 0 -> NULL, как в Qlik)
        o.mvz_sum * (CASE p.performer_type WHEN 'RDB' THEN p.work_fact_h
                          WHEN 'Смешан' THEN p.work_fact_h * dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_substr_count(p.performer, 'RDB') / p.n_performers
                          ELSE 0 END) / nullif(o.work_fact_h, 0)                AS cost_own,
        o.mvz_sum * (CASE p.performer_type WHEN 'RDS' THEN p.work_fact_h
                          WHEN 'Смешан' THEN p.work_fact_h * dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_substr_count(p.performer, 'RDS') / p.n_performers
                          ELSE 0 END) / nullif(o.work_fact_h, 0)                AS cost_contr,
        o.mvz_sum * (CASE WHEN p.performer_type = 'Не указан' THEN p.work_fact_h ELSE 0 END)
                  / nullif(o.work_fact_h, 0)                                    AS cost_unknown,
        n.performer_names,
        case when p.sys_status like '%МТКУ%' then 1 else 0 end sys_status_no_mtku,
        case when p.user_status like '%УДАЛ%' then 1 else 0 end user_status_no_udal
    FROM p
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders o ON o.order_num = p.order_num
    LEFT JOIN names n ON n.notification = p.notification
                     AND coalesce(n.do_code, '') = coalesce(p.do_code, '');   -- hash-join friendly
    GET DIAGNOSTICS v_rows = ROW_COUNT;
    ANALYZE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages;
    RETURN v_rows;
END;
$$;
