

-- [Затраты по услугам]
DROP TABLE IF EXISTS dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_service_cost;
CREATE TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_service_cost (
    order_num       text,     -- Заказ
    contractor_name text,     -- Наименование контрагента
    service_name    text,     -- Наименование услуги
    service_cost    numeric,   -- Стоимость услуги
    ord_conser_key  text    -- Уникальный ключ Заказ-Контрагент-Услуга
) DISTRIBUTED BY (order_num);

COMMENT ON TABLE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_service_cost IS 'Затраты по услугам подрядчиков в разрезе заказов. Qlik: таблица [Затраты по услугам] (Code/2.13)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_service_cost.order_num IS 'Qlik: [Заказ]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_service_cost.contractor_name IS 'Qlik: [Наименование контрагента]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_service_cost.service_name IS 'Qlik: [Наименование услуги]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_service_cost.service_cost IS 'Qlik: [Стоимость услуги]';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_service_cost.ord_conser_key IS 'Уникальный ключ Заказ-Контрагент-Услуга';
