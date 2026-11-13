

-- Num#(x, '#', ',', '.') — текст -> число. Пробелы/неразрывные пробелы убираются, запятая = десятичный разделитель.
-- Нечисловое значение -> NULL (как в Qlik).
-- STRICT: NULL не вызывает тело (меньше вызовов на больших сканах ODS).
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(p text) RETURNS numeric
LANGUAGE sql IMMUTABLE STRICT AS $$
    SELECT CASE WHEN s ~ '^[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)([eE][+-]?[0-9]+)?$' THEN s::numeric END
    FROM (SELECT replace(replace(replace(btrim(p), ' ', ''), chr(160), ''), ',', '.') AS s) x
$$;
