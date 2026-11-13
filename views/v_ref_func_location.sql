-- [ТаблицаТехместо.temp] (5УР_ТМ), дубли отбрасываются
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location AS
(SELECT DISTINCT ON (func_location) func_location, fl_name
FROM (SELECT btrim(func_location) AS func_location, btrim(fl_name) AS fl_name, src_row
      FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_func_location) s
WHERE func_location IS NOT null
ORDER BY func_location, src_row)
union all -- Источник СИД КСУ НСИ
(SELECT DISTINCT ON (func_location) func_location, fl_name
FROM (SELECT btrim(id_nsi) AS func_location, btrim(name) AS fl_name, update_datetime
      FROM dp_rid_ods_corp_ksunsiups_nsi.toro_techplaces) s
WHERE func_location IS NOT null and func_location='0000' -- Убрать фильтр для переключения источника данных
ORDER BY func_location, update_datetime desc);
-- v_ref_func_location (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919632)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location IS 'Справочник технических мест 5 уровня';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location."func_location" IS 'Техническое место';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_func_location."fl_name" IS 'Название технического места';