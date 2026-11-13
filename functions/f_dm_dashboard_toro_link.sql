

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_link() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint;
BEGIN
    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link
    SELECT l.*,
           d.do_code                                                  -- 05.06 SectionAccess - ДО (REDUCTION)
    FROM (
        -- Сообщения: ключи + ДО/ГП из ЕО + 6 типов дат
        SELECT 'Сообщения'::text, k.notification, k.order_num, k.equipment, e.do_code, e.planner_group,
               NULL::text, NULL::text, NULL::text, NULL::bigint, dt.link_date, dt.date_type
        FROM (SELECT DISTINCT notification, order_num, equipment FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages) k
        LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo e ON e.equipment = k.equipment
        LEFT JOIN (
            SELECT DISTINCT m.notification,
                   CASE t.n WHEN 1 THEN m.ord_plan_start_date WHEN 2 THEN m.ord_fact_end_date
                            WHEN 3 THEN m.ord_plan_end_date   WHEN 4 THEN m.req_start_date
                            WHEN 5 THEN m.req_end_date        WHEN 6 THEN m.created_date END AS link_date,
                   CASE t.n WHEN 1 THEN 'Заказы.Дата начала выполнения (план)'
                            WHEN 2 THEN 'Заказы.Дата завершения выполнения (факт)'
                            WHEN 3 THEN 'Заказы.Дата завершения выполнения (план)'
                            WHEN 4 THEN 'Сообщ.Дата начала сообщения (план)'
                            WHEN 5 THEN 'Сообщ.Дата завершения сообщения (план)'
                            WHEN 6 THEN 'Сообщ.Дата создания сообщения' END        AS date_type
            FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages m
            CROSS JOIN (SELECT generate_series(1, 6) AS n) t
        ) dt ON dt.notification = k.notification

        UNION ALL
        -- ЗатратыПланФакт
        SELECT 'ЗатратыПланФакт', NULL, NULL, NULL, k.do_code, k.planner_group,
               k.cost_key, NULL, NULL, NULL, dt.month_start, 'Затраты_ПФ.Дата на начало месяца'
        FROM (SELECT DISTINCT cost_key, do_code, planner_group FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact) k
        LEFT JOIN (SELECT DISTINCT cost_key, month_start FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact) dt ON dt.cost_key = k.cost_key

        UNION ALL
        -- ЗатратыФакт
        SELECT 'ЗатратыФакт', NULL, NULL, NULL, k.do_code, NULL,
               NULL, k.cost_fact_key, NULL, NULL, dt.month_start, 'ЗатратыФакт.Дата на начало месяца'
        FROM (SELECT DISTINCT cost_fact_key, do_code FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact) k
        LEFT JOIN (SELECT DISTINCT cost_fact_key, month_start FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact) dt
               ON dt.cost_fact_key = k.cost_fact_key

        UNION ALL
        -- LC(мес)
        SELECT 'LC(мес)', NULL, NULL, NULL, k.do_code, NULL,
               NULL, NULL, k.lc_key, NULL, dt.month_start, 'LC.Дата на начало месяца'
        FROM (SELECT DISTINCT lc_key, do_code FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_lc_month) k
        LEFT JOIN (SELECT DISTINCT lc_key, month_start FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_lc_month) dt ON dt.lc_key = k.lc_key

        UNION ALL
        -- ЕО (без даты)
        SELECT DISTINCT 'ЕО', NULL, NULL, equipment, do_code, planner_group,
               NULL, NULL, NULL, NULL::bigint, NULL::date, NULL
        FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo

        UNION ALL
        -- ЕО_Ext
        SELECT DISTINCT 'ЕО_Ext', NULL, NULL, equipment, do_code, planner_group,
               NULL, NULL, NULL, eo_ext_key, month_start, 'ЕО.Ext.Первый день месяца выполнения заказа'
        FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext
    ) l (entity, notification, order_num, equipment, do_code, planner_group,
         cost_key, cost_fact_key, lc_key, eo_ext_key, link_date, date_type)
    LEFT JOIN (SELECT DISTINCT do_code FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_do_company) d ON d.do_code = l.do_code;
    GET DIAGNOSTICS v_rows = ROW_COUNT;
    ANALYZE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link;
    RETURN v_rows;
END;
$$;
