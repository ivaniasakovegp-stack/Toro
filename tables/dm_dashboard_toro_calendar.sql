


/* ---------- Календарь ---------- */
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar (
    cal_date           date,  -- Дата
    quarter_year       text,  -- Квартал Год — текстовая часть Dual, «Кв1-2024»
    quarter_year_sort  date,  -- Квартал Год — числовая часть Dual (конец квартала)
    year_quarter       text,  -- ГодКвартал — «2024-Кв1»
    year_month         text,  -- Год Месяц — «2024.01»
    month_year         text,  -- Месяц Год — текстовая часть Dual, «янв 2024»
    month_year_sort    date,  -- Месяц Год — числовая часть Dual (конец месяца)
    month_num          int,   -- Месяц — номер месяца
    month_name         text,  -- Месяц — название месяца (текстовая часть Dual)
    all_years          int,   -- Все года
    year_num           int,   -- Год — NULL до 2022
    day_counter        int    -- Day Counter
) DISTRIBUTED BY (cal_date);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar IS 'Календарь по диапазону дат таблицы связей. Qlik: таблица [Календарь], 02-02.Model.Календарь.qvd';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar.cal_date IS 'Qlik: [Дата]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar.quarter_year IS 'Qlik: [Квартал Год] — текстовая часть Dual, «Кв1-2024»';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar.quarter_year_sort IS 'Qlik: [Квартал Год] — числовая часть Dual (конец квартала)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar.year_quarter IS 'Qlik: [ГодКвартал] — «2024-Кв1»';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar.year_month IS 'Qlik: [Год Месяц] — «2024.01»';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar.month_year IS 'Qlik: [Месяц Год] — текстовая часть Dual, «янв 2024»';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar.month_year_sort IS 'Qlik: [Месяц Год] — числовая часть Dual (конец месяца)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar.month_num IS 'Qlik: [Месяц] — номер месяца';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar.month_name IS 'Qlik: [Месяц] — название месяца (текстовая часть Dual)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar.all_years IS 'Qlik: [Все года]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar.year_num IS 'Qlik: [Год] — NULL до 2022';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar.day_counter IS 'Qlik: [Day Counter]';
