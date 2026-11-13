
-- 01-07.Extract.ТОРО.Наработка   (Loader/02.07)
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_oper_time AS
SELECT equipment,                                   -- Единица оборудования
       meas_point,                                  -- Точка измерений
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(meas_date)      AS meas_date,      -- Дата измерений
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_tm(meas_moment)    AS meas_moment,    -- Момент измерений
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(counter_value) AS counter_value,  -- Показания счетчика
       point_name                                   -- Название точки измерений
FROM dp_rid_ods_corp_dfs_dashboard_toro.oper_time
union all -- данные из Источника SAP ТОРО, КСУ НСИ
SELECT eo.inventory_number                    AS equipment,      -- Единица оборудования (инв. номер)
       mp.id_nsi                              AS meas_point,     -- Точка измерений (ВЭ)
       i.idate                                AS change_date,    -- Дата изменения ВЭ
       i.itime                                AS meas_moment,    -- Момент измерений ВЭ
       i.cntrr::numeric                        AS counter_value,  -- Показания счетчика ВЭ
       mp.name                                AS point_name     -- Название точки измерений ВЭ
       --i.cdiff::numeric                        AS counter_diff   -- Разница ПоказанСчетчик ВЭ
FROM dp_rid_ods_corp_torobrd_src.imrg i
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_equipments eo
       ON eo.guid::text= i.equnr_guid
      AND eo.is_blocked = false
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_measurement_points mp
       ON mp.guid::text= i.point_guid
      AND mp.is_deleted = false
WHERE i.lvorm <> 'X' 
		and i.equnr_guid='X' -- Убрать для переключения источника  
		AND i.cancl <> 'X';
-- v_src_oper_time (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919557)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_oper_time IS 'Показания наработки ЕО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_oper_time."equipment" IS 'Единица оборудования';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_oper_time."meas_point" IS 'Точка измерений';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_oper_time."meas_date" IS 'Дата измерений';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_oper_time."meas_moment" IS 'Момент измерений';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_oper_time."counter_value" IS 'Показания счетчика';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_oper_time."point_name" IS 'Название точки измерений';
