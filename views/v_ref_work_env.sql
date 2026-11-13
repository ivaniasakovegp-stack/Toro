

-- [Рабочие среды]
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_work_env AS
SELECT work_env, dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(norm_hours) AS norm_hours FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_work_env;
-- v_ref_work_env (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919626)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_work_env IS 'Нормативы по рабочим средам';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_work_env."work_env" IS 'Рабочая среда';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_work_env."norm_hours" IS 'Нормативное значение, ч.';
