

-- 01-03.Extract.ТОРО.ЕО   (Loader/02.03)
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo AS
SELECT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(equipment)                                AS equipment,          -- Единица оборудования
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(in_operation_from)                     AS in_operation_from,  -- Дата начала эксплуатации
       func_location                                    AS func_location,      -- Техническое место
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(planner_group), 'NGP')           AS planner_group,      -- Группа плановиков
       planning_plant                                   AS do_code,            -- ДО / _DO
       eo_class                                         AS eo_class,           -- Класс
       status_name                                      AS eo_status,          -- Статус ЕО
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(maint_strategy), '[Не присвоено]') AS maint_strategy,   -- Стратегия обслуживания
       tech_object_type                                 AS eo_type,            -- Вид ЕО
       eo_name                                          AS eo_name,            -- Название
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(work_env), 'Не заполнено')       AS work_env,           -- Рабочая среда
       CASE WHEN ppr_active_flag = 'X' THEN 1 ELSE 0 END AS is_active,         -- Активно
       strategy_status                                  AS strategy_status,    -- Статус стратегии
       adjacent_system                                  AS adjacent_system,    -- Смежная система
       pressure_vessel                                  AS pressure_vessel,    -- Сосуд под давлением
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(manufacturer), 'Не указан')      AS manufacturer,       -- Изготовитель
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(mand_data_total), 0)         AS mand_data_total,    -- Кол-во обязат. данных всего
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(mand_data_filled)                     AS mand_data_filled,   -- Кол-во обязат. данных заполн.
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(data_total)                           AS data_total,         -- Кол-во данных всего
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(data_filled)                          AS data_filled,        -- Кол-во данных заполн.
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(chars_total)                          AS chars_total,        -- Кол-во хар-к всего
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(chars_filled)                         AS chars_filled,       -- Кол-во харак заполн.
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(checks_total)                         AS checks_total,       -- Кол-во проверок всего
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(checks_passed)                        AS checks_passed,      -- Кол-во проверок заполн.
       btrim(resp_workcenter)                           AS resp_workcenter     -- КодОРМ
FROM dp_rid_ods_corp_dfs_dashboard_toro.eo
union all -- данные из Источника SAP ТОРО, КСУ НСИ
SELECT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(e.id_nsi)                                       AS equipment,          -- Единица оборудования (toro_equipments.id_nsi, Код)
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(e."сommissioning_date"::text)                       AS in_operation_from,  -- Дата начала эксплуатации (toro_equipments.сommissioning_date; обрати внимание: в имени колонки кириллическая «с»)
       tp.name                                                                                    AS func_location,      -- Техническое место: TODO — связь ЕО↔техническое место в S2T toro_equipments/toro_equipments_timesegments не описана; до добавления связи — NULL
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(pg.name), 'NGP')                        AS planner_group,      -- Группа плановиков (toro_equipments_timesegments.toro_planners_groups_id → toro_planners_groups.name)
       pl.id_nsi                                                                                  AS do_code,            -- ДО / _DO (toro_equipments_timesegments.toro_plants_id → toro_plants.id_nsi, Код)
       clf.name                                                                                   AS eo_class,           -- Класс (toro_equipments.toro_classifiers_id → toro_classifiers.name)
       st.status                                                                                  AS eo_status,          -- Статус ЕО: TODO — текущий статус объекта для ЕО в S2T не описан (кандидаты: toro_object_statuses / toro_object_statuses_shemes)
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(ms.name), '[Не присвоено]')              AS maint_strategy,     -- Стратегия обслуживания: TODO — ссылка ЕО↔стратегия в S2T не описана (кандидат: toro_strategies)
       tot.name                                                                                   AS eo_type,            -- Вид ЕО (toro_equipments.toro_techobjects_types_id → toro_techobjects_types.name)
       e.name                                                                                     AS eo_name,            -- Название (toro_equipments.name)
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(fe.value), 'Не заполнено')               AS work_env,           -- Рабочая среда: TODO — признак объекта (кандидаты: toro_objects_features/toro_objects_feature_values, имя признака «Рабочая среда»)
       --CASE WHEN eq.flag_active_ppr = 'X' THEN 1 ELSE 0 END                                       
       null AS is_active,          -- Активно (torobrd_src.equi_add.flag_active_ppr)
       --eq.equnr_strat_stat                                                                        
       null AS strategy_status,    -- Статус стратегии (torobrd_src.equi_add.equnr_strat_stat)
       --eq.equnr_strat_intgr                                                                       
       null AS adjacent_system,    -- Смежная система (torobrd_src.equi_add.equnr_strat_intgr)
       pv.value                                                                                   AS pressure_vessel,    -- Сосуд под давлением: TODO — признак объекта (кандидаты: toro_objects_features/toro_objects_feature_values, имя признака «Сосуд под давлением»)
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(e.producer), 'Не указан')                AS manufacturer,       -- Изготовитель (toro_equipments.producer)
       --eq.number_req_data                          
       null AS mand_data_total,    -- Кол-во обязат. данных всего (torobrd_src.equi_add.number_req_data)
       --eq.number_comp_req_data                     
       null AS mand_data_filled,   -- Кол-во обязат. данных заполн. (torobrd_src.equi_add.number_comp_req_data)
       --eq.number_data                              
       null AS data_total,         -- Кол-во данных всего (torobrd_src.equi_add.number_data)
       --eq.number_comp_data                         
       null AS data_filled,        -- Кол-во данных заполн. (torobrd_src.equi_add.number_comp_data)
       --eq.number_charact                           
       null AS chars_total,        -- Кол-во хар-к всего (torobrd_src.equi_add.number_charact)
       --eq.number_comp_charact                      
       null AS chars_filled,       -- Кол-во харак заполн. (torobrd_src.equi_add.number_comp_charact)
       --eq.num_checks                               
       null AS checks_total,       -- Кол-во проверок всего (torobrd_src.equi_add.num_checks)
       --eq.num_comp_checks                          
       null AS checks_passed,      -- Кол-во проверок заполн. (torobrd_src.equi_add.num_comp_checks)
       btrim(ts.workplace_object)                                                                 AS resp_workcenter     -- КодОРМ (toro_equipments_timesegments.workplace_object)
