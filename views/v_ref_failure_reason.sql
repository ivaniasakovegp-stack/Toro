-- [Reason for refuse] + строка NOVALUE
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_failure_reason AS
SELECT reason_code, reason_group, reason_name FROM dp_rid_ods_corp_dfs_dashboard_toro.hb_failure_reason
UNION ALL
SELECT 'NOVALUE'::text, 'Не указано'::text, 'Не указано'::text
union all -- Источник СИД КСУ НСИ
SELECT c.id_nsi::text        AS reason_code,   -- Причина отказа_код
       g.name::text          AS reason_group,  -- Причина отказа_загл (наименование группы кодов)
       c.name::text          AS reason_name    -- Причина отказа (наименование кода)
FROM dp_rid_ods_corp_ksunsiups_nsi.toro_codes c
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_codesgroups g
       ON g.id_nsi = c.toro_codesgroups_id
WHERE c.is_deleted_insource = FALSE
  AND c.is_blocked = false and c.id_nsi='0000'; -- Убрать фильтр для переключения источника данных
-- v_ref_failure_reason (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919613)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_failure_reason IS 'Справочник причин отказа + строка NOVALUE';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_failure_reason."reason_code" IS 'Причина отказа_код';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_failure_reason."reason_group" IS 'Причина отказа_загл';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_failure_reason."reason_name" IS 'Причина отказа';
