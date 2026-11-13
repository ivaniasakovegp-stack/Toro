

-- [ЕО.Count]
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_count_by_do;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_count_by_do (
    do_code   text,    -- ДО
    eo_count  bigint   -- Единица оборудования_CountMRP
) DISTRIBUTED BY (do_code);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_count_by_do IS 'Количество ЕО по ДО. Qlik: таблица [ЕО.Count] (Code/02.03)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_count_by_do.do_code IS 'Qlik: [ДО]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_count_by_do.eo_count IS 'Qlik: [Единица оборудования_CountMRP]';
