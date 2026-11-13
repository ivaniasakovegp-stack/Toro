

-- Справочник пороги KPI Справочник Шаблон порогов.xlsx
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level (
	kpi_level text NULL, -- Номер KPI
	unit text NULL, -- Единица измерения
	low_limit numeric NULL, -- Нижний показатель эффективности
	target_limit numeric NULL, -- Целевой показатель эффективности
	high_limit numeric NULL, -- Верхний показатель эффективности
	low_limit_low numeric NULL, -- Нижний показатель эффективности Нижний Диапазон 
	low_limit_high numeric NULL, -- Нижний показатель эффективности Верхний Диапазон 
	target_limit_low numeric NULL, -- Целевой показатель эффективности Нижний Диапазон 
	target_limit_high numeric NULL, -- Целевой показатель эффективности Верхний Диапазон 
	high_limit_low numeric NULL, -- Верхний показатель эффективности Нижний Диапазон 
	high_limit_high numeric NULL, -- Верхний показатель эффективности Верхний Диапазон 
	src_sheet text NULL -- Имя листа Excel источника из загрузчика
)
WITH (
	appendonly=true,
	orientation=row,
	compresstype=zlib, 
	compresslevel=1
)
DISTRIBUTED REPLICATED;

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level IS 'Справочник пороги KPI';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level.kpi_level IS 'Номер KPI';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level.unit IS 'Единица измерения';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level.low_limit IS 'Нижний показатель эффективности';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level.target_limit IS 'Целевой показатель эффективности';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level.high_limit IS 'Верхний показатель эффективности';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level.low_limit_low IS 'Нижний показатель эффективности Нижний Диапазон ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level.low_limit_high IS 'Нижний показатель эффективности Верхний Диапазон';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level.target_limit_low IS 'Целевой показатель эффективности Нижний Диапазон';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level.target_limit_high IS 'Целевой показатель эффективности Верхний Диапазон';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level.high_limit_low IS 'Верхний показатель эффективности Нижний Диапазон';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level.high_limit_high IS 'Верхний показатель эффективности Верхний Диапазон ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_kpi_level.src_sheet IS 'Имя листа Excel источника из загрузчика';
