

DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_year_month_counter;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_year_month_counter (
    month_year     text,  -- Месяц Год
    month_counter  int    -- Month Counter — дней в месяце
) DISTRIBUTED BY (month_year);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_year_month_counter IS 'Количество дней в каждом месяце календаря. Qlik: таблица [YearMonthCounter], 02-03.Model.Календарь.Дней_Месяца.qvd';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_year_month_counter.month_year IS 'Qlik: [Месяц Год]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_year_month_counter.month_counter IS 'Qlik: [Month Counter] — дней в месяце';
