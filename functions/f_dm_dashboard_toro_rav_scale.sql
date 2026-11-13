

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_rav_scale() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint := 0; v_cnt bigint;
BEGIN
    
    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_scale;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_scale 
    SELECT scale_name, rav_pct FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_rav_scale;
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows := v_rows + v_cnt;

    RETURN v_rows;
END;
$$;
