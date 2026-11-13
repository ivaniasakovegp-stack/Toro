-- [Дочерние общества]
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_do_company AS
SELECT do_code,                                         -- ДО
       trim(do_full_name) as do_full_name, -- ДО (полное наименование)
       trim(do_short_name) as do_short_name, -- ДО (краткое наименование)
       trim(do_abbr) as do_abbr,                                         -- ДО (сокр.)
       do_color,                                        -- ДО (цвет)
       btrim(do_abbr)                         AS do_sort_text,  -- ДО сорт (текст Dual)
       floor(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(do_sort))::int        AS do_sort_num    -- ДО сорт (число Dual)
FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_do
union all -- Источник СИД КСУ НСИ
SELECT id_nsi                                   AS do_code,      -- ДО
       trim(name)                               AS do_full_name, -- ДО (полное наименование)
       trim(name)                               AS do_short_name,-- ДО (краткое наименование)
       trim(name)                               AS do_abbr,      -- ДО (сокр.)
       NULL::text                               AS do_color,     -- ДО (цвет) — в НСИ отсутствует
       trim(name)                               AS do_sort_text, -- ДО сорт (текст)
       CASE WHEN id_nsi ~ '^[0-9]+$'
            THEN id_nsi::int
            ELSE 0
       END                                      AS do_sort_num   -- ДО сорт (число)
FROM dp_rid_ods_corp_ksunsiups_nsi.toro_plants
where id_nsi='0000'; -- Убрать фильтр для переключения источника данных
-- v_ref_do_company (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919578)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_do_company IS 'Справочник дочерних обществ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_do_company."do_code" IS 'ДО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_do_company."do_full_name" IS 'ДО (полное наименование)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_do_company."do_short_name" IS 'ДО (краткое наименование)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_do_company."do_abbr" IS 'ДО (сокр.)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_do_company."do_color" IS 'ДО (цвет)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_do_company."do_sort_text" IS 'ДО сорт';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_do_company."do_sort_num" IS 'ДО сорт';
