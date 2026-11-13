

-- Текст -> timestamp. Поддерживает ISO, DD.MM.YYYY[ HH:MI[:SS]] и серийную дату Excel (число дней от 30.12.1899)
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_ts(p text) RETURNS timestamp
LANGUAGE sql IMMUTABLE AS $$
    SELECT CASE
        WHEN s IS NULL THEN NULL
        WHEN s ~ '^\d{4}-\d{2}-\d{2}([ T]\d{1,2}:\d{2}(:\d{2}(\.\d+)?)?)?$'
            THEN replace(s, 'T', ' ')::timestamp
        WHEN s ~ '^\d{1,2}\.\d{1,2}\.\d{4}( \d{1,2}:\d{2}(:\d{2}(\.\d+)?)?)?$'
            THEN to_date(split_part(s, ' ', 1), 'DD.MM.YYYY')
                 + coalesce(nullif(split_part(s, ' ', 2), '')::time, time '00:00')
        WHEN s ~ '^\d+(\.\d+)?$'
            THEN timestamp '1899-12-30' + s::float8 * interval '1 day'
    END
    FROM (SELECT nullif(btrim(p), '') AS s) x
$$;
