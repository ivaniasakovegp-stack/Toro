

/* ---------------------------------------------------------------------
   Хелперы — эквиваленты функций Qlik.
   Все IMMUTABLE и не читают таблиц: безопасны для выполнения на сегментах.
   --------------------------------------------------------------------- */

-- EmptyIsNull(Trim(x))
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(p text) RETURNS text
LANGUAGE sql IMMUTABLE AS $$ SELECT nullif(btrim(p), '') $$;
