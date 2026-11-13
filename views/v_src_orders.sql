/* =====================================================================
   02_dm_dashboard_toro_src_ref_views.sql — представления над сырыми данными Excel
     v_src_*  — очищенные и типизированные источники (бывший Loader -> DataTier1 QVD)
     v_ref_*  — справочники (бывшие HandBooks + inline-таблицы Qlik)
     v_calc_* — расчёт наработки (МРП, MTBR) по ЕО
   Отдельного слоя хранения нет: представления вычисляются при загрузке итоговых таблиц.
   ===================================================================== */

/* ===================== ИСТОЧНИКИ (Loader) ===================== */

-- 01-01.Extract.ТОРО.Заказы   (Loader/02.01)
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders AS
WITH jt AS (
    SELECT jest.objnr,
           replace(replace(array_agg(DISTINCT stsy.name)::character varying::text, '}'::text, ''::text), '{'::text, ''::text) AS stsy_list,
           replace(replace(array_agg(DISTINCT stus.name)::character varying::text, '}'::text, ''::text), '{'::text, ''::text) AS stus_list
    FROM dp_rid_ods_corp_torobrd_src.jest
    LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_status_user   stus ON stus.guid = jest.stat_guid::uuid
    LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_status_system stsy ON stsy.guid = jest.stat_guid::uuid
    WHERE NOT jest.inact = 'X'::text
      AND NOT jest.stat_guid = ''::text
    GROUP BY jest.objnr
)
SELECT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(order_num)                AS order_num,        -- Заказ
       btrim(sys_status)                AS sys_status,       -- Системный статус
       btrim(user_status)               AS user_status,      -- Пользовательский статус заказа
       order_type                       AS order_type,       -- Вид заказа
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(bas_start)             AS plan_start_date,  -- Дата начала выполнения (план)
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(bas_end)               AS plan_end_date,    -- Дата завершения выполнения (план)
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(fact_start)            AS fact_start_date,  -- Дата начала выполнения (факт)
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(fact_end)              AS fact_end_date,    -- Дата завершения выполнения (факт)
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(confirm_date)          AS confirm_date,     -- Дата подтверждения
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_tm(confirm_time)          AS confirm_time,     -- Время подтверждения
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_tm(fact_start_time)       AS fact_start_time,  -- Время начала выполнения (факт)
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_tm(fact_end_time)         AS fact_end_time,    -- Время завершения выполнения (факт)
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_file_do(src_file)            AS do_code,          -- _DO
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(total_fact_sum)       AS mvz_sum,          -- МВЗ_сумма
       CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(cost_center) IS NULL THEN 'NOVALUE' ELSE cost_center END AS mvz_code, -- МВЗ_код
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(entry_date)            AS entry_date,       -- Дата ввода заказа
       short_text                       AS short_text        -- Краткий текст
FROM dp_rid_ods_corp_dfs_dashboard_toro.orders
union all -- данные из Источника SAP ТОРО
SELECT a.aufnr        AS order_num,        -- Заказ (AUFK-AUFNR)
       jt.stsy_list   AS sys_status,       -- Системный статус (JEST + toro_status_system)
       jt.stus_list   AS user_status,      -- Пользовательский статус (JEST + toro_status_user)
       a.auart        AS order_type,       -- Вид заказа (AUFK-AUART)
       a.gstrp        AS plan_start_date,  -- План начала (AUFK-GSTRP)
       a.gltrp        AS plan_end_date,    -- План завершения (AUFK-GLTRP)
       a.gstri        AS fact_start_date,  -- Факт начала (AUFK-GSTRI)
       a.getri        AS fact_end_date,    -- Факт завершения (AUFK-GETRI)
       NULL::date     AS confirm_date,     -- В AUFK/AFVC аналога нет
       NULL::time     AS confirm_time,     -- В AUFK/AFVC аналога нет
       a.gsuzi        AS fact_start_time,  -- Время начала (AUFK-GSUZI)
       a.geuzi        AS fact_end_time,    -- Время завершения (AUFK-GEUZI)
       NULL::text     AS do_code,          -- В AUFK/AFVC аналога нет
       afvc_sum.netpr AS mvz_sum,          -- Сумма по операциям (AFVC-NETPR, без НДС)
       CASE WHEN a.kostl IS NULL THEN 'NOVALUE' ELSE a.kostl END AS mvz_code, -- МВЗ_код (AUFK-KOSTL)
       a.erdat        AS entry_date,       -- Дата ввода (AUFK-ERDAT)
       a.ktext        AS short_text        -- Краткий текст (AUFK-KTEXT)
FROM dp_rid_ods_corp_torobrd_src.aufk a
LEFT JOIN jt ON jt.objnr = a.objnr
LEFT JOIN (
    SELECT aufnr, SUM(netpr) AS netpr
    FROM dp_rid_ods_corp_torobrd_src.afvc
    GROUP BY aufnr
) afvc_sum ON afvc_sum.aufnr = a.aufnr
where a.aufnr='0000'; -- Убрать фильтр для переключения источника данных

-- v_src_orders (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919540)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders IS 'Очищенные и типизированные заказы ТОРО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."order_num" IS 'Заказ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."sys_status" IS 'Системный статус';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."user_status" IS 'Пользовательский статус заказа';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."order_type" IS 'Вид заказа';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."plan_start_date" IS 'Дата начала выполнения (план)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."plan_end_date" IS 'Дата завершения выполнения (план)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."fact_start_date" IS 'Дата начала выполнения (факт)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."fact_end_date" IS 'Дата завершения выполнения (факт)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."confirm_date" IS 'Дата подтверждения';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."confirm_time" IS 'Время подтверждения';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."fact_start_time" IS 'Время начала выполнения (факт)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."fact_end_time" IS 'Время завершения выполнения (факт)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."do_code" IS '_DO';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."mvz_sum" IS 'МВЗ_сумма';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."mvz_code" IS 'МВЗ_код';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."entry_date" IS 'Дата ввода заказа';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_orders."short_text" IS 'Краткий текст';

