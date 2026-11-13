

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_eo() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint;
BEGIN
    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo
    SELECT e.equipment, e.in_operation_from, e.func_location, e.planner_group, e.do_code, e.eo_class,
           e.eo_status, e.maint_strategy,
           coalesce(e.eo_type, 'RDE0000'),
           e.eo_name, e.work_env, e.is_active,
           CASE WHEN e.adjacent_system IS NOT NULL AND e.eo_status = 'В эксплуатации' THEN 'Запущена'
                ELSE e.strategy_status END,
           e.adjacent_system, e.pressure_vessel, e.manufacturer,
           e.mand_data_total, e.mand_data_filled, e.data_total, e.data_filled,
           e.chars_total, e.chars_filled, e.checks_total, e.checks_passed, e.resp_workcenter,
           -- КТГ: B — исключая 7 статусов, E — исключая 5 статусов
           CASE WHEN e.eo_status IS NULL THEN NULL
                WHEN NOT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(e.eo_status, ARRAY['Бездействие','На консервации','Проектируемый','Списано',
                                                       'Строительство','В ожидании ремонта','На проверке']) THEN 1
                ELSE 0 END,
           CASE WHEN e.eo_status IS NULL THEN NULL
                WHEN NOT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(e.eo_status, ARRAY['Бездействие','На консервации','Проектируемый','Списано',
                                                       'Строительство']) THEN 1
                ELSE 0 END,
           substring(e.maint_strategy FROM '\[(.*?)\]'),                     -- TextBetween('[', ']')
           upper(left(e.work_env, 1)) || lower(substr(e.work_env, 2)),
           CASE WHEN e.mand_data_filled = 0 AND e.data_filled = 0 AND e.chars_filled = 0 THEN 1 END,
           coalesce(w.workcenter_name, 'Не указан'),
           CASE WHEN v.func_location IS NOT NULL THEN 1 ELSE 0 END,
           coalesce(c.class_name, 'Класс не определен'),
           c.is_excluded,
           -- 02.07.2024: классы вне классификатора -> 'УППРЭ энергетическое оборудование'
           CASE WHEN NOT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(e.eo_type, ARRAY['RDE%']) AND ct.class_name IS NULL
                     THEN 'УППРЭ энергетическое оборудование'
                WHEN ct.class_name IS NULL THEN 'Не указано'
                ELSE ct.class_name END,
           n.npo_type,
           we.norm_hours,
           CASE WHEN e.func_location IS NULL THEN NULL
                ELSE CASE dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_substr_count(e.func_location, '-')
                         WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 WHEN 4 THEN 5 ELSE 6 END
           END,
           dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(e.func_location, 2), dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(e.func_location, 3),
           dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(e.func_location, 4), dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(e.func_location, 5),
           dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(e.func_location, 6),
           f2.fl_name, f3.fl_name, f4.fl_name, f5.fl_name, f6.fl_name,
           ms.strategy_descr,
           mrp.mrp,
           mtbr.avg_oper_time,
           case when tt.eo_type_code is not null then 1 else 0 end as eo_type_top10,
           case when e.eo_type like '%RDE03%' then 1 else 0 end as eo_type_rde03
    FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo e
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_workcenter_map w ON w.map_key = coalesce(e.do_code,'') || coalesce(e.resp_workcenter,'')
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_virtual_fl v     ON v.func_location = e.func_location
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_class c       ON c.class_code  = e.eo_class
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_class ct      ON ct.class_code = e.eo_type
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_npo_type n
           ON n.npo_index = CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(e.pressure_vessel) IS NULL THEN e.eo_class ELSE e.eo_class || e.pressure_vessel END
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_work_env we      ON we.work_env = e.work_env
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location f2 ON f2.func_location = dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(e.func_location, 2)
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location f3 ON f3.func_location = dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(e.func_location, 3)
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location f4 ON f4.func_location = dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(e.func_location, 4)
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location f5 ON f5.func_location = dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(e.func_location, 5)
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location f6 ON f6.func_location = dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(e.func_location, 6)
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_maint_strategy ms ON ms.maint_strategy = e.maint_strategy
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_calc_oper_time_mrp  mrp  ON mrp.equipment  = e.equipment
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_calc_oper_time_mtbr mtbr ON mtbr.equipment = e.equipment
    left join dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_type_tracked tt on tt.eo_type_descr=ct.class_name
    WHERE e.equipment IS NOT NULL AND e.do_code IS NOT NULL;
    GET DIAGNOSTICS v_rows = ROW_COUNT;

    ANALYZE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo;
    RETURN v_rows;
END;
$$;
