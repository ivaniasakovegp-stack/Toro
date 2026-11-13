/* =====================================================================
   01_dm_dashboard_toro_init.sql — схема prj_brd_sa; таблицы модели — с префиксом dm_dashboard_toro_
   Здесь размещается всё, кроме сырых данных Excel (они — объекты dfs_dashboard_toro_* той же схемы):
     - функции-хелперы (аналоги функций Qlik)
     - технические таблицы: журнал, реестр шагов, календарь-числа
     - представления над исходными данными (бывший Loader / DataTier1) и справочники
     - итоговые таблицы модели (бывший DataTier2), заполняемые функциями загрузки

   Соглашения об именах:
     v_src_*                    — представление: очищенные/типизированные данные одного Excel-источника
     v_ref_*                    — представление: справочник
     v_calc_*                   — представление: расчётный промежуточный результат
     f_*                        — функции загрузки итоговых таблиц и оркестрации
     f_h_*                      — функции-хелперы (nz, wm, to_num, to_ts, …)
     dm_dashboard_toro_etl_*    — технические таблицы и последовательность
     прочие dm_dashboard_toro_* — итоговая модель данных

   Совместимость: Greenplum 6.22 (PostgreSQL 9.4.26).
   ===================================================================== */

--CREATE SCHEMA IF NOT EXISTS prj_brd_sa;

/* ---------------------------------------------------------------------
   Журнал загрузки (замена Trace + FileList/ModFileTime из 01.03)
   --------------------------------------------------------------------- */
-- история запусков сохраняется при повторном развёртывании
CREATE TABLE IF NOT EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_log (
    run_id        bigint,
    step_no       int,
    step_name     text,
    started_at    timestamp,
    finished_at   timestamp,
    rows_affected bigint,
    status        text,          -- OK / ERROR
    message       text
)
DISTRIBUTED BY (run_id);

-- CREATE SEQUENCE IF NOT EXISTS появился только в 9.5 -> проверка через каталог
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
                   WHERE n.nspname = 'dp_rid_dmt_cns_corp_pixbi_brd_toro' AND c.relname = 'dm_dashboard_toro_etl_seq_run_id' AND c.relkind = 'S') THEN
        CREATE SEQUENCE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_seq_run_id;
    END IF;
END
$$;
