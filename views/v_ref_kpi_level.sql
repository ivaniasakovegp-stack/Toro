

-- [KPI_Level]: Sheet2 + Concatenate Sheet3 (диапазоны 'a-b')
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_level AS
SELECT kpi_num AS kpi_level, unit,
       CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(low_value)    IS NOT NULL THEN low_value    || coalesce(unit,'') END AS low_limit,
       CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(target_value) IS NOT NULL THEN target_value || coalesce(unit,'') END AS target_limit,
       CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(high_value)   IS NOT NULL THEN high_value   || coalesce(unit,'') END AS high_limit,
       NULL::text AS low_limit_low, NULL::text AS low_limit_high,
       NULL::text AS target_limit_low, NULL::text AS target_limit_high,
       NULL::text AS high_limit_low, NULL::text AS high_limit_high,
       src_sheet
FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_kpi_level0 WHERE src_sheet = 'Sheet2'
UNION ALL
SELECT kpi_num, unit, NULL, NULL, NULL,
       CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(low_value)    IS NOT NULL THEN split_part(low_value,'-',1)    || coalesce(unit,'') END,
       CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(low_value)    IS NOT NULL THEN split_part(low_value,'-',2)    || coalesce(unit,'') END,
       CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(target_value) IS NOT NULL THEN split_part(target_value,'-',1) || coalesce(unit,'') END,
       CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(target_value) IS NOT NULL THEN split_part(target_value,'-',2) || coalesce(unit,'') END,
       CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(high_value)   IS NOT NULL THEN split_part(high_value,'-',1)   || coalesce(unit,'') END,
       CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(high_value)   IS NOT NULL THEN split_part(high_value,'-',2)   || coalesce(unit,'') END,
       src_sheet
FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_kpi_level1 WHERE src_sheet = 'Sheet3';
-- v_ref_kpi_level (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919611)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_level IS 'Пороги эффективности КПЭ (листы Sheet2 и Sheet3)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_level."kpi_level" IS 'KPI_Level';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_level."unit" IS 'Ед.изм_limit';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_level."low_limit" IS 'Low_limit';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_level."target_limit" IS 'Target_limit';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_level."high_limit" IS 'High_limit';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_level."low_limit_low" IS 'Low_limit_low';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_level."low_limit_high" IS 'Low_limit_high';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_level."target_limit_low" IS 'Target_limit_low';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_level."target_limit_high" IS 'Target_limit_high';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_level."high_limit_low" IS 'High_limit_low';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_level."high_limit_high" IS 'High_limit_high';
