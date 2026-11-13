

-- [Шкала оценки RAV] (inline)
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_rav_scale AS
SELECT * FROM (VALUES
    ('Лучшие 4-го квартиля'::text, 9.1::numeric), ('Середина 3-го квартиля', 7.8), ('Лучшие 3-го квартиля', 6.5),
    ('Середина 2-го квартиля', 5.0), ('Лучшие 2-го квартиля', 3.5), ('Середина 1-го квартиля', 2.5),
    ('Лучшие 1-го квартиля', 0.9)) v (scale_name, rav_pct);
-- v_ref_rav_scale (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919648)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_rav_scale IS 'Шкала оценки RAV (константы)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_rav_scale."scale_name" IS 'Шкала%RAV';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_rav_scale."rav_pct" IS '%RAV';
