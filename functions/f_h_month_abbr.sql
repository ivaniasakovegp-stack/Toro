

-- Сокращённое название месяца (SET MonthNames='янв;фев;...')
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_month_abbr(m int) RETURNS text
LANGUAGE sql IMMUTABLE AS $$
    SELECT (ARRAY['янв','фев','мар','апр','май','июн','июл','авг','сен','окт','ноя','дек'])[m]
$$;
