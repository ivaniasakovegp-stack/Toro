

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_calendar() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE
    v_rows bigint;
    v_min  date;
    v_max  date;
BEGIN
    SELECT min(link_date), max(link_date) INTO v_min, v_max FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link;

    -- если максимальная дата позже конца текущего года — календарь до конца СЛЕДУЮЩЕГО года
    IF v_max > (date_trunc('year', current_date) + interval '1 year - 1 day')::date THEN
        v_max := (date_trunc('year', current_date) + interval '2 year - 1 day')::date;
    END IF;

    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar;
    IF v_min IS NOT NULL THEN
        INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar
        SELECT d.dt,
               'Кв' || extract(quarter FROM d.dt)::int || '-' || extract(year FROM d.dt)::int,
               (date_trunc('quarter', d.dt) + interval '3 month - 1 day')::date,
               extract(year FROM d.dt)::int || '-Кв' || extract(quarter FROM d.dt)::int,
               to_char(d.dt, 'YYYY.MM'),
               dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_month_abbr(extract(month FROM d.dt)::int) || ' ' || extract(year FROM d.dt)::int,
               (date_trunc('month', d.dt) + interval '1 month - 1 day')::date,
               extract(month FROM d.dt)::int,
               dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_month_abbr(extract(month FROM d.dt)::int),
               extract(year FROM d.dt)::int,
               CASE WHEN extract(year FROM d.dt) < 2022 THEN NULL ELSE extract(year FROM d.dt)::int END,
               1
        FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_dim_day d
        WHERE d.dt BETWEEN v_min AND v_max;
    END IF;
    GET DIAGNOSTICS v_rows = ROW_COUNT;

    RETURN v_rows;
END;
$$;
