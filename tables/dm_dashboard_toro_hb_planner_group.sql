-- Справочник ГП.xlsx
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_planner_group;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_planner_group (
	planner_group text NULL, -- Группа плановиков
	pg_abbr text NULL, -- Группа плановиков (сокр.)
	pg_text text NULL, -- Группа плановиков (текст)
	pg_sort integer NULL -- Сортировка
)
WITH (
	appendonly=true,
	orientation=row,
	compresstype=zlib, 
	compresslevel=1
)
DISTRIBUTED REPLICATED;

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_planner_group IS 'Справочник Группа плановиков [Ref_ГП] (02-07.Model.RefGP)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_planner_group.planner_group IS 'Группа плановиков';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_planner_group.pg_text IS 'Группа плановиков (текст)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_planner_group.pg_abbr IS 'Группа плановиков (сокр.)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_planner_group.pg_sort IS 'Сортировка';
