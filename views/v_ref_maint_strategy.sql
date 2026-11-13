

-- Стратегия обслуживания (inline из 04.03)
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_maint_strategy AS
SELECT * FROM (VALUES
    ('ПЛАНТО'::text, 'Плановое тех. обслуживание'::text),
    ('ФАКТСОСТ', 'Обслуж. по факт. состоянию'),
    ('ОТКАЗ',    'Эксплуатация до отказа'),
    ('ВЫШЕЕО',   'Входит в вышест. ЕО')) v (maint_strategy, strategy_descr);
-- v_ref_maint_strategy (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919655)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_maint_strategy IS 'Расшифровка стратегий обслуживания (константы)';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_maint_strategy."maint_strategy" IS 'Стратегия обслуживания';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_maint_strategy."strategy_descr" IS 'ЕО.Стратегия, расшифровка';