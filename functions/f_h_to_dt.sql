

-- Date(Floor(x))
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(p text) RETURNS date
LANGUAGE sql IMMUTABLE AS $$ SELECT dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_ts(p)::date $$;
