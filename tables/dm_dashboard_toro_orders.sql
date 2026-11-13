/* =====================================================================
   03_dm_dashboard_toro_orders_messages.sql — Заказы и Сообщения (итоговые таблицы)
   Источник логики:
     Code/02.01 Заказы, 02.02 Сообщения             — базовые признаки
     Code/04.01.01 Сообщения1                         — КПЭ 10/11/14/15_17/28/32, тех. места
     Code/04.01.02 Сообщения2                         — "Кол-во для D"
     Code/04.02 Заказы                                — Σ трудозатрат, вид заказа, МВЗ
     Code/04.01.03 Сообщения3                         — тип исполнителя, разнесение затрат, ОРМ исполнителей

   Порядок: f_orders -> f_messages
   (04.01.03 использует [Работа фактическая(ч)] заказа из 04.02, поэтому заказы считаются первыми;
    Σ трудозатрат по заказу берётся из v_src_messages — те же строки, что и [Сообщ.temp] в Qlik)

   Обозначения условий (в CTE b):
     c_a = WildMatch([Системный статус сообщения], '*УДАЛ*', '*МТКУ*')
     c_b = WildMatch([Системный статус] (заказа),  '*НЕВЫ*', '*МТКУ*')
     c_c = WildMatch([Пользовательский статус сообщения], '*УДАЛ*', '*НЕВЫ*')
     c_p = WildMatch([Пользовательский статус сообщения], '*ПДТВ*')
   Приоритет операторов как в Qlik/SQL: AND сильнее OR,
   т.е. "A or B or C or IsNull(факт) and not P" = A OR B OR C OR (факт IS NULL AND NOT P).
   ===================================================================== */

/* ---------- Заказы (Code/02.01 + 04.02) ---------- */
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders (
    order_num               text,     -- Заказ
    sys_status              text,     -- Системный статус
    user_status             text,     -- Пользовательский статус заказа
    order_type              text,     -- Вид заказа
    plan_start_date         date,     -- Дата начала выполнения (план)
    plan_end_date           date,     -- Дата завершения выполнения (план)
    fact_start_date         date,     -- Дата начала выполнения (факт)
    fact_end_date           date,     -- Дата завершения выполнения (факт)
    confirm_date            date,     -- Дата подтверждения
    confirm_time            time,     -- Время подтверждения
    fact_start_time         time,     -- Время начала выполнения (факт)
    fact_end_time           time,     -- Время завершения выполнения (факт)
    do_code                 text,     -- _DO
    mvz_sum                 numeric,  -- МВЗ_сумма
    mvz_code                text,     -- МВЗ_код
    entry_date              date,     -- Дата ввода заказа
    short_text              text,     -- Краткий текст
    closed_in_time          int,      -- Закрыт в срок — 1 / NULL
    closed                  int,      -- Закрытые заказы — 1 / NULL
    not_done                int,      -- Невып. заказы — 1 / NULL
    confirmed               int,      -- Подтв. заказы — 1 / NULL
    kpi12_confirmed         int,      -- КПЭ_12.Подтв. заказы — 1 / NULL
    confirm_duration_h      numeric,  -- Длительность подтверждения заказа(ч)
    kpi29_30_no_materials   int,      -- КПЭ 29-30 Без материалов
    flag_mtku_nev           int,      -- Признак МТКУ/НЕВ
    flag_sgm                int,      -- СГМ в заказе
    work_fact_h             numeric,  -- Работа фактическая(ч) — Σ по сообщениям заказа (Code/04.02)
    work_plan_h             numeric,  -- Работа плановая(ч) — Σ по сообщениям заказа (Code/04.02)
    order_type_text         text,     -- Вид заказа текст
    order_work_kind         text,     -- Вид заказа - тип работ
    mvz_name                text,      -- МВЗ_Название
    sys_status_not          int,       -- Признак системного статуса МТКУ НЕВЫ
    user_status_not_sgm     int        -- Признак пользовательского статуса СГМ
)
WITH (appendonly=true, orientation=column, compresstype=zlib, compresslevel=1)
DISTRIBUTED BY (order_num);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders IS 'Заказы ТОРО с признаками выполнения/подтверждения, трудозатратами и МВЗ. Qlik: таблица [Заказы] (Loader 01-01.Extract.ТОРО.Заказы.qvd; Code/02.01, 04.02)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.order_num IS 'Qlik: [Заказ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.sys_status IS 'Qlik: [Заказы.Системный статус]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.user_status IS 'Qlik: [Заказы.Пользовательский статус заказа]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.order_type IS 'Qlik: [Заказы.Вид заказа]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.plan_start_date IS 'Qlik: [Заказы.Дата начала выполнения (план)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.plan_end_date IS 'Qlik: [Заказы.Дата завершения выполнения (план)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.fact_start_date IS 'Qlik: [Заказы.Дата начала выполнения (факт)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.fact_end_date IS 'Qlik: [Заказы.Дата завершения выполнения (факт)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.confirm_date IS 'Qlik: [Заказы.Дата подтверждения]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.confirm_time IS 'Qlik: [Заказы.Время подтверждения]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.fact_start_time IS 'Qlik: [Заказы.Время начала выполнения (факт)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.fact_end_time IS 'Qlik: [Заказы.Время завершения выполнения (факт)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.do_code IS 'Qlik: [Заказы._DO]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.mvz_sum IS 'Qlik: [Заказы.МВЗ_сумма]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.mvz_code IS 'Qlik: [Заказы.МВЗ_код]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.entry_date IS 'Qlik: [Заказы.Дата ввода заказа]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.short_text IS 'Qlik: [Заказы.Краткий текст]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.closed_in_time IS 'Qlik: [Заказы.Закрыт в срок] — 1 / NULL';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.closed IS 'Qlik: [Заказы.Закрытые заказы] — 1 / NULL';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.not_done IS 'Qlik: [Заказы.Невып. заказы] — 1 / NULL';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.confirmed IS 'Qlik: [Заказы.Подтв. заказы] — 1 / NULL';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.kpi12_confirmed IS 'Qlik: [Заказы.КПЭ_12.Подтв. заказы] — 1 / NULL';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.confirm_duration_h IS 'Qlik: [Заказы.Длительность подтверждения заказа(ч)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.kpi29_30_no_materials IS 'Qlik: [Заказы.КПЭ 29-30 Без материалов]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.flag_mtku_nev IS 'Qlik: [Заказы.Признак МТКУ/НЕВ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.flag_sgm IS 'Qlik: [Заказы.СГМ в заказе]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.work_fact_h IS 'Qlik: [Заказы.Работа фактическая(ч)] — Σ по сообщениям заказа (Code/04.02)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.work_plan_h IS 'Qlik: [Заказы.Работа плановая(ч)] — Σ по сообщениям заказа (Code/04.02)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.order_type_text IS 'Qlik: [Заказы.Вид заказа текст]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.order_work_kind IS 'Qlik: [Заказы.Вид заказа - тип работ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.mvz_name IS 'Qlik: [Заказы.МВЗ_Название]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.sys_status_not IS 'Признак системного статуса МТКУ НЕВЫ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_orders.user_status_not_sgm IS 'Признак пользовательского статуса СГМ';
