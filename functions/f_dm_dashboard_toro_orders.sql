

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_orders() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint;
BEGIN
    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders
    SELECT o.order_num, o.sys_status, o.user_status, o.order_type,
           o.plan_start_date, o.plan_end_date, o.fact_start_date, o.fact_end_date,
           o.confirm_date, o.confirm_time, o.fact_start_time, o.fact_end_time,
           o.do_code, o.mvz_sum, o.mvz_code, o.entry_date, o.short_text,
           -- 02.01: признаки
           CASE WHEN o.plan_end_date >= o.fact_end_date AND o.fact_end_date IS NOT NULL
                 AND dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.sys_status, ARRAY['%ТЗКР%','%ЗАКР%'])
                 AND NOT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.sys_status, ARRAY['%НЕВЫ%','%МТКУ%']) THEN 1 END,
           CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.sys_status, ARRAY['%ТЗКР%','%ЗАКР%'])
                 AND NOT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.sys_status, ARRAY['%НЕВЫ%','%МТКУ%']) THEN 1 END,
           CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.sys_status, ARRAY['%НЕВЫ%','%МТКУ%']) THEN 1 END,
           CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.sys_status, ARRAY['%ПДТВ%','%ЧПДТ%'])
                 AND NOT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.sys_status, ARRAY['%НЕВЫ%']) THEN 1 END,
           CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.sys_status, ARRAY['%ПДТВ%'])
                 AND NOT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.sys_status, ARRAY['%НЕВЫ%']) THEN 1 END,
           -- пустое время подменяется на 23:59:59
           CASE WHEN o.confirm_date IS NOT NULL AND o.fact_end_date IS NOT NULL THEN
                extract(epoch FROM (
                    (o.confirm_date  + coalesce(o.confirm_time,  time '23:59:59'))
                  - (o.fact_end_date + coalesce(o.fact_end_time, time '23:59:59'))
                )) / 3600.0
           END,
           CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.user_status, ARRAY['%НМТР%'])
                 AND NOT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.user_status, ARRAY['%СГМ%']) THEN 1 ELSE 0 END,
           CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.sys_status, ARRAY['%НЕВЫ%','%МТКУ%']) THEN 1 ELSE 0 END,
           CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.user_status, ARRAY['%СГМ%']) THEN 1 ELSE 0 END,
           -- 04.02: Σ трудозатрат по сообщениям заказа
           w.work_fact_h, w.work_plan_h,
           t.order_type_text, t.work_kind,
           cc.cc_name,
           case when dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(o.sys_status,  ARRAY['%МТКУ%','%НЕВЫ%']) then 1 else 0 end as sys_status_not,
           case when o.user_status like '%СГМ%' then 1 else 0 end user_status_not_sgm
    FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders o
    LEFT JOIN (SELECT order_num,
                      coalesce(sum(work_fact_h), 0) AS work_fact_h,   -- Sum() в Qlik по одним NULL = 0
                      coalesce(sum(work_plan_h), 0) AS work_plan_h
               FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages
               WHERE order_num IS NOT NULL
               GROUP BY order_num) w ON w.order_num = o.order_num
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_order_type  t  ON t.order_type   = o.order_type
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_cost_center cc ON cc.cost_center = o.mvz_code;
    GET DIAGNOSTICS v_rows = ROW_COUNT;
    ANALYZE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders;
    RETURN v_rows;
END;
$$;
