

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_year_month_counter() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE
    v_rows bigint;
BEGIN
    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_year_month_counter;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_year_month_counter
    SELECT month_year, sum(day_counter) FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar GROUP BY month_year;
    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN v_rows;
END;
$$;
