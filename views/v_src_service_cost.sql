-- 01-09.Extract.ТОРО.ЗатратыУслуги   (Loader/02.09)
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_service_cost AS
SELECT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(order_num)           AS order_num,        -- Заказ
       btrim(contractor_name)      AS contractor_name,  -- Наименование контрагента
       btrim(material_text)        AS service_name,     -- Наименование услуги
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(amount_no_vat)   AS service_cost      -- Стоимость услуги
FROM dp_rid_ods_corp_dfs_dashboard_toro.service_cost
union all
SELECT btrim(afvc.aufnr)            AS order_num,        -- Заказ
       btrim(afvc.name1)            AS contractor_name,  -- Наименование контрагента
       btrim(afvc.txz01)            AS service_name,     -- Наименование услуги
       afvc.netpr                   AS service_cost      -- Стоимость услуги
FROM dp_rid_ods_corp_torobrd_src.afvc
  JOIN dp_rid_ods_corp_torobrd_src.aufk
    ON aufk.aufnr = afvc.aufnr
  JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_plants tp
    ON tp.id_nsi = aufk.iwerk
WHERE afvc.aufnr IS NOT NULL
  AND btrim(afvc.aufnr) <> ''
  and afvc.aufnr='0000'; -- Убрать фильтр для переключения источника данных
-- v_src_service_cost (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919561)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_service_cost IS 'Затраты по услугам подрядчиков';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_service_cost."order_num" IS 'Заказ';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_service_cost."contractor_name" IS 'Наименование контрагента';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_service_cost."service_name" IS 'Наименование услуги';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_service_cost."service_cost" IS 'Стоимость услуги';
