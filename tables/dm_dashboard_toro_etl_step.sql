/* =====================================================================
   07_dm_dashboard_toro_orchestration.sql — реестр шагов и запуск всего ETL
   Заменяет последовательность вкладок Qlik (Loader -> Code).
   Слой Loader (xlsx -> QVD) реализован представлениями v_src_* и отдельного шага не требует.

   Запуск:
     SELECT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_run_all();      -- все шаги
     SELECT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_run_all(30);    -- начиная с шага 30
   Из Airflow — по одной задаче на строку dm_dashboard_toro_etl_step (SELECT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_orders(); ...),
   каждый шаг в своей транзакции, зависимости по step_no.
   ===================================================================== */

DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_step;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_step (
    step_no    int,
    func_name  text,
    target     text,     -- заполняемая таблица
    qlik_src   text,     -- откуда перенесено
    is_active  boolean DEFAULT true
) DISTRIBUTED REPLICATED;

INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_step (step_no, func_name, target, qlik_src) VALUES
 (10, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_orders',         'orders',     'Loader/02.01; Code/02.01, 04.02'),
 (20, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_messages',    'messages',   'Loader/02.02; Code/02.02, 04.01.01-03'),
 (30, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_eo',            'eo',         'Loader/02.03, 02.07; Code/02.03, 02.09, 04.03'),
 (35, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_eo_count_by_do','eo_count_by_do',   'Loader/02.03, 02.07; Code/02.03, 02.09, 04.03'),
 (40, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_eo_ext',        'eo_ext',           'Loader/02.08; Code/04.04'),
 (50, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_cost_fact',     'cost_fact',        'Loader/02.05-02.06, 02.09; Code/02.05, 02.06, 2.13'),
 (53, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_lc_month',      'lc_month',         'Loader/02.05-02.06, 02.09; Code/02.05, 02.06, 2.13'),
 (55, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_service_cost',  'service_cost',     'Loader/02.05-02.06, 02.09; Code/02.05, 02.06, 2.13'),                                                
 (60, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_link',          'link',             'Code/05.02-05.06'),
 (70, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_calendar',      'calendar',         'Code/06.00'),
 (75, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_year_month_counter', 'year_month_counter',   'Code/06.00'),
 (80, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_hb_planner_group',   'hb_planner_group','Addition direct load references'),
 (85, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_hb_do',              'hb_do',           'Addition direct load references'),
 (87, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_kpi_level',              'kpi_level',           'Addition direct load references'),
 (88, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_rav_scale',      'rav_scale',           'Addition direct load references'),
 (90, 'dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_link_ext',           'link_ext',        'Extended Link Table');
