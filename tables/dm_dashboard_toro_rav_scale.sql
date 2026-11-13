

-- [Шкала оценки RAV]
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_scale;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_scale (
	scale_name text NULL, -- Шкала %RAV
	rav_pct numeric NULL -- %RAV
)
DISTRIBUTED BY (scale_name);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_scale IS 'Шкала оценки RAV (константы)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_scale.scale_name IS 'Шкала %RAV';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_rav_scale.rav_pct IS '%RAV';
