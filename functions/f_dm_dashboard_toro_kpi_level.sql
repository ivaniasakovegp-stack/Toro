

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_kpi_level() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint := 0; v_cnt bigint;
BEGIN
    	
	TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level
	SELECT hb_kpi_level0.kpi_num AS kpi_level,
    hb_kpi_level0.unit,
			CASE
				WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(hb_kpi_level0.low_value) IS NOT NULL THEN 
				dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(hb_kpi_level0.low_value)::numeric --|| COALESCE(hb_kpi_level0.unit, ''::text)
				ELSE NULL::numeric
			END AS low_limit,
			CASE
				WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(hb_kpi_level0.target_value) IS NOT NULL THEN 
				dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(hb_kpi_level0.target_value)::numeric --|| COALESCE(hb_kpi_level0.unit, ''::text)
				ELSE NULL::numeric
			END AS target_limit,
			CASE
				WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(hb_kpi_level0.high_value) IS NOT NULL THEN 
				dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(hb_kpi_level0.high_value)::numeric --|| COALESCE(hb_kpi_level0.unit, ''::text)
				ELSE NULL::numeric
			END AS high_limit,
		NULL::numeric AS low_limit_low,
		NULL::numeric AS low_limit_high,
		NULL::numeric AS target_limit_low,
		NULL::numeric AS target_limit_high,
		NULL::numeric AS high_limit_low,
		NULL::numeric AS high_limit_high,
		hb_kpi_level0.src_sheet
	FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_kpi_level0
	WHERE hb_kpi_level0.src_sheet = 'Sheet2'::text
	UNION ALL
	SELECT hb_kpi_level1.kpi_num AS kpi_level,
		hb_kpi_level1.unit,
		NULL::numeric AS low_limit,
		NULL::numeric AS target_limit,
		NULL::numeric AS high_limit,
			CASE
				WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(hb_kpi_level1.low_value) IS NOT NULL THEN 
				dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(split_part(hb_kpi_level1.low_value, '-'::text, 1))::numeric --|| COALESCE(hb_kpi_level1.unit, ''::text)
				ELSE NULL::numeric
			END AS low_limit_low,
			CASE
				WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(hb_kpi_level1.low_value) IS NOT NULL THEN 
				dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(split_part(hb_kpi_level1.low_value, '-'::text, 2))::numeric --|| COALESCE(hb_kpi_level1.unit, ''::text)
				ELSE NULL::numeric
			END AS low_limit_high,
			CASE
				WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(hb_kpi_level1.target_value) IS NOT NULL THEN 
				dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(split_part(hb_kpi_level1.target_value, '-'::text, 1))::numeric --|| COALESCE(hb_kpi_level1.unit, ''::text)
				ELSE NULL::numeric
			END AS target_limit_low,
			CASE
				WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(hb_kpi_level1.target_value) IS NOT NULL THEN 
				dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(split_part(hb_kpi_level1.target_value, '-'::text, 2))::numeric --|| COALESCE(hb_kpi_level1.unit, ''::text)
				ELSE NULL::numeric
			END AS target_limit_high,
			CASE
				WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(hb_kpi_level1.high_value) IS NOT NULL THEN 
				dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(split_part(hb_kpi_level1.high_value, '-'::text, 1))::numeric --|| COALESCE(hb_kpi_level1.unit, ''::text)
				ELSE NULL::numeric
			END AS high_limit_low,
			CASE
				WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(hb_kpi_level1.high_value) IS NOT NULL THEN 
				dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(split_part(hb_kpi_level1.high_value, '-'::text, 2))::numeric --|| COALESCE(hb_kpi_level1.unit, ''::text)
				ELSE NULL::numeric
			END AS high_limit_high,
		hb_kpi_level1.src_sheet
	FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_kpi_level1
	WHERE hb_kpi_level1.src_sheet = 'Sheet3'::text;

	GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows := v_rows + v_cnt;
	
	RETURN v_rows;
    
END;
$$;
