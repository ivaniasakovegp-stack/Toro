

-- SubField(FileBaseName(), '_', n) ; n = -1 -> последняя часть
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_file_part(fn text, n int) RETURNS text
LANGUAGE sql IMMUTABLE AS $$
    SELECT CASE WHEN n = -1 THEN regexp_replace(b, '^.*_', '')
                ELSE split_part(b, '_', n) END
    FROM (SELECT regexp_replace(fn, '\.[^.]*$', '') AS b) x
$$;
