-- [Отслеживаемые виды ЕО] (переменная nTopClasses) + описание из классификатора
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_type_tracked AS
with 
root AS (
    -- корневые уровни: без родителя либо с родителем, отсутствующим в таблице
    SELECT btrim(id_nsi) AS class_code,
           btrim(name)   AS class_name
    FROM dp_rid_ods_corp_ksunsiups_nsi.toro_classifiers
    WHERE id_nsi IS NOT NULL
      AND (parent_id IS NULL
           OR btrim(parent_id) = ''
           OR btrim(parent_id) NOT IN (SELECT btrim(id_nsi)
                                       FROM dp_rid_ods_corp_ksunsiups_nsi.toro_classifiers))),
eo_class as -- Аналог v_ref_eo_class
((SELECT DISTINCT ON (c.class_code)
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
) t where class_code='0000' -- Убрать фильтр для переключения источника данных;
)
--Окончание Аналога v_ref_eo_class
SELECT t.eo_type_code,                                  -- Код вида ЕО
       c.class_name AS eo_type_descr                    -- Вид ЕО (описание)
FROM (SELECT DISTINCT btrim(eo_type_code) AS eo_type_code FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_eo_type_tracked) t
LEFT JOIN eo_class c ON c.class_code = t.eo_type_code;
-- v_ref_eo_type_tracked (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919599)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_type_tracked IS 'Отслеживаемые виды ЕО (ТОП-10 для КТГ)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_type_tracked."eo_type_code" IS 'Код вида ЕО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_type_tracked."eo_type_descr" IS 'Вид ЕО (описание)';
