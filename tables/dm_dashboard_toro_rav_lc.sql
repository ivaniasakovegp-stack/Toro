

-- [RavLc]
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_lc;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_lc (
    rav_lc_key text,     -- RavLc.Ключ — ДО|Год
    rav_value  numeric,  -- Значение_RAV — исходное значение × 1000
    lc_value   numeric,  -- Значение_LC — исходное значение × 1000
    do_code    text      -- _DO
) DISTRIBUTED BY (do_code);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_lc IS 'RAV и LC по ДО и году (устаревший шаблон). Qlik: таблица [RavLc]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_lc.rav_lc_key IS 'Qlik: [RavLc.Ключ] — ДО|Год';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_lc.rav_value IS 'Qlik: [RavLc.Значение_RAV] — исходное значение × 1000';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_lc.lc_value IS 'Qlik: [RavLc.Значение_LC] — исходное значение × 1000';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_lc.do_code IS 'Qlik: [RavLc._DO]';
