

-- [ЗатратыФакт] (02-08.Model.Zatrat)
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact (
    cost_fact_key  text,     -- ЗатратыФакт.Ключ — ДО|MMM_YYYY
    do_code        text,     -- ДО
    month_start    date,     -- Дата на начало месяца
    cost_group     text,     -- Группа затрат
    field_name     text,     -- Месторождение
    workshop       text,     -- Цех
    account_1      text,     -- Account 1
    account_2      text,     -- Account 2
    account        text,     -- Аккаунт
    cost_fact      numeric,  -- Затраты факт, руб — исходное значение × 1000
    cost_plan      numeric   -- Затраты план, руб — исходное значение × 1000
) DISTRIBUTED BY (cost_fact_key);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact IS 'Факт затрат по месяцам (шаблоны 2024). Qlik: таблица [ЗатратыФакт], 02-08.Model.Zatrat.qvd';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact.cost_fact_key IS 'Qlik: [ЗатратыФакт.Ключ] — ДО|MMM_YYYY';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact.do_code IS 'Qlik: [ДО]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact.month_start IS 'Qlik: [ЗатратыФакт.Дата на начало месяца]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact.cost_group IS 'Qlik: [ЗатратыФакт.Группа затрат]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact.field_name IS 'Qlik: [ЗатратыФакт.Месторождение]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact.workshop IS 'Qlik: [ЗатратыФакт.Цех]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact.account_1 IS 'Qlik: [ЗатратыФакт.Account 1]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact.account_2 IS 'Qlik: [ЗатратыФакт.Account 2]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact.account IS 'Qlik: [ЗатратыФакт.Аккаунт]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact.cost_fact IS 'Qlik: [ЗатратыФакт.Затраты факт, руб] — исходное значение × 1000';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact.cost_plan IS 'Qlik: [ЗатратыФакт.Затраты план, руб] — исходное значение × 1000';
