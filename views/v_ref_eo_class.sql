-- [EO.Class.temp]: классификатор + признак исключения; дубли кодов отбрасываются
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_class AS
WITH root AS (
    -- корневые уровни: без родителя либо с родителем, отсутствующим в таблице
    SELECT btrim(id_nsi) AS class_code,
           btrim(name)   AS class_name
    FROM dp_rid_ods_corp_ksunsiups_nsi.toro_classifiers
    WHERE id_nsi IS NOT NULL
      AND (parent_id IS NULL
           OR btrim(parent_id) = ''
           OR btrim(parent_id) NOT IN (SELECT btrim(id_nsi)
                                       FROM dp_rid_ods_corp_ksunsiups_nsi.toro_classifiers)))
-- Источник DFS                                       
(SELECT DISTINCT ON (c.class_code)
       c.class_code,                                    -- Класс
       c.class_name,                                    -- Наименование класса
       c.class_full_name,                               -- Полное наименование класса
       c.level_num,                                     -- № уровня
       c.parent_class_code,                             -- Код вышестоящего класса
       CASE WHEN x.class_code IS NOT NULL THEN '1' ELSE '0' END AS is_excluded  -- Признак исключения класса ЕО
FROM (SELECT btrim(class_code) AS class_code, btrim(class_name_40) AS class_name,
             btrim(class_full_name) AS class_full_name, level_num,
             btrim(parent_class_code) AS parent_class_code, src_row
      FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_eo_class) c
LEFT JOIN (SELECT DISTINCT btrim(class_code) AS class_code FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_eo_class_excluded) x
       ON x.class_code = c.class_code
WHERE c.class_code IS NOT NULL
ORDER BY c.class_code, c.src_row)
union all -- Источник КСУ НСИ
SELECT DISTINCT
       class_code,       -- Класс
       class_name,       -- Наименование класса
       class_full_name,  -- Полное наименование класса
       level_num,        -- № уровня
       parent_class_code,-- Код вышестоящего класса
       '0'::text AS is_excluded  -- Признак исключения класса ЕО
FROM (
    -- уровень 1
    SELECT r.class_code,
           r.class_name,
           r.class_name AS class_full_name,
           '1' AS level_num,
           NULL::text AS parent_class_code
    FROM root r
    UNION ALL
    -- уровень 2
    SELECT btrim(c.id_nsi),
           btrim(c.name),
           r.class_name || ' / ' || btrim(c.name),
           '2',
           r.class_code
    FROM dp_rid_ods_corp_ksunsiups_nsi.toro_classifiers c
    JOIN root r
      ON r.class_code = btrim(c.parent_id)
    WHERE c.id_nsi IS NOT NULL
    UNION ALL
    -- уровень 3
    SELECT btrim(c.id_nsi),
           btrim(c.name),
           r.class_name || ' / ' || btrim(p.name) || ' / ' || btrim(c.name),
           '3',
           btrim(p.id_nsi)
    FROM dp_rid_ods_corp_ksunsiups_nsi.toro_classifiers c
    JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_classifiers p
      ON btrim(p.id_nsi) = btrim(c.parent_id)
    JOIN root r
      ON r.class_code = btrim(p.parent_id)
    WHERE c.id_nsi IS NOT NULL
    UNION ALL
    -- уровень 4
    SELECT btrim(c.id_nsi),
           btrim(c.name),
           r.class_name || ' / ' || btrim(gp.name) || ' / ' || btrim(p.name) || ' / ' || btrim(c.name),
           '4',
           btrim(p.id_nsi)
    FROM dp_rid_ods_corp_ksunsiups_nsi.toro_classifiers c
    JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_classifiers p
      ON btrim(p.id_nsi) = btrim(c.parent_id)
    JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_classifiers gp
      ON btrim(gp.id_nsi) = btrim(p.parent_id)
    JOIN root r
      ON r.class_code = btrim(gp.parent_id)
    WHERE c.id_nsi IS NOT NULL
) t where class_code='0000'; -- Убрать фильтр для переключения источника данных;
-- v_ref_eo_class (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919585)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_class IS 'Классификатор ЕО с признаком исключения класса';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_class."class_code" IS 'Класс';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_class."class_name" IS 'Наименование класса';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_class."class_full_name" IS 'Полное наименование класса';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_class."level_num" IS '№ уровня';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_class."parent_class_code" IS 'Код вышестоящего класса';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_class."is_excluded" IS 'Признак исключения класса ЕО';
