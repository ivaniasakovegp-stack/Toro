


CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_link_ext() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint := 0; v_cnt bigint;
BEGIN
    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext
(
with calnd as
            (SELECT 
            cal.cal_date, 
            cal.quarter_year, 
            cal.quarter_year_sort, 
            cal.year_quarter, 
            cal.year_month, 
            cal.month_year, 
            cal.month_year_sort, 
            cal.month_num, 
            cal.month_name, 
            cal.all_years, 
            cal.year_num, 
            cal.day_counter,
            mcal.month_counter 
FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar cal
            left join dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_year_month_counter mcal on cal.month_year = mcal.month_year),
ref_do as
            (SELECT 
            do_code, 
            do_full_name, 
            do_short_name, 
            do_abbr, 
            do_color, 
            --do_sort, 
            do_sort_num
FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do),
ref_plangr as
            (SELECT 
            planner_group, 
            pg_abbr, 
            pg_text, 
            pg_sort
FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_planner_group)
SELECT 
            coalesce(tl.notification,'X')||coalesce(tl.order_num,'X') as key_ord_note,
            tl.entity, 
            tl.notification, 
            tl.order_num, 
            tl.equipment, 
            tl.do_code, 
            tl.planner_group, 
            tl.cost_key, 
            tl.cost_fact_key, 
            tl.lc_key, 
            tl.eo_ext_key, 
            tl.link_date, 
            tl.date_type, 
            tl.reduction,
            cl.cal_date, 
            cl.quarter_year, 
            cl.quarter_year_sort, 
            cl.year_quarter, 
            cl.year_month, 
            cl.month_year, 
            cl.month_year_sort, 
            cl.month_num, 
            cl.month_name, 
            cl.all_years, 
            cl.year_num, 
            cl.day_counter,
            cl.month_counter,
            rd.do_full_name, 
            rd.do_short_name, 
            rd.do_abbr, 
            rd.do_color, 
            rd.do_sort_num,
            rg.pg_abbr, 
            rg.pg_text, 
            rg.pg_sort,
            ROW_NUMBER() over (partition by order_num order by link_date) as ord_conser_key
FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link tl
left join calnd cl on cl.cal_date=tl.link_date
left join ref_do rd on rd.do_code=tl.do_code
left join ref_plangr rg on rg.planner_group=tl.planner_group
--left join dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_service_cost sc on tl.order_num=sc.order_num
);
GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows := v_rows + v_cnt;
	
	RETURN v_rows;
    
END;
$$;

