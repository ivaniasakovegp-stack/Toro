

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_hb_do() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint := 0; v_cnt bigint;
BEGIN
    	
	TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do
	SELECT do_code, do_full_name, do_short_name, do_abbr, do_color, do_sort_text as do_sort, do_sort_num
	FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_do_company;
	GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows := v_rows + v_cnt;
	
	RETURN v_rows;
    
END;
$$;
