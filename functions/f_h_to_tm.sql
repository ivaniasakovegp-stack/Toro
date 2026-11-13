

-- Time(x): 'HH:MI[:SS]', дробная часть суток Excel (0.5 = 12:00) или полный timestamp
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_tm(p text) RETURNS time
LANGUAGE sql IMMUTABLE AS $$
    SELECT CASE
        WHEN s IS NULL THEN NULL
        WHEN s ~ '^\d{1,2}:\d{2}(:\d{2}(\.\d+)?)?$' THEN s::time
        WHEN s ~ '^\d+(\.\d+)?$' THEN time '00:00' + (s::float8 - floor(s::float8)) * interval '1 day'
        ELSE dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_ts(s)::time
    END
    FROM (SELECT nullif(btrim(p), '') AS s) x
$$;