FROM dp_rid_ods_corp_ksunsiups_nsi.toro_equipments e
-- Актуальный сегмент времени ЕО (группа плановиков, завод, рабочее место, техническое место)
LEFT JOIN (
    SELECT parent_id,
           toro_planners_groups_id,
           toro_plants_id,
           workplace_object
    FROM (
        SELECT parent_id,
               toro_planners_groups_id,
               toro_plants_id,
               workplace_object,
               ROW_NUMBER() OVER (PARTITION BY parent_id ORDER BY id_nsi DESC) AS rn
        FROM dp_rid_ods_corp_ksunsiups_nsi.toro_equipments_timesegments
        WHERE (end_date IS NULL OR end_date::date >= CURRENT_DATE)
          AND NOT is_blocked
          AND NOT is_deleted_insource
    ) s
    WHERE s.rn = 1
) ts ON ts.parent_id = e.guid::text
-- Справочники (КСУ НСИ)
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_techobjects_types  tot ON tot.id_nsi = e.toro_techobjects_types_id AND NOT tot.is_blocked
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_classifiers        clf ON clf.id_nsi = e.toro_classifiers_id        
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_planners_groups    pg  ON pg.id_nsi  = ts.toro_planners_groups_id   AND NOT pg.is_blocked
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_plants             pl  ON pl.id_nsi  = ts.toro_plants_id
-- Источник SAP: ТОРО-поля ЕО (активность ППР, статус стратегии, смежная система, счётчики)
--LEFT JOIN dp_rid_ods_corp_torobrd_src.equi_add                  eq  ON eq.equnr   = e.id_nsi Включить после подключения источника 
-- TODO: технические места (func_location) — связь ЕО↔ТМ не описана в S2T; до описания связи — NULL
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_techplaces         tp  ON 1 = 0
-- TODO: статус ЕО (eo_status) — связь ЕО↔статус не описана в S2T; до описания — NULL
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_object_statuses    st  ON 1 = 0
-- TODO: стратегия обслуживания (maint_strategy) — связь ЕО↔стратегия не описана в S2T; до описания — NULL
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_strategies         ms  ON 1 = 0
-- TODO: признаки объектов (work_env, pressure_vessel) — через toro_objects_feature_values после уточнения ключа (id_owner) и имён признаков
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_objects_feature_values fe ON 1 = 0
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_objects_feature_values  pv ON 1 = 0
WHERE NOT e.is_blocked and e.id_nsi='0000' -- убрать после переключения источника
  AND e.id_nsi IS NOT NULL;
-- v_src_eo (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919544)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo IS 'Очищенные и типизированные единицы оборудования';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."equipment" IS 'Единица оборудования';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."in_operation_from" IS 'Дата начала эксплуатации';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."func_location" IS 'Техническое место';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."planner_group" IS 'Группа плановиков';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."do_code" IS 'ДО (= _DO)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."eo_class" IS 'Класс';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."eo_status" IS 'Статус ЕО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."maint_strategy" IS 'Стратегия обслуживания';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."eo_type" IS 'Вид ЕО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."eo_name" IS 'Название';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."work_env" IS 'Рабочая среда';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."is_active" IS 'Активно';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."strategy_status" IS 'Статус стратегии';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."adjacent_system" IS 'Смежная система';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."pressure_vessel" IS 'Сосуд под давлением';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."manufacturer" IS 'Изготовитель';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."mand_data_total" IS 'Кол-во обязат. данных всего';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."mand_data_filled" IS 'Кол-во обязат. данных заполн.';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."data_total" IS 'Кол-во данных всего';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."data_filled" IS 'Кол-во данных заполн.';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."chars_total" IS 'Кол-во хар-к всего';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."chars_filled" IS 'Кол-во харак заполн.';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."checks_total" IS 'Кол-во проверок всего';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."checks_passed" IS 'Кол-во проверок заполн.';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo."resp_workcenter" IS 'КодОРМ';
