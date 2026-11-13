/* =====================================================================
   06_dm_dashboard_toro_costs_link_calendar.sql
     - затраты (ЗатратыПланФакт, ЗатратыФакт, LC, RavLc, Затраты по услугам)
     - таблица связей ТаблСвязей (02-01.Model.ТаблСвязей.qvd) с единым полем дат и REDUCTION
     - календарь (02-02.Model.Календарь.qvd) и YearMonthCounter (02-03)
   Источник логики: Code/02.05, 02.06, 2.13, 05.01–05.06, 06.00
   ===================================================================== */

/* ---------- Затраты ---------- */
-- [ЗатратыПланФакт]
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact (
    cost_key       text,     -- Затраты.Ключ — Завод|ГП|MMM_YYYY
    do_code        text,     -- ДО — совпадает с полем _DO
    month_start    date,     -- Дата на начало месяца
    rav_lc_key     text,     -- RavLc.Ключ — Завод|Год
    planner_group  text,     -- Группа плановиков
    cost_category  text,     -- Категория затрат
    cost_plan      numeric,  -- Затраты план, руб — исходное значение × 1000
    cost_fact      numeric,  -- Затраты факт, руб — исходное значение × 1000
    cost_forecast  numeric   -- Затраты прогноз, руб — исходное значение × 1000
) DISTRIBUTED BY (do_code);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact IS 'Затраты ТОиР план/факт/прогноз по ДО, группе плановиков и месяцу. Qlik: таблица [ЗатратыПланФакт] (поля с префиксом Затраты_ПФ.)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact.cost_key IS 'Qlik: [Затраты.Ключ] — Завод|ГП|MMM_YYYY';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact.do_code IS 'Qlik: [ДО] — совпадает с полем _DO';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact.month_start IS 'Qlik: [Затраты_ПФ.Дата на начало месяца]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact.rav_lc_key IS 'Qlik: [RavLc.Ключ] — Завод|Год';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact.planner_group IS 'Qlik: [Группа плановиков]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact.cost_category IS 'Qlik: [Затраты_ПФ.Категория затрат]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact.cost_plan IS 'Qlik: [Затраты_ПФ.Затраты план, руб] — исходное значение × 1000';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact.cost_fact IS 'Qlik: [Затраты_ПФ.Затраты факт, руб] — исходное значение × 1000';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact.cost_forecast IS 'Qlik: [Затраты_ПФ.Затраты прогноз, руб] — исходное значение × 1000';
