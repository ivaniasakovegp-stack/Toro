


/* ---------- Таблица связей (link table) ----------
   Одна строка = сущность + её ключи + одна из дат (единое поле Дата/Тип_даты).
   В BI фильтр по календарю/ДО/ГП работает через эту таблицу, как ассоциации в Qlik. */
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link (
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
    reduction      text     -- REDUCTION — Section Access по ДО (Code/05.06)
)
WITH (appendonly=true, orientation=column, compresstype=zlib, compresslevel=1)
DISTRIBUTED BY (entity,do_code);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link IS 'Таблица связей модели: ключи сущностей, ДО/ГП, единое поле дат и REDUCTION. Qlik: таблица [ТаблСвязей], 02-01.Model.ТаблСвязей.qvd';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link.entity IS 'Qlik: [Сущность]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link.notification IS 'Qlik: [Сообщение]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link.order_num IS 'Qlik: [Заказ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link.equipment IS 'Qlik: [Единица оборудования]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link.do_code IS 'Qlik: [ДО]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link.planner_group IS 'Qlik: [Группа плановиков]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link.cost_key IS 'Qlik: [Затраты.Ключ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link.cost_fact_key IS 'Qlik: [ЗатратыФакт.Ключ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link.lc_key IS 'Qlik: [LC.Ключ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link.eo_ext_key IS 'Qlik: [ЕО.Расш.Ключ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link.link_date IS 'Qlik: [Дата]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link.date_type IS 'Qlik: [Тип_даты]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link.reduction IS 'Qlik: [REDUCTION] — Section Access по ДО (Code/05.06)';
