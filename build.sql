/*
   build.sql — порядок сборки витрины dm_dashboard_toro (Greenplum 6.22 / PostgreSQL 9.4).
   Запуск из каталога проекта:
     psql -d <database> -v ON_ERROR_STOP=1 -f build.sql

   Фазы:
     1. functions — хелперы. Представления вызывают их при создании.
     2. tables — таблицы, комментарии, права и начальное наполнение.
        Журнал etl_log создаётся вместе с последовательностью dm_dashboard_toro_etl_seq_run_id.
        Календарь чисел etl_dim_day заполняется сразу. Реестр шагов etl_step тоже.
     3. views — источники, справочники, расчёт наработки.
        v_ref_eo_type_tracked после v_ref_eo_class.
        v_calc_oper_time_mtbr и v_calc_oper_time_mrp после v_src_oper_time.
     4. functions — загрузчики в порядке step_no, затем f_run_all.

   Повторный запуск пересоздаёт таблицы модели.
   dm_dashboard_toro_etl_log сохраняется: в её скрипте CREATE TABLE IF NOT EXISTS.
*/


-- 1. Функции-хелперы
\ir functions/f_h_nz.sql
\ir functions/f_h_wm.sql
\ir functions/f_h_substr_count.sql
\ir functions/f_h_to_num.sql
\ir functions/f_h_to_ts.sql
\ir functions/f_h_to_dt.sql
\ir functions/f_h_to_tm.sql
\ir functions/f_h_month_abbr.sql
\ir functions/f_h_mmm_yyyy.sql
\ir functions/f_h_file_do.sql
\ir functions/f_h_file_part.sql
\ir functions/f_h_tm_prefix.sql

-- 2. Таблицы
--\ir tables/dm_dashboard_toro_etl_log.sql
\ir tables/dm_dashboard_toro_etl_dim_day.sql
\ir tables/dm_dashboard_toro_orders.sql
\ir tables/dm_dashboard_toro_messages.sql
\ir tables/dm_dashboard_toro_eo.sql
\ir tables/dm_dashboard_toro_eo_count_by_do.sql
\ir tables/dm_dashboard_toro_eo_ext.sql
\ir tables/dm_dashboard_toro_cost_plan_fact.sql
\ir tables/dm_dashboard_toro_cost_fact.sql
\ir tables/dm_dashboard_toro_lc_month.sql
\ir tables/dm_dashboard_toro_rav_lc.sql
\ir tables/dm_dashboard_toro_service_cost.sql
\ir tables/dm_dashboard_toro_link.sql
\ir tables/dm_dashboard_toro_calendar.sql
\ir tables/dm_dashboard_toro_year_month_counter.sql
\ir tables/dm_dashboard_toro_hb_planner_group.sql
\ir tables/dm_dashboard_toro_hb_do.sql
\ir tables/dm_dashboard_toro_kpi_level.sql
\ir tables/dm_dashboard_toro_rav_scale.sql
\ir tables/dm_dashboard_toro_link_ext.sql
--\ir tables/dm_dashboard_toro_etl_step.sql

-- 3. Представления
\ir views/v_src_orders.sql
\ir views/v_src_messages.sql
\ir views/v_src_eo.sql
\ir views/v_src_cost_fact.sql
\ir views/v_src_lc_month.sql
\ir views/v_src_oper_time.sql
\ir views/v_src_eo_oper_time.sql
\ir views/v_src_service_cost.sql
\ir views/v_ref_workcenter_map.sql
\ir views/v_ref_do_company.sql
\ir views/v_ref_eo_class.sql
\ir views/v_ref_npo_type.sql
\ir views/v_ref_eo_type_tracked.sql
\ir views/v_ref_planner_group.sql
\ir views/v_ref_kpi_threshold.sql
\ir views/v_ref_kpi_level.sql
\ir views/v_ref_failure_reason.sql
\ir views/v_ref_cost_center.sql
\ir views/v_ref_work_env.sql
\ir views/v_ref_func_location.sql
\ir views/v_ref_virtual_fl.sql
\ir views/v_ref_rav_scale.sql
\ir views/v_ref_order_type.sql
\ir views/v_ref_maint_strategy.sql
\ir views/v_calc_oper_time_mtbr.sql
\ir views/v_calc_oper_time_mrp.sql

-- 4. Функции загрузки и оркестрация
\ir functions/f_dm_dashboard_toro_order.sql
\ir functions/f_dm_dashboard_toro_messages.sql
\ir functions/f_dm_dashboard_toro_eo.sql
\ir functions/f_dm_dashboard_toro_eo_count_by_do.sql
\ir functions/f_dm_dashboard_toro_eo_ext.sql
\ir functions/f_dm_dashboard_toro_cost_fact.sql
\ir functions/f_dm_dashboard_toro_lc_month.sql
\ir functions/f_dm_dashboard_toro_service_cost.sql
\ir functions/f_dm_dashboard_toro_link.sql
\ir functions/f_dm_dashboard_toro_calendar.sql
\ir functions/f_dm_dashboard_toro_year_month_counter.sql
\ir functions/f_dm_dashboard_toro_hb_planner_group.sql
\ir functions/f_dm_dashboard_toro_hb_do.sql
\ir functions/f_dm_dashboard_toro_kpi_level.sql
\ir functions/f_dm_dashboard_toro_rav_scale.sql
\ir functions/f_dm_dashboard_toro_link_ext.sql
--\ir functions/f_run_all.sql