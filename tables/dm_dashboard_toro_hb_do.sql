

-- Справочник ДО.xlsx
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do (
	do_code text NULL, -- ДО
	do_full_name text NULL, -- ДО (полное наименование)
	do_short_name text NULL, -- ДО (краткое наименование)
	do_abbr text NULL, -- ДО (сокр.)
	do_color text NULL, -- ДО (цвет)
	do_sort text NULL, -- ДО (сорт)
	do_sort_num integer -- ДО сорт (число)
)
WITH (
	appendonly=true,
	orientation=row,
	compresstype=zlib, 
	compresslevel=1
)
DISTRIBUTED REPLICATED;

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do IS 'Справочник [Дочерние общества]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do.do_code IS 'ДО код';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do.do_full_name IS 'ДО (полное наименование)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do.do_short_name IS 'ДО (краткое наименование)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do.do_abbr IS 'ДО (сокращение)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do.do_color IS 'ДО (цвет)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do.do_sort IS 'ДО (сорт)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do.do_sort_num IS 'ДО сорт (число)';
