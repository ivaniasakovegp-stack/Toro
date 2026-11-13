

-- [LC] (02-09.Model.LC)
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_lc_month;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_lc_month (
    lc_key       text,     -- LC.Ключ — ДО|MMM_YYYY
    do_code      text,     -- ДО
    month_start  date,     -- Дата на начало месяца
    lc_plan      numeric,  -- Значение LC план, руб. — исходное значение × 1000
    lc_fact      numeric   -- Значение LC факт, руб. — исходное значение × 1000
) DISTRIBUTED BY (do_code);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_lc_month IS 'LC помесячно, план/факт. Qlik: таблица [LC], 02-09.Model.LC.qvd';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_lc_month.lc_key IS 'Qlik: [LC.Ключ] — ДО|MMM_YYYY';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_lc_month.do_code IS 'Qlik: [ДО]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_lc_month.month_start IS 'Qlik: [LC.Дата на начало месяца]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_lc_month.lc_plan IS 'Qlik: [LC.Значение LC план, руб.] — исходное значение × 1000';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_lc_month.lc_fact IS 'Qlik: [LC.Значение LC факт, руб.] — исходное значение × 1000';
