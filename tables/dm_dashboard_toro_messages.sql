



/* ---------- Сообщения (02-06.Model.Сообщения) ---------- */
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages (
    key_ord_note           text,     -- Ключ уникальный Заказ-Сообщение
    equipment              text,     -- Единица оборудования
    notification           text,     -- Сообщение
    order_num              text,     -- Заказ
    notif_type             text,     -- Вид сообщения
    req_start_date         date,     -- Дата начала сообщения (план)
    req_end_date           date,     -- Дата завершения сообщения (план)
    user_status            text,     -- Пользовательский статус сообщения
    sys_status             text,     -- Системный статус сообщения
    detection_code         text,     -- Способ обнаружения_код
    failure_reason_code    text,     -- Причина отказа_код
    work_plan_h            numeric,  -- Работа плановая(ч)
    work_fact_h            numeric,  -- Работа фактическая(ч)
    work_fact_h_raw        text,     -- Работа фактическая(ч)1
    do_code                text,     -- _DO
    created_date           date,     -- Дата создания сообщения
    description            text,     -- Описание
    func_location          text,     -- Техническое место
    toro_work_type         text,     -- ВидРабТОРО
    analysis_required      int,      -- Треб. анализ
    analysis_done          int,      -- Проведён
    performer              text,     -- Исполнитель
    equipment_part         text,     -- Часть оборудования
    failure_reason_name    text,     -- Причина отказа_наименование
    failure_mode_text      text,     -- Текст вида отказа
    failure_mechanism      text,     -- Механизм отказа
    failure_crit_code      int,      -- Критичность отказа код
    failure_crit_name      text,     -- Критичность отказа наименование — текстовая часть Dual
    failure_crit_sort      int,      -- Критичность отказа наименование — числовая часть Dual (сортировка)
    resp_workcenter        text,     -- КодОРМ
    filter_by_create       int,      -- Фильтр по дате создания
    filter_no_mtku         int,      -- Фильтр без МТКУ
    flag_mtku_udal         int,      -- Признак МТКУ/УДАЛ
    detection_method       text,     -- Способ обнаружения
    flag_otm               int,      -- Признак ОТМ
    filter_mtku_2025       int,      -- Фильтр с МТКУ 2025
    work_kind              text,     -- Вид работы
    resp_workcenter_name   text,     -- ОРМ_наименование
    ord_order_num          text,     -- Заказ.temp
    ord_sys_status         text,     -- Системный статус
    ord_fact_end_date      date,     -- Дата завершения выполнения (факт)
    ord_plan_end_date      date,     -- Дата завершения выполнения (план)
    ord_plan_start_date    date,     -- Дата начала выполнения (план)
    ord_fact_start_date    date,     -- Дата начала выполнения (факт)
    ord_fact_start_time    time,     -- Время начала выполнения (факт)
    ord_fact_end_time      time,     -- Время завершения выполнения (факт)
    ord_entry_date         date,     -- Дата ввода заказа
    is_virtual_fl          int,      -- Признак вирттехместа
    kpi11                  text,     -- КПЭ11
    kpi10                  text,     -- КПЭ10
    kpi15_17               text,     -- КПЭ15_17
    kpi15_17_overdue_name  text,     -- КПЭ15_17_Просрочено_оценка — текстовая часть Dual
    kpi15_17_overdue_code  int,      -- КПЭ15_17_Просрочено_оценка код
    kpi15_17_no_mtku       text,     -- КПЭ15_17_БезМТКУ
    kpi28                  int,      -- КПЭ 28
    kpi_x_not_done         int,      -- КПЭ_X_Не выполнено
    kpi14                  int,      -- КПЭ 14
    kpi32_a                int,      -- КПЭ 32_A
    kpi32_b                int,      -- КПЭ 32_B
    kpi32_eadd             int,      -- КПЭ 32_Eadd
    no_order               int,      -- Нет заказа
    notif_type_dssp        text,     -- Вид сообщения ДССП
    kpi11_in_time          int,      -- КПЭ11_В срок
    kpi11_overdue          int,      -- КПЭ11_Просрочено
    kpi10_in_time          int,      -- КПЭ10_В срок
    kpi10_overdue          int,      -- КПЭ10_Просрочено
    kpi15_17_in_time       int,      -- КПЭ15_17_В срок
    kpi15_17_overdue       int,      -- КПЭ15_17_Просрочено
    reason_group           text,     -- Причина отказа_загл
    reason_name            text,     -- Причина отказа
    tm2                    text,     -- Месторождение
    tm3                    text,     -- Объект
    tm4                    text,     -- Оборудование
    tm5                    text,     -- Уровень5
    tm6                    text,     -- Уровень6
    tm2_name               text,     -- Месторождение (описание)
    tm3_name               text,     -- Объект (описание)
    tm4_name               text,     -- Оборудование (описание)
    tm5_name               text,     -- Уровень5 (описание)
    tm6_name               text,     -- Уровень6 (описание)
    drt_drb                int,      -- DRT_DRB
    cnt_for_d              bigint,   -- Кол-во для D
    performer_type         text,     -- Исполнитель_Тип — RDB / RDS / Смешан / Не указан
    work_fact_own_h        numeric,  -- Работа фактическая Собств
    work_fact_contr_h      numeric,  -- Работа фактическая Подряд
    work_fact_unknown_h    numeric,  -- Работа фактическая Не указан
    mvz_sum                numeric,  -- МВЗ_сумма — сумма заказа
    order_work_fact_h      numeric,  -- Заказ.Работа фактическая(ч)
    cost_own               numeric,  -- Затраты_Собств
    cost_contr             numeric,  -- Затраты_Подряд
    cost_unknown           numeric,  -- Затраты_Не указан
    performer_names        text,      -- Исполнитель_Наименование
    sys_status_no_mtku     int, -- Признак системного статуса МТКУ
    user_status_no_udal    int  -- Признак пользовательского статуса УДАЛ
)
WITH (appendonly=true, orientation=column, compresstype=zlib, compresslevel=1)
DISTRIBUTED BY (key_ord_note);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages IS 'Сообщения ТОРО: КПЭ 10/11/14/15_17/28/32, тех. места, «Кол-во для D», исполнители и разнесение затрат. Qlik: таблица [Сообщения] (поля с префиксом Сообщ.), 02-06.Model.Сообщения.qvd';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.key_ord_note IS 'Ключ уникальный Заказ-Сообщение';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.equipment IS 'Qlik: [Единица оборудования]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.notification IS 'Qlik: [Сообщение]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.order_num IS 'Qlik: [Заказ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.notif_type IS 'Qlik: [Сообщ.Вид сообщения]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.req_start_date IS 'Qlik: [Сообщ.Дата начала сообщения (план)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.req_end_date IS 'Qlik: [Сообщ.Дата завершения сообщения (план)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.user_status IS 'Qlik: [Сообщ.Пользовательский статус сообщения]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.sys_status IS 'Qlik: [Сообщ.Системный статус сообщения]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.detection_code IS 'Qlik: [Сообщ.Способ обнаружения_код]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.failure_reason_code IS 'Qlik: [Сообщ.Причина отказа_код]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.work_plan_h IS 'Qlik: [Сообщ.Работа плановая(ч)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.work_fact_h IS 'Qlik: [Сообщ.Работа фактическая(ч)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.work_fact_h_raw IS 'Qlik: [Сообщ.Работа фактическая(ч)1]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.do_code IS 'Qlik: [Сообщ._DO]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.created_date IS 'Qlik: [Сообщ.Дата создания сообщения]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.description IS 'Qlik: [Сообщ.Описание]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.func_location IS 'Qlik: [Сообщ.Техническое место]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.toro_work_type IS 'Qlik: [Сообщ.ВидРабТОРО]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.analysis_required IS 'Qlik: [Сообщ.Треб. анализ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.analysis_done IS 'Qlik: [Сообщ.Проведён]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.performer IS 'Qlik: [Сообщ.Исполнитель]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.equipment_part IS 'Qlik: [Сообщ.Часть оборудования]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.failure_reason_name IS 'Qlik: [Сообщ.Причина отказа_наименование]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.failure_mode_text IS 'Qlik: [Сообщ.Текст вида отказа]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.failure_mechanism IS 'Qlik: [Сообщ.Механизм отказа]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.failure_crit_code IS 'Qlik: [Сообщ.Критичность отказа код]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.failure_crit_name IS 'Qlik: [Сообщ.Критичность отказа наименование] — текстовая часть Dual';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.failure_crit_sort IS 'Qlik: [Сообщ.Критичность отказа наименование] — числовая часть Dual (сортировка)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.resp_workcenter IS 'Qlik: [Сообщ.КодОРМ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.filter_by_create IS 'Qlik: [Сообщ.Фильтр по дате создания]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.filter_no_mtku IS 'Qlik: [Сообщ.Фильтр без МТКУ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.flag_mtku_udal IS 'Qlik: [Сообщ.Признак МТКУ/УДАЛ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.detection_method IS 'Qlik: [Сообщ.Способ обнаружения]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.flag_otm IS 'Qlik: [Сообщ.Признак ОТМ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.filter_mtku_2025 IS 'Qlik: [Сообщ.Фильтр с МТКУ 2025]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.work_kind IS 'Qlik: [Сообщ.Вид работы]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.resp_workcenter_name IS 'Qlik: [Сообщ.ОРМ_наименование]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.ord_order_num IS 'Qlik: [Сообщ.Заказ.temp]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.ord_sys_status IS 'Qlik: [Сообщ.Системный статус]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.ord_fact_end_date IS 'Qlik: [Сообщ.Дата завершения выполнения (факт)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.ord_plan_end_date IS 'Qlik: [Сообщ.Дата завершения выполнения (план)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.ord_plan_start_date IS 'Qlik: [Сообщ.Дата начала выполнения (план)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.ord_fact_start_date IS 'Qlik: [Сообщ.Дата начала выполнения (факт)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.ord_fact_start_time IS 'Qlik: [Сообщ.Время начала выполнения (факт)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.ord_fact_end_time IS 'Qlik: [Сообщ.Время завершения выполнения (факт)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.ord_entry_date IS 'Qlik: [Сообщ.Дата ввода заказа]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.is_virtual_fl IS 'Qlik: [Сообщ.Признак вирттехместа]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi11 IS 'Qlik: [Сообщ.КПЭ11]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi10 IS 'Qlik: [Сообщ.КПЭ10]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi15_17 IS 'Qlik: [Сообщ.КПЭ15_17]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi15_17_overdue_name IS 'Qlik: [Сообщ.КПЭ15_17_Просрочено_оценка] — текстовая часть Dual';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi15_17_overdue_code IS 'Qlik: [Сообщ.КПЭ15_17_Просрочено_оценка код]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi15_17_no_mtku IS 'Qlik: [Сообщ.КПЭ15_17_БезМТКУ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi28 IS 'Qlik: [Сообщ.КПЭ 28]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi_x_not_done IS 'Qlik: [Сообщ.КПЭ_X_Не выполнено]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi14 IS 'Qlik: [Сообщ.КПЭ 14]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi32_a IS 'Qlik: [Сообщ.КПЭ 32_A]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi32_b IS 'Qlik: [Сообщ.КПЭ 32_B]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi32_eadd IS 'Qlik: [Сообщ.КПЭ 32_Eadd]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.no_order IS 'Qlik: [Сообщ.Нет заказа]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.notif_type_dssp IS 'Qlik: [Сообщ.Вид сообщения ДССП]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi11_in_time IS 'Qlik: [Сообщ.КПЭ11_В срок]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi11_overdue IS 'Qlik: [Сообщ.КПЭ11_Просрочено]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi10_in_time IS 'Qlik: [Сообщ.КПЭ10_В срок]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi10_overdue IS 'Qlik: [Сообщ.КПЭ10_Просрочено]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi15_17_in_time IS 'Qlik: [Сообщ.КПЭ15_17_В срок]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.kpi15_17_overdue IS 'Qlik: [Сообщ.КПЭ15_17_Просрочено]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.reason_group IS 'Qlik: [Сообщ.Причина отказа_загл]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.reason_name IS 'Qlik: [Сообщ.Причина отказа]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.tm2 IS 'Qlik: [Сообщ.Месторождение]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.tm3 IS 'Qlik: [Сообщ.Объект]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.tm4 IS 'Qlik: [Сообщ.Оборудование]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.tm5 IS 'Qlik: [Сообщ.Уровень5]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.tm6 IS 'Qlik: [Сообщ.Уровень6]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.tm2_name IS 'Qlik: [Сообщ.Месторождение (описание)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.tm3_name IS 'Qlik: [Сообщ.Объект (описание)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.tm4_name IS 'Qlik: [Сообщ.Оборудование (описание)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.tm5_name IS 'Qlik: [Сообщ.Уровень5 (описание)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.tm6_name IS 'Qlik: [Сообщ.Уровень6 (описание)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.drt_drb IS 'Qlik: [Сообщ.DRT_DRB]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.cnt_for_d IS 'Qlik: [Сообщ.Кол-во для D]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.performer_type IS 'Qlik: [Сообщ.Исполнитель_Тип] — RDB / RDS / Смешан / Не указан';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.work_fact_own_h IS 'Qlik: [Сообщ.Работа фактическая Собств]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.work_fact_contr_h IS 'Qlik: [Сообщ.Работа фактическая Подряд]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.work_fact_unknown_h IS 'Qlik: [Сообщ.Работа фактическая Не указан]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.mvz_sum IS 'Qlik: [Сообщ.МВЗ_сумма] — сумма заказа';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.order_work_fact_h IS 'Qlik: [Сообщ.Заказ.Работа фактическая(ч)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.cost_own IS 'Qlik: [Сообщ.Затраты_Собств]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.cost_contr IS 'Qlik: [Сообщ.Затраты_Подряд]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.cost_unknown IS 'Qlik: [Сообщ.Затраты_Не указан]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.performer_names IS 'Qlik: [Сообщ.Исполнитель_Наименование]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.sys_status_no_mtku IS 'Признак системного статуса МТКУ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages.user_status_no_udal IS 'Признак пользовательского статуса УДАЛ';
