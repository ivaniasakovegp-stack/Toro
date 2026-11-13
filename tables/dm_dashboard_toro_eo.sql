/* =====================================================================
   04_dm_dashboard_toro_eo.sql — Единицы оборудования (02-04.Model.ЕО.qvd)
   Источник логики: Code/02.03 ЕО, Code/04.03 ЕО, [ЕО.Count]
   Зависимости: v_src_eo, v_ref_*, v_calc_oper_time_mrp / v_calc_oper_time_mtbr
   ===================================================================== */

DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo (
    equipment             text,     -- Единица оборудования
    in_operation_from     date,     -- Дата начала эксплуатации
    func_location         text,     -- Техническое место
    planner_group         text,     -- Группа плановиков
    do_code               text,     -- ДО
    eo_class              text,     -- Класс
    eo_status             text,     -- Статус ЕО
    maint_strategy        text,     -- Стратегия обслуживания
    eo_type               text,     -- Вид ЕО — RDE0000, если не заполнен
    eo_name               text,     -- Название
    work_env              text,     -- Рабочая среда
    is_active             int,      -- Активно
    strategy_status       text,     -- Статус стратегии — «Запущена» для смежных систем в эксплуатации
    adjacent_system       text,     -- Смежная система
    pressure_vessel       text,     -- Сосуд под давлением
    manufacturer          text,     -- Изготовитель
    mand_data_total       numeric,  -- Кол-во обязат. данных всего
    mand_data_filled      numeric,  -- Кол-во обязат. данных заполн.
    data_total            numeric,  -- Кол-во данных всего
    data_filled           numeric,  -- Кол-во данных заполн.
    chars_total           numeric,  -- Кол-во хар-к всего
    chars_filled          numeric,  -- Кол-во харак заполн.
    checks_total          numeric,  -- Кол-во проверок всего
    checks_passed         numeric,  -- Кол-во проверок заполн.
    resp_workcenter       text,     -- КодОРМ
    kpi6_ktg_bi           int,      -- КПЭ_6-КТГ-ЕО-Bi
    kpi6_ktg_ei           int,      -- КПЭ_6-КТГ-ЕО-Ei
    strategy_short        text,     -- Стратегия обслуживания краткая
    work_env_norm         text,     -- Рабочая среда_совм.
    empty_fields          int,      -- Незаполненные поля
    resp_workcenter_name  text,     -- ОРМ_наименование
    is_virtual_fl         int,      -- Признак вирттехместа
    class_name            text,     -- Наименование класса — «Класс не определен», если нет в классификаторе
    is_class_excluded     text,     -- Признак исключения класса ЕО
    eo_type_descr         text,     -- Вид ЕО (описание)
    npo_type              text,     -- Виды НПО
    norm_hours            numeric,  -- Нормативное значение, ч.
    tm_level              int,      -- Уровень ТМ
    tm2                   text,     -- Месторождение
    tm3                   text,     -- Объект
    tm4                   text,     -- Оборудование
    tm5                   text,     -- Уровень5
    tm6                   text,     -- Уровень6
    tm2_name              text,     -- Месторождение (описание)
    tm3_name              text,     -- Объект (описание)
    tm4_name              text,     -- Оборудование (описание)
    tm5_name              text,     -- Уровень5 (описание)
    tm6_name              text,     -- Уровень6 (описание)
    strategy_descr        text,     -- ЕО.Стратегия, расшифровка
    oper_time_base        numeric,  -- Наработка_базовая — МРП по ЕО (Code/02.09)
    oper_time_avg         numeric,   -- Наработка_средняя — MTBR (Code/02.09)
    eo_type_top10         int,      -- Признак В списке ТОП Типов
    eo_type_rde03         int       -- Признак Типа ЕО RDE03
)
WITH (appendonly=true, orientation=column, compresstype=zlib, compresslevel=1)
DISTRIBUTED BY (equipment);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo IS 'Единицы оборудования с классификацией, тех. местами, признаками КТГ и наработкой. Qlik: таблица [ЕО] (поля с префиксом ЕО.), 02-04.Model.ЕО.qvd';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.equipment IS 'Qlik: [Единица оборудования]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.in_operation_from IS 'Qlik: [ЕО.Дата начала эксплуатации]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.func_location IS 'Qlik: [ЕО.Техническое место]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.planner_group IS 'Qlik: [Группа плановиков]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.do_code IS 'Qlik: [ДО]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.eo_class IS 'Qlik: [ЕО.Класс]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.eo_status IS 'Qlik: [ЕО.Статус ЕО]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.maint_strategy IS 'Qlik: [ЕО.Стратегия обслуживания]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.eo_type IS 'Qlik: [ЕО.Вид ЕО] — RDE0000, если не заполнен';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.eo_name IS 'Qlik: [ЕО.Название]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.work_env IS 'Qlik: [ЕО.Рабочая среда]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.is_active IS 'Qlik: [ЕО.Активно]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.strategy_status IS 'Qlik: [ЕО.Статус стратегии] — «Запущена» для смежных систем в эксплуатации';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.adjacent_system IS 'Qlik: [ЕО.Смежная система]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.pressure_vessel IS 'Qlik: [ЕО.Сосуд под давлением]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.manufacturer IS 'Qlik: [ЕО.Изготовитель]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.mand_data_total IS 'Qlik: [ЕО.Кол-во обязат. данных всего]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.mand_data_filled IS 'Qlik: [ЕО.Кол-во обязат. данных заполн.]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.data_total IS 'Qlik: [ЕО.Кол-во данных всего]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.data_filled IS 'Qlik: [ЕО.Кол-во данных заполн.]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.chars_total IS 'Qlik: [ЕО.Кол-во хар-к всего]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.chars_filled IS 'Qlik: [ЕО.Кол-во харак заполн.]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.checks_total IS 'Qlik: [ЕО.Кол-во проверок всего]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.checks_passed IS 'Qlik: [ЕО.Кол-во проверок заполн.]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.resp_workcenter IS 'Qlik: [ЕО.КодОРМ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.kpi6_ktg_bi IS 'Qlik: [ЕО.КПЭ_6-КТГ-ЕО-Bi]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.kpi6_ktg_ei IS 'Qlik: [ЕО.КПЭ_6-КТГ-ЕО-Ei]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.strategy_short IS 'Qlik: [ЕО.Стратегия обслуживания краткая]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.work_env_norm IS 'Qlik: [ЕО.Рабочая среда_совм.]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.empty_fields IS 'Qlik: [ЕО.Незаполненные поля]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.resp_workcenter_name IS 'Qlik: [ЕО.ОРМ_наименование]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.is_virtual_fl IS 'Qlik: [ЕО.Признак вирттехместа]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.class_name IS 'Qlik: [ЕО.Наименование класса] — «Класс не определен», если нет в классификаторе';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.is_class_excluded IS 'Qlik: [ЕО.Признак исключения класса ЕО]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.eo_type_descr IS 'Qlik: [ЕО.Вид ЕО (описание)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.npo_type IS 'Qlik: [ЕО.Виды НПО]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.norm_hours IS 'Qlik: [ЕО.Нормативное значение, ч.]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.tm_level IS 'Qlik: [ЕО.Уровень ТМ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.tm2 IS 'Qlik: [ЕО.Месторождение]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.tm3 IS 'Qlik: [ЕО.Объект]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.tm4 IS 'Qlik: [ЕО.Оборудование]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.tm5 IS 'Qlik: [ЕО.Уровень5]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.tm6 IS 'Qlik: [ЕО.Уровень6]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.tm2_name IS 'Qlik: [ЕО.Месторождение (описание)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.tm3_name IS 'Qlik: [ЕО.Объект (описание)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.tm4_name IS 'Qlik: [ЕО.Оборудование (описание)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.tm5_name IS 'Qlik: [ЕО.Уровень5 (описание)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.tm6_name IS 'Qlik: [ЕО.Уровень6 (описание)]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.strategy_descr IS 'Qlik: [ЕО.ЕО.Стратегия, расшифровка]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.oper_time_base IS 'Qlik: [ЕО.Наработка_базовая] — МРП по ЕО (Code/02.09)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.oper_time_avg IS 'Qlik: [ЕО.Наработка_средняя] — MTBR (Code/02.09)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.eo_type_top10 IS 'Признак В списке ТОП Типов';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo.eo_type_rde03 IS 'Признак Типа ЕО RDE03';
