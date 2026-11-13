

-- SubStringCount(s, sub) — регистрозависимо, как в Qlik
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_substr_count(s text, sub text) RETURNS int
LANGUAGE sql IMMUTABLE AS $$
    SELECT CASE WHEN s IS NULL OR sub IS NULL OR sub = '' THEN 0
                ELSE (length(s) - length(replace(s, sub, ''))) / length(sub) END
$$;
