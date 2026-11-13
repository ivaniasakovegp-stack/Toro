

-- 01-08.Extract.ТОРО.ВремяЭкспл   (Loader/02.08)
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo_oper_time AS
SELECT equipment,                                   -- Единица оборудования
       meas_point,                                  -- " ВЭ"
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(meas_date)      AS change_date,    -- Дата изменения ВЭ
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_tm(meas_moment)    AS meas_moment,    -- Момент измерений ВЭ
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(counter_value) AS counter_value,  -- Показания счетчика ВЭ
       point_name,                                  -- Название точки измерений ВЭ
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(counter_diff)  AS counter_diff    -- Разница ПоказанСчетчик ВЭ
FROM dp_rid_ods_corp_dfs_dashboard_toro.eo_oper_time
union all
SELECT eq.name                        AS equipment,      -- Единица оборудования
       i.point_guid                   AS meas_point,     -- " ВЭ" (точка измерений)
       i.aedat                        AS change_date,    -- Дата изменения ВЭ
       i.itime                        AS meas_moment,    -- Момент измерений ВЭ
       i.cntrr::numeric               AS counter_value,  -- Показания счетчика ВЭ
       mp.name                        AS point_name,     -- Название точки измерений ВЭ
       i.cdiff::numeric               AS counter_diff    -- Разница ПоказанСчетчик ВЭ
FROM dp_rid_ods_corp_torobrd_src.imrg i
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_equipments eq
       ON i.equnr_guid = eq.guid::text
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_measurement_points mp
       ON i.point_guid = mp.guid::text
where i.equnr_guid = '0000';-- Убрать для переключения источника       
-- WHERE i.lvorm IS DISTINCT FROM 'X'   -- метка удаления, при необходимости
--   AND i.cancl  = ' '                 -- метка сторно, при необходимости;
-- v_src_eo_oper_time (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919559)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo_oper_time IS 'Показания времени эксплуатации ЕО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo_oper_time."equipment" IS 'Единица оборудования';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo_oper_time."meas_point" IS '«ВЭ» (Точка измерений)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo_oper_time."change_date" IS 'Дата изменения ВЭ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo_oper_time."meas_moment" IS 'Момент измерений ВЭ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo_oper_time."counter_value" IS 'Показания счетчика ВЭ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo_oper_time."point_name" IS 'Название точки измерений ВЭ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo_oper_time."counter_diff" IS 'Разница ПоказанСчетчик ВЭ';
