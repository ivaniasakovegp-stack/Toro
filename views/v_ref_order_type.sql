

-- Вид заказа (inline из 04.02)
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_order_type AS
SELECT * FROM (VALUES
    ('RD01'::text, 'Планово-предупредительное обслуживание'::text, 'Плановые'::text),
    ('RD02', 'Обслуживание по фактическому состоянию', 'Плановые'),
    ('RD03', 'Корректирующее обслуживание',            'Внеплановые'),
    ('RD04', 'Неотложное обслуживание',                'Аварийные')) v (order_type, order_type_text, work_kind);
-- v_ref_order_type (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919653)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_order_type IS 'Расшифровка видов заказа (константы)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_order_type."order_type" IS 'Вид заказа';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_order_type."order_type_text" IS 'Вид заказа текст';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_order_type."work_kind" IS 'Вид заказа - тип работ';
