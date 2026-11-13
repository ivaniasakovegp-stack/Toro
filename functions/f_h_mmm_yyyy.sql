

-- Text(Date(d, 'MMM_YYYY')) -> 'янв_2024' (используется в ключах затрат/LC)
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_mmm_yyyy(d date) RETURNS text
LANGUAGE sql IMMUTABLE AS $$
    SELECT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_month_abbr(extract(month FROM d)::int) || '_' || extract(year FROM d)::int
$$;
