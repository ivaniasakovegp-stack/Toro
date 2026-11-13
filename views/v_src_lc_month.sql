-- 01-06.Extract.ТОРО.Lc   (Loader/02.06.02): FirstSortedValue(x, -NumRow) — последнее непустое значение
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_lc_month AS
WITH scen AS (  -- справочник сценариев: полный сценарий (%Сценарий) -> Сценарий/Год/Месяц
    SELECT s._scenarij,
           min(s.scenarij) AS scenarij,
           min(s.god)::int  AS year_num,
           min(s.mesyac)::int AS month_num
    FROM dp_rid_ods_corp_openbox_src.spravochniki_ob_scenarij_qvd s
    WHERE s.scenarij LIKE 'План%' OR s.scenarij LIKE 'Факт%'
    GROUP BY s._scenarij
),
fd AS (  -- первичные данные, только денежные строки
    SELECT f.division_first, f.uu, f.value,
           sc.scenarij, sc.year_num, sc.month_num
    FROM dp_rid_ods_corp_openbox_src.firstdata f
    JOIN scen sc ON sc._scenarij = concat(f.version, '__', f.scenario, '__', f.data_ob)
    WHERE f.priznak_dengi = '1'
),
do_ref AS (  -- справочник division (допустимые ДО)
    SELECT division FROM dp_rid_ods_corp_openbox_src.spravochniki_ob_division_qvd
),
plan_agg AS (
    SELECT r.division AS do_code,
           make_date(fd.year_num, fd.month_num, 1) AS month_start,
           sum(fd.value) AS lc_plan
    FROM fd
    JOIN do_ref r ON r.division = fd.division_first
    WHERE fd.scenarij LIKE 'План%'
    GROUP BY r.division, fd.year_num, fd.month_num
),
fact_agg AS (
    SELECT r.division AS do_code,
           make_date(fd.year_num, fd.month_num, 1) AS month_start,
           sum(e.value) AS lc_fact
    FROM dp_rid_ods_corp_openbox_src.enddata e
    JOIN fd ON fd.uu = e.uu
    JOIN do_ref r ON r.division = fd.division_first
    WHERE fd.scenarij LIKE 'Факт%'
    GROUP BY r.division, fd.year_num, fd.month_num
)
--Источник DFS
SELECT lc_key, do_code, month_start,
       (array_agg(lc_plan ORDER BY (lc_plan IS NULL), src_file DESC, src_row DESC))[1] AS lc_plan, -- Значение LC план, руб.
       (array_agg(lc_fact ORDER BY (lc_fact IS NULL), src_file DESC, src_row DESC))[1] AS lc_fact  -- Значение LC факт, руб.
FROM (SELECT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_file_part(src_file, 2) || '|' || dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_mmm_yyyy(m) AS lc_key,   -- LC.Ключ
             dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_file_part(src_file, 2)                           AS do_code,  -- ДО
             m                                                    AS month_start,
             dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(plan) * 1000                              AS lc_plan,
             dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(fact) * 1000                              AS lc_fact,
             src_file, src_row
      FROM (SELECT s.*, make_date(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(year_num)::int, dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(month_num)::int, 1) AS m
            FROM dp_rid_ods_corp_dfs_dashboard_toro.lc_month s
            WHERE dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(year_num) IS NOT NULL) s) t
GROUP BY lc_key, do_code, month_start
-- данные из Источника Open BOX
union all
SELECT COALESCE(p.do_code, f.do_code) || '|' || dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_mmm_yyyy(COALESCE(p.month_start, f.month_start)) AS lc_key,  -- LC.Ключ
       COALESCE(p.do_code, f.do_code)                    AS do_code,     -- ДО
       COALESCE(p.month_start, f.month_start)            AS month_start, -- Дата на начало месяца
       p.lc_plan,                                                                     -- Значение LC план, руб.
       f.lc_fact                                                                      -- Значение LC факт, руб.
FROM plan_agg p 
FULL OUTER JOIN fact_agg f USING (do_code, month_start)
where p.do_code='0000'; -- Убрать фильтр для переключения источника данных
-- v_src_lc_month (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919554)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_lc_month IS 'LC помесячно (в рублях), одна строка на ДО и месяц';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_lc_month."lc_key" IS 'LC.Ключ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_lc_month."do_code" IS 'ДО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_lc_month."month_start" IS 'Дата на начало месяца';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_lc_month."lc_plan" IS 'Значение LC план, руб.';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_lc_month."lc_fact" IS 'Значение LC факт, руб.';
