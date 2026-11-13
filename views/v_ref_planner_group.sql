-- [Ref_ГП] (02-07.Model.RefGP)
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_planner_group AS
SELECT btrim(planner_group)                 AS planner_group,  -- Группа плановиков
       btrim(pg_abbr)                       AS pg_abbr,        -- Группа плановиков (сокр.)
       btrim(pg_text)                       AS pg_sort_text,   -- Группа плановиков сорт (текст)
       floor(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(pg_sort))::int      AS pg_sort_num     -- Группа плановиков сорт (число)
FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_planner_group
union all -- Источник СИД КСУ НСИ
SELECT  btrim(id_nsi)                                                 AS planner_group,  -- Группа плановиков
       btrim(id_nsi)                                                  AS pg_abbr,        -- Группа плановиков (сокр.)
       btrim(name)                                                 AS pg_sort_text,   -- Группа плановиков сорт (текст)
       floor(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(id_nsi))::int
                                                                      AS pg_sort_num     -- Группа плановиков сорт (число)
FROM dp_rid_ods_corp_ksunsiups_nsi.toro_planners_groups
WHERE is_blocked = false
  AND is_deleted_insource = false and id_nsi='0000'; -- Убрать фильтр для переключения источника данных

-- v_ref_planner_group (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919606)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_planner_group IS 'Справочник групп плановиков';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_planner_group."planner_group" IS 'Группа плановиков';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_planner_group."pg_abbr" IS 'Группа плановиков (сокр.)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_planner_group."pg_sort_text" IS 'Группа плановиков сорт';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_planner_group."pg_sort_num" IS 'Группа плановиков сорт';
