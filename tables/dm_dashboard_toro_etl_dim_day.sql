

/* ---------------------------------------------------------------------
   Календарь-«числа» для разворота интервалов по дням
   (замена While IterNo() в Qlik; без LATERAL — для совместимости с GP 6)
   --------------------------------------------------------------------- */
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_dim_day;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_dim_day (dt date NOT NULL)
DISTRIBUTED REPLICATED;

INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_dim_day (dt)
SELECT d::date FROM generate_series('2000-01-01'::date, '2045-12-31'::date, interval '1 day') d;
