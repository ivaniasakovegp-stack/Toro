

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_lc_month() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint := 0; v_cnt bigint;
BEGIN
    
    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_lc_month;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_lc_month SELECT * FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_lc_month;
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows := v_rows + v_cnt;

    --TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_lc;
    --INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_lc SELECT * FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_rav_lc;
    --GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows := v_rows + v_cnt;

    RETURN v_rows;
END;
$$;
