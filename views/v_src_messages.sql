

-- 01-02.Extract.ТОРО.Сообщ   (Loader/02.02): Load Distinct ... where not isNull([Сообщение])
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages AS
WITH msg_ops AS (
    SELECT aufnr,
           SUM(arbei) AS work_plan_h,   -- arbei — Работа по операции (план)
           --SUM(isrnw) 
           null AS work_fact_h,   -- isrnw — Фактическая работа
           --SUM(isrnw)
           null AS work_fact_h_raw
    FROM dp_rid_ods_corp_torobrd_src.afvc
    GROUP BY aufnr
)
SELECT DISTINCT
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(equipment)                                    AS equipment,           -- Единица оборудования
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(notification)                                 AS notification,        -- Сообщение
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(order_num)                                    AS order_num,           -- Заказ
       notif_type                                           AS notif_type,          -- Вид сообщения
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(req_start)                                 AS req_start_date,      -- Дата начала сообщения (план)
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(req_end)                                   AS req_end_date,        -- Дата завершения сообщения (план)
       btrim(user_status)                                   AS user_status,         -- Пользовательский статус сообщения
       btrim(sys_status)                                    AS sys_status,          -- Системный статус сообщения
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(detection_code), 'NOVALUE')          AS detection_code,      -- Способ обнаружения_код
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(failure_reason_code), 'NOVALUE')     AS failure_reason_code, -- Причина отказа_код
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(work_plan_h)                              AS work_plan_h,         -- Работа плановая(ч)
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(work_fact_h)                              AS work_fact_h,         -- Работа фактическая(ч)
       work_fact_h                                          AS work_fact_h_raw,     -- Работа фактическая(ч)1
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_file_do(src_file)                                AS do_code,             -- _DO
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(created_date)                              AS created_date,        -- Дата создания сообщения
       description                                          AS description,         -- Описание
       func_location                                        AS func_location,       -- Техническое место
       toro_work_type                                       AS toro_work_type,      -- ВидРабТОРО
       -- 21.12.2023: учитывать только сообщения, созданные с 01.08.2023
       CASE WHEN analysis_required = 'X' AND dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(created_date) >= date '2023-08-01' THEN 1 ELSE 0 END
                                                            AS analysis_required,   -- Треб. анализ
       CASE WHEN analysis_done = 'X' AND dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(created_date) >= date '2023-08-01' THEN 1 ELSE 0 END
                                                            AS analysis_done,       -- Проведён
       performer                                            AS performer,           -- Исполнитель
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(equipment_part),      'Не указано')  AS equipment_part,      -- Часть оборудования
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(failure_reason_name), 'Не указано')  AS failure_reason_name, -- Причина отказа_наименование
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(failure_mode_text),   'Не указано')  AS failure_mode_text,   -- Текст вида отказа
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(failure_mechanism),   'Не указано')  AS failure_mechanism,   -- Механизм отказа
       CASE WHEN crit IN ('0001','0002','0003','0004','0005') THEN crit::int ELSE 99 END
                                                            AS failure_crit_code,   -- Критичность отказа код
       CASE WHEN crit IS NULL THEN 'Не указано'
            WHEN crit = '0001' THEN 'Очень высокие риски'
            WHEN crit = '0002' THEN 'Высокие риски'
            WHEN crit = '0003' THEN 'Средние риски'
            WHEN crit = '0004' THEN 'Низкие риски'
            WHEN crit = '0005' THEN 'Очень низкие риски'
            ELSE 'Ошибочное значение' END                   AS failure_crit_name,   -- Критичность отказа наименование
       CASE WHEN crit IS NULL THEN 98
            WHEN crit IN ('0001','0002','0003','0004','0005') THEN crit::int
            ELSE 99 END                                     AS failure_crit_sort,   -- ... (число Dual)
       btrim(resp_workcenter)                               AS resp_workcenter      -- КодОРМ
