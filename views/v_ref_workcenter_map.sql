/* ===================== СПРАВОЧНИКИ ===================== */

-- Mapl_ORM_1: ApplyMap(Завод & КодОРМ) — берётся ПЕРВОЕ вхождение ключа
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_workcenter_map AS
(SELECT DISTINCT ON (map_key) map_key, plant, workcenter_code, workcenter_name
FROM (SELECT coalesce(btrim(plant),'') || coalesce(btrim(workcenter_code),'') AS map_key,
             btrim(plant) AS plant, btrim(workcenter_code) AS workcenter_code,
             btrim(workcenter_name) AS workcenter_name,      -- ОРМ_наименование
             src_file, src_row
      FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_workcenter) s
ORDER BY map_key, src_file, src_row)
union all -- Источник СИД КСУ НСИ
(SELECT DISTINCT ON (map_key) map_key, plant, workcenter_code, workcenter_name
FROM (SELECT coalesce(btrim(p.name), '') || coalesce(btrim(wp.workplace), '') AS map_key,
             btrim(p.name)       AS plant,
             btrim(wp.workplace) AS workcenter_code,
             btrim(wp.name)      AS workcenter_name,      -- ОРМ_наименование
             wp.update_datetime,
             wp.workplace,
             wp.guid          
      FROM dp_rid_ods_corp_ksunsiups_nsi.toro_workplaces wp
      LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_plants p
             ON p.id_nsi = wp.toro_plants_id
     WHERE wp.guid='0000'            -- Убрать фильтр для переключения источника данных
     ) s
ORDER BY map_key, update_datetime DESC NULLS LAST, workplace, guid);
-- v_ref_workcenter_map (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919571)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_workcenter_map IS 'Маппинг «Завод+код рабочего места → наименование ОРМ»';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_workcenter_map."map_key" IS 'КлючОРМ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_workcenter_map."plant" IS 'Завод';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_workcenter_map."workcenter_code" IS 'Код рабочего места';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_workcenter_map."workcenter_name" IS 'ОРМ_наименование';
