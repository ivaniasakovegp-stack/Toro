

-- SubField(Replace(filename(), '_', '.'), '.', -2): 'Заказы_1022.xlsx' -> '1022'
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_file_do(fn text) RETURNS text
LANGUAGE sql IMMUTABLE AS $$
    SELECT reverse(split_part(reverse(replace(fn, '_', '.')), '.', 2))
$$;