FROM (SELECT s.*, dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(failure_criticality) AS crit FROM dp_rid_ods_corp_dfs_dashboard_toro.messages s) s
WHERE dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(notification) IS NOT NULL
union all
SELECT DISTINCT
       eq.object_number                          AS equipment,           -- Единица оборудования (equnr_guid -> toro_equipments.object_number)
       qmel.qmnum                                AS notification,        -- Сообщение (qmnum)
       qmel.aufnr                                AS order_num,           -- Заказ (aufnr)
       qmel.qmart                                                                            AS notif_type,          -- Вид сообщения
       qmel.strmn                            AS req_start_date,      -- Дата начала сообщения (план) — начало устранения
       qmel.ltrmn                             AS req_end_date,        -- Дата завершения сообщения (план) — конец устранения
       NULL::text                                                                            AS user_status,         -- Пользовательский статус сообщения (в qmel/afvc нет; в SAP — объект статуса)
       NULL::text                                                                            AS sys_status,          -- Системный статус сообщения (в qmel/afvc нет)
       coalesce(det.id_nsi,  'NOVALUE')          AS detection_code,      -- Способ обнаружения_код (macod_guid -> toro_codes.id_nsi)
       coalesce(frc.id_nsi,  'NOVALUE')          AS failure_reason_code, -- Причина отказа_код (urcod_guid -> toro_codes.id_nsi)
       ops.work_plan_h                                                                       AS work_plan_h,         -- Работа плановая(ч)
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(ops.work_fact_h)                        AS work_fact_h,         -- Работа фактическая(ч)
       ops.work_fact_h_raw                                                                   AS work_fact_h_raw,     -- Работа фактическая(ч)1
       qmel.zzreqid                               AS do_code,             -- _DO — Номер заявки
       qmel.erdat                             AS created_date,        -- Дата создания сообщения
       qmel.qmtxt                                                                            AS description,         -- Описание (текст сообщения)
       tp.id_nsi                                AS func_location,       -- Техническое место (tplnr_guid -> toro_techplaces.id_nsi)
       wt.id_nsi                                AS toro_work_type,      -- ВидРабТОРО (ilart_guid -> toro_codes.id_nsi)
       -- 21.12.2023: учитывать только сообщения, созданные с 01.08.2023
       CASE WHEN qmel.zz_analis = 'X' AND qmel.erdat >= date '2023-08-01' THEN 1 ELSE 0 END
                                                                                    AS analysis_required,   -- Треб. анализ (zz_analis)
       CASE WHEN qmel.zz_done   = 'X' AND qmel.erdat >= date '2023-08-01' THEN 1 ELSE 0 END
                                                                                    AS analysis_done,       -- Проведён (zz_done)
       NULL::text                                                                            AS performer,           -- Исполнитель (в qmel/afvc нет)
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(--qmel.oteil_text
       null),  'Не указано')  AS equipment_part,      -- Часть оборудования
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(--qmel.urcod_text
       null),   'Не указано')  AS failure_reason_name, -- Причина отказа_наименование
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(--qmel.qmcod_text
       null),   'Не указано')  AS failure_mode_text,   -- Текст вида отказа
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(--qmel.fecod_text
       null),   'Не указано')  AS failure_mechanism,   -- Механизм отказа
       CASE WHEN qmel.zzcrtc_fail IN ('0001','0002','0003','0004','0005') THEN qmel.zzcrtc_fail::int ELSE 99 END
                                                                                    AS failure_crit_code,   -- Критичность отказа код (zzcrtc_fail)
       CASE WHEN qmel.zzcrtc_fail IS NULL THEN 'Не указано'
            WHEN qmel.zzcrtc_fail = '0001' THEN 'Очень высокие риски'
            WHEN qmel.zzcrtc_fail = '0002' THEN 'Высокие риски'
            WHEN qmel.zzcrtc_fail = '0003' THEN 'Средние риски'
            WHEN qmel.zzcrtc_fail = '0004' THEN 'Низкие риски'
            WHEN qmel.zzcrtc_fail = '0005' THEN 'Очень низкие риски'
            ELSE 'Ошибочное значение' END              AS failure_crit_name,   -- Критичность отказа наименование
       CASE WHEN qmel.zzcrtc_fail IS NULL THEN 98
            WHEN qmel.zzcrtc_fail IN ('0001','0002','0003','0004','0005') THEN qmel.zzcrtc_fail::int
            ELSE 99 END                                 AS failure_crit_sort,   -- ... (число Dual)
       btrim(wp.workplace)                                                                       AS resp_workcenter      -- КодОРМ (arbpl_guid -> toro_workplaces.workplace)
FROM (SELECT s.* FROM dp_rid_ods_corp_torobrd_src.qmel s) qmel
LEFT JOIN msg_ops  ops ON ops.aufnr        = qmel.aufnr
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_equipments eq   ON eq.guid::text   = qmel.equnr_guid
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_codes      det  ON det.guid  = qmel.macod_guid   -- Способ обнаружения
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_codes      frc  ON frc.guid  = qmel.urcod_guid   -- Причина отказа
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_techplaces tp   ON tp.guid   = qmel.tplnr_guid
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_codes      wt   ON wt.guid   = qmel.ilart_guid   -- Вид работ ТОРО
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_workplaces wp   ON wp.guid   = qmel.arbpl_guid   -- Ответственное рабочее место
WHERE dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(qmel.qmnum) IS NOT null and qmel.qmnum='0000';-- Убрать фильтр для переключения источника данных
-- v_src_messages (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919542)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages IS 'Очищенные и типизированные сообщения ТОРО (без дублей, без пустого номера)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."equipment" IS 'Единица оборудования';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."notification" IS 'Сообщение';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."order_num" IS 'Заказ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."notif_type" IS 'Вид сообщения';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."req_start_date" IS 'Дата начала сообщения (план)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."req_end_date" IS 'Дата завершения сообщения (план)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."user_status" IS 'Пользовательский статус сообщения';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."sys_status" IS 'Системный статус сообщения';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."detection_code" IS 'Способ обнаружения_код';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."failure_reason_code" IS 'Причина отказа_код';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."work_plan_h" IS 'Работа плановая(ч)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."work_fact_h" IS 'Работа фактическая(ч)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."work_fact_h_raw" IS 'Работа фактическая(ч)1';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."do_code" IS '_DO';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."created_date" IS 'Дата создания сообщения';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."description" IS 'Описание';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."func_location" IS 'Техническое место';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."toro_work_type" IS 'ВидРабТОРО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."analysis_required" IS 'Треб. анализ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."analysis_done" IS 'Проведён';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."performer" IS 'Исполнитель';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."equipment_part" IS 'Часть оборудования';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."failure_reason_name" IS 'Причина отказа_наименование';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."failure_mode_text" IS 'Текст вида отказа';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."failure_mechanism" IS 'Механизм отказа';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."failure_crit_code" IS 'Критичность отказа код';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."failure_crit_name" IS 'Критичность отказа наименование';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."failure_crit_sort" IS 'Критичность отказа наименование';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_messages."resp_workcenter" IS 'КодОРМ';
