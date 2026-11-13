

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_hb_planner_group() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint := 0; v_cnt bigint;
BEGIN
    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_planner_group;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_planner_group
	SELECT planner_group, pg_abbr, pg_sort_text as pg_text, pg_sort_num as pg_sort
	FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_planner_group;
	GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows := v_rows + v_cnt;
	
	RETURN v_rows;
    
END;
$$;
