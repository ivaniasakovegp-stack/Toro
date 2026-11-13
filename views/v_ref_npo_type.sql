

-- [Виды НПО]: НПО_индекс = Класс & Сосуд; дубли индекса отбрасываются
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_npo_type AS
SELECT DISTINCT ON (npo_index) npo_index, class_code, npo_type, pressure_vessel
FROM (SELECT CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(pressure_vessel) IS NULL THEN class_code
                  ELSE class_code || pressure_vessel END AS npo_index,
             class_code, npo_type, pressure_vessel, src_row
      FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_npo_type) s
ORDER BY npo_index, src_row;

-- v_ref_npo_type (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919589)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_npo_type IS 'Маппинг классов ЕО на виды НПО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_npo_type."npo_index" IS 'НПО_индекс';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_npo_type."class_code" IS 'Класс';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_npo_type."npo_type" IS 'Виды НПО';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_npo_type."pressure_vessel" IS 'Виды НПО - сосуды под давлением';
