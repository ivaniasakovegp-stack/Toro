

-- Префикс технического места из k уровней (TM2..TM6 в 04.01.01 / 04.03):
-- Text(If(SubStringCount(TM,'-') >= k-1, SubField(TM,'-',1)&'-'&...&SubField(TM,'-',k)))
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_tm_prefix(tm text, k int) RETURNS text
LANGUAGE sql IMMUTABLE AS $$
    SELECT CASE WHEN dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_substr_count(tm, '-') >= k - 1
                THEN array_to_string((string_to_array(tm, '-'))[1:k], '-') END
$$;
