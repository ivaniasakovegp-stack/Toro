/* ---------- Таблица связей Расширенная Для PixBi (link table extended) ----------
   Одна строка = сущность + её ключи + одна из дат (единое поле Дата/Тип_даты).
   В BI фильтр по календарю/ДО/ГП работает через эту таблицу, как ассоциации в Qlik. */
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext (
    key_ord_note      text,  -- Ключ уникальный Заказ-Сообщение
    entity         text,     -- Сущность
    notification   text,     -- Сообщение
    order_num      text,     -- Заказ
    equipment      text,     -- Единица оборудования
    do_code        text,     -- ДО
    planner_group  text,     -- Группа плановиков
    cost_key       text,     -- Затраты.Ключ
    cost_fact_key  text,     -- ЗатратыФакт.Ключ
    lc_key         text,     -- LC.Ключ
    eo_ext_key     bigint,   -- ЕО.Расш.Ключ
    link_date      date,     -- Дата
    date_type      text,     -- Тип_даты
    reduction      text,      -- REDUCTION — Section Access по ДО (Code/05.06)
    cal_date          date,
    quarter_year      text,
    quarter_year_sort date,
    year_quarter      text,
    year_month        text,
    month_year        text,
    month_year_sort   date,
    month_num         int,
    month_name        text,
    all_years         int,
    year_num          int,
    day_counter       int,
    month_counter     int,
    do_full_name      text,
    do_short_name     text,
    do_abbr           text,
    do_color          text,
    do_sort_num       int,
    pg_abbr           text,
    pg_text           text,
    pg_sort           int,
    ord_conser_key  text    -- Уникальный ключ Заказ-Контрагент-Услуга
)
WITH (appendonly=true, orientation=column, compresstype=zlib, compresslevel=1)
DISTRIBUTED BY (entity,do_code);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext IS 'Таблица связей модели: ключи сущностей, ДО/ГП, единое поле дат и REDUCTION. Qlik: таблица [ТаблСвязей], 02-01.Model.ТаблСвязей.qvd';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.key_ord_note IS 'Ключ уникальный Заказ-Сообщение';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.entity IS 'Qlik: [Сущность]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.notification IS 'Qlik: [Сообщение]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.order_num IS 'Qlik: [Заказ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.equipment IS 'Qlik: [Единица оборудования]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.do_code IS 'Qlik: [ДО]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.planner_group IS 'Qlik: [Группа плановиков]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.cost_key IS 'Qlik: [Затраты.Ключ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.cost_fact_key IS 'Qlik: [ЗатратыФакт.Ключ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.lc_key IS 'Qlik: [LC.Ключ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.eo_ext_key IS 'Qlik: [ЕО.Расш.Ключ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.link_date IS 'Qlik: [Дата]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.date_type IS 'Qlik: [Тип_даты]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.reduction IS 'Qlik: [REDUCTION] — Section Access по ДО (Code/05.06)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.cal_date IS 'Qlik: [Дата]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.quarter_year IS 'Qlik: [Квартал Год] — текстовая часть Dual, «Кв1-2024»';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.quarter_year_sort IS 'Qlik: [Квартал Год] — числовая часть Dual (конец квартала)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.year_quarter IS 'Qlik: [ГодКвартал] — «2024-Кв1»';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.year_month IS 'Qlik: [Год Месяц] — «2024.01»';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.month_year IS 'Qlik: [Месяц Год] — текстовая часть Dual, «янв 2024»';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.month_year_sort IS 'Qlik: [Месяц Год] — числовая часть Dual (конец месяца)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.month_num IS 'Qlik: [Месяц] — номер месяца';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.month_name IS 'Qlik: [Месяц] — название месяца (текстовая часть Dual)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.all_years IS 'Qlik: [Все года]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.year_num IS 'Qlik: [Год] — NULL до 2022';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.day_counter IS 'Qlik: [Day Counter]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.month_counter IS 'Qlik: [Month Counter] — дней в месяце';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.do_full_name IS 'ДО (полное наименование)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.do_short_name IS 'ДО (краткое наименование)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.do_abbr IS 'ДО (сокращение)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.do_color IS 'ДО (цвет)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.do_sort_num IS 'ДО сорт (число)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.pg_abbr IS 'Группа плановиков (сокр.)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.pg_text IS 'Группа плановиков (текст)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.pg_sort IS 'Сортировка';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext.ord_conser_key IS 'Уникальный ключ Заказ-Контрагент-Услуга';
