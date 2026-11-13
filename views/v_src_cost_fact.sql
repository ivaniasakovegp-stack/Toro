

-- 01-05.Extract.ТОРО.ЗатратыФакт   (Loader/02.05.02); файл Затраты(мес)_<ДО>_<ММ>_..._<ГГГГ>.xlsx
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact AS
WITH division_qv AS (
    SELECT division, mestorozhdenie, cekh
    FROM dp_rid_ods_corp_openbox_src.spravochniki_ob_division_qvd
    WHERE division IS NOT NULL
    GROUP BY division, mestorozhdenie, cekh
),
account_qv AS (
    SELECT account, account_1
    FROM dp_rid_ods_corp_openbox_src.spravochniki_ob_account_qvd
    WHERE account IS NOT NULL
    GROUP BY account, account_1
),
account_kalk_qv AS (
    SELECT account_kalkulyaciya, account_kalkulyaciya_1
    FROM dp_rid_ods_corp_openbox_src.spravochniki_ob_account_kalkulyaciya_qvd
    WHERE account_kalkulyaciya IS NOT NULL
    GROUP BY account_kalkulyaciya, account_kalkulyaciya_1
),
src AS (
    SELECT qakev.division                                                            AS do_code,
           to_date('20' || right(qakfv.data_ob, 2) || '-' ||
                   (case left(qakfv.data_ob, 3)
                        when 'JAN' then '01' when 'FEB' then '02' when 'MAR' then '03'
                        when 'APR' then '04' when 'MAY' then '05' when 'JUN' then '06'
                        when 'JUL' then '07' when 'AUG' then '08' when 'SEP' then '09'
                        when 'OCT' then '10' when 'NOV' then '11' when 'DEC' then '12'
                   end) || '-01', 'YYYY-MM-DD')                                     AS month_start,
           qakfv.uu                                                                  AS cost_group,
           division_qv.mestorozhdenie                                                AS field_name,
           division_qv.cekh                                                          AS workshop,
           account_qv.account_1                                                      AS account_1,
           account_kalk_qv.account_kalkulyaciya_1                                    AS account_2,
           qakfv.account                                                             AS account,
           qakfv.scenario                                                            AS scenario,
           qakev.value                                                               AS value
    FROM dp_rid_ods_corp_openbox_src.firstdata qakfv
    JOIN dp_rid_ods_corp_openbox_src.enddata qakev ON qakev.uu = qakfv.uu
    LEFT JOIN division_qv     ON division_qv.division           = qakev.division
    LEFT JOIN account_qv      ON account_qv.account             = qakfv.account
    LEFT JOIN account_kalk_qv ON account_kalk_qv.account_kalkulyaciya = qakev.account_ob
    WHERE left(qakfv.data_ob, 3) IN ('JAN','FEB','MAR','APR','MAY','JUN',
                                     'JUL','AUG','SEP','OCT','NOV','DEC')
)
--Источник DFS
SELECT do_code || '|' || dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_mmm_yyyy(m)                     AS cost_fact_key, -- ЗатратыФакт.Ключ
       do_code                                               AS do_code,       -- ДО
       m                                                     AS month_start,   -- Дата на начало месяца
       btrim(cost_group)                                     AS cost_group,    -- Группа затрат
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(field_name), 'Месторождение не указано') AS field_name, -- Месторождение
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(workshop),   'Цех не указан')         AS workshop,      -- Цех
       btrim(account_1)                                      AS account_1,     -- Account 1
       btrim(account_2)                                      AS account_2,     -- Account 2
       btrim(account)                                        AS account,       -- Аккаунт
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(fact) * 1000                               AS cost_fact,     -- Затраты факт, руб
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(plan) * 1000                               AS cost_plan      -- Затраты план, руб
FROM (SELECT s.*,
             dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_file_part(src_file, 2) AS do_code,
             make_date(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_file_part(src_file, -1))::int,
                       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_file_part(src_file, 3))::int, 1) AS m
      FROM dp_rid_ods_corp_dfs_dashboard_toro.cost_month_fact s) s
WHERE dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(account) IS NOT null
union all
-- данные из Источника Open BOX
SELECT do_code || '|' || dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_mmm_yyyy(month_start)      AS cost_fact_key,
       do_code                                                                            AS do_code,
       month_start                                                                        AS month_start,
       btrim(cost_group)                                                                  AS cost_group,
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(field_name), 'Месторождение не указано') AS field_name,
       coalesce(dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(workshop),   'Цех не указан')         AS workshop,
       btrim(account_1)                                                                   AS account_1,
       btrim(account_2)                                                                   AS account_2,
       btrim(account)                                                                     AS account,
       sum(case when scenario ILIKE '%факт%' then value end)                              AS cost_fact,
       sum(case when scenario ILIKE '%план%' then value end)                              AS cost_plan
FROM src
WHERE dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(account) IS NOT null and account='0000' -- Убрать фильтр для переключения источника данных
GROUP BY do_code, month_start, cost_group, field_name, workshop, account_1, account_2, account;
-- v_src_cost_fact (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919551)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact IS 'Факт затрат по месяцам (в рублях), без строк с пустым Account';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact."cost_fact_key" IS 'ЗатратыФакт.Ключ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact."do_code" IS 'ДО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact."month_start" IS 'Дата на начало месяца';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact."cost_group" IS 'Группа затрат';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact."field_name" IS 'Месторождение';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact."workshop" IS 'Цех';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact."account_1" IS 'Account 1';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact."account_2" IS 'Account 2';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact."account" IS 'Аккаунт';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact."cost_fact" IS 'Затраты факт, руб';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact."cost_plan" IS 'Затраты план, руб';
