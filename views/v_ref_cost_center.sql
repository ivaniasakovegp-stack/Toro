-- [МВЗ]: последняя по дате запись на каждый код + строка NOVALUE
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_cost_center AS
SELECT cost_center, valid_date, cc_name
FROM (SELECT cost_center, dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(valid_date) AS valid_date, cc_name,
             row_number() OVER (PARTITION BY cost_center
                                ORDER BY dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(valid_date) DESC NULLS LAST, src_row) AS rn
      FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_cost_center) s
WHERE rn = 1
UNION ALL
SELECT 'NOVALUE'::text, NULL::date, 'Не определено'::text
union all -- Источник СИД КСУ НСИ
SELECT cost_center, valid_date, cc_name
FROM (SELECT id_nsi::text        AS cost_center,
             end_date::date      AS valid_date,
             name::text          AS cc_name,
             row_number() OVER (PARTITION BY id_nsi
                                ORDER BY end_date::date DESC NULLS LAST) AS rn
      FROM dp_rid_ods_corp_ksunsiups_nsi.sap_costcenters) s
WHERE rn = 1 and cost_center='0000'; -- Убрать фильтр для переключения источника данных
-- v_ref_cost_center (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919620)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_cost_center IS 'Справочник МВЗ: последняя по дате запись на код + строка NOVALUE';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_cost_center."cost_center" IS 'МВЗ_код';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_cost_center."valid_date" IS 'МВЗ_Дата';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_cost_center."cc_name" IS 'МВЗ_Название';
