/* =====================================================================
   05_dm_dashboard_toro_eo_ext.sql — ЕО.Расширенная (02-05.Model.ЕО_расшир): простои ЕО по месяцам и КТГ
   Источник логики: Code/04.04 - ЕО.Расширенная
   Зависимости: dm_dashboard_toro_messages, dm_dashboard_toro_eo, v_src_eo_oper_time, v_ref_eo_type_tracked, dm_dashboard_toro_etl_dim_day

   Алгоритм (CTE в одном запросе, без промежуточных таблиц):
     iv   — интервалы работ: факт. начало/окончание заказов по сообщениям (кроме ВидРабТОРО = 'SRV')
            + интервалы «Часы в нерабочем состоянии» из времени эксплуатации;
     isl  — склейка пересекающихся интервалов по ЕО (gaps & islands);
     dh   — разворот по дням (часы в день, не более 24) без ЕО в статусах
            Бездействие/На консервации/Проектируемый/Списано/Строительство;
     mh   — часы простоя по месяцам с 01.01.2022;
     top  — ЕО отслеживаемых видов (ТОП-10): сетка месяцев 2022-01..текущий и КТГ
            КТГ = (24*дней - часы) / (24*дней); если КПЭ_6-Bi = 0 -> 0;
     итог — mh FULL JOIN top + атрибуты ЕО + ключ ЕО.Расш.Ключ.
   ===================================================================== */

DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext (
    eo_ext_key        bigint,   -- ЕО.Расш.Ключ
    equipment         text,     -- Единица оборудования
    month_start       date,     -- Первый день месяца выполнения заказа
    work_hours_month  numeric,  -- Длительность работ в месяц — часы
    ktg               numeric,  -- КТГ — только для ЕО отслеживаемых видов
    do_code           text,     -- ДО
    planner_group     text,     -- Группа плановиков
    resp_workcenter   text      -- КодОРМ
)
WITH (appendonly=true, orientation=column, compresstype=zlib, compresslevel=1)
DISTRIBUTED BY (equipment);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext IS 'Простои ЕО по месяцам и КТГ. Qlik: таблица [ЕО.Расширенная] (поля с префиксом ЕО.Ext.), 02-05.Model.ЕО_расшир.qvd';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext.eo_ext_key IS 'Qlik: [ЕО.Расш.Ключ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext.equipment IS 'Qlik: [Единица оборудования]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext.month_start IS 'Qlik: [ЕО.Ext.Первый день месяца выполнения заказа]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext.work_hours_month IS 'Qlik: [ЕО.Ext.Длительность работ в месяц] — часы';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext.ktg IS 'Qlik: [ЕО.Ext.КТГ] — только для ЕО отслеживаемых видов';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext.do_code IS 'Qlik: [ДО]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext.planner_group IS 'Qlik: [Группа плановиков]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext.resp_workcenter IS 'Qlik: [ЕО.Ext.КодОРМ]';
