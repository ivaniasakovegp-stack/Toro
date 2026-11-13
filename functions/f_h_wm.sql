

-- WildMatch(x, 'p1', 'p2', ...) > 0
-- Шаблоны передаются в синтаксисе LIKE ('%ЗАКР%'). WildMatch регистронезависим -> ILIKE.
-- WildMatch(NULL, ...) в Qlik = 0, поэтому NULL -> false (важно для NOT WildMatch(...)).
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(p text, patterns text[]) RETURNS boolean
LANGUAGE sql IMMUTABLE AS $$ SELECT coalesce(p ILIKE ANY (patterns), false) $$;
