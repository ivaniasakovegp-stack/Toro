

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_eo_count_by_do() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint;
BEGIN

    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_count_by_do;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_count_by_do
    SELECT do_code, count(equipment) FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo WHERE do_code IS NOT NULL GROUP BY do_code;
    GET DIAGNOSTICS v_rows = ROW_COUNT;

    ANALYZE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_count_by_do;

    RETURN v_rows;
END;
$$;
