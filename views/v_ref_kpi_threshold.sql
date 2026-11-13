

-- [Threshold]
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_threshold AS
SELECT do_code,                                         -- ДО
       kpi_num             AS kpi_threshold,            -- KPI_Threshold
       target || '%'       AS target,                   -- Цель
       stretch_target || '%' AS stretch_target          -- Напряженная цель
FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_threshold;

-- v_ref_kpi_threshold (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919608)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_threshold IS 'Целевые значения КПЭ по ДО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_threshold."do_code" IS 'ДО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_threshold."kpi_threshold" IS 'KPI_Threshold';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_threshold."target" IS 'Цель';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_kpi_threshold."stretch_target" IS 'Напряженная цель';
