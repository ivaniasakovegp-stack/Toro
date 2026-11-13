-- [ТаблицаВиртТехместо]
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_virtual_fl AS
SELECT DISTINCT func_location FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_virtual_fl WHERE func_location IS NOT null
union all -- Источник СИД КСУ НСИ
SELECT DISTINCT
    tp.id_nsi::text AS func_location
FROM dp_rid_ods_corp_ksunsiups_nsi.toro_techplaces tp
WHERE tp.id_nsi IS NOT null and id_nsi='0000'; -- Убрать фильтр для переключения источника данных
-- v_ref_virtual_fl (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919646)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_virtual_fl IS 'Перечень виртуальных технических мест';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_virtual_fl."func_location" IS 'Техническое место';

