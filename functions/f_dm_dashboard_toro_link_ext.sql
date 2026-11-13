
-- workfile per segment: ROW_NUMBER() PARTITION BY order_num на таблице,
-- DISTRIBUTED BY (entity, do_code), сваливает ВСЕ NULL order_num на один
-- сегмент (skew) и сортирует их → превышение gp_workfile_limit_per_segment.
--
-- Фикс: окно только для строк с order_num (сущность «Сообщения»), после
-- перераспределения DISTRIBUTED BY (order_num); остальные сущности — без окна.
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_link_ext() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE
    v_rows bigint := 0;
    v_cnt  bigint;
    r      record;
BEGIN
    BEGIN
        PERFORM set_config('statement_mem', '128MB', true);
        PERFORM set_config('gp_workfile_compression', 'on', true);
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext;

    DROP TABLE IF EXISTS tmp_le_cal;
    DROP TABLE IF EXISTS tmp_le_do;
    DROP TABLE IF EXISTS tmp_le_pg;
    DROP TABLE IF EXISTS tmp_le_msg;

    -- Малые справочники: hash-join без раздувания workfile
    CREATE TEMP TABLE tmp_le_cal ON COMMIT DROP AS
    SELECT cal.cal_date,
           cal.quarter_year,
           cal.quarter_year_sort,
           cal.year_quarter,
           cal.year_month,
           cal.month_year,
           cal.month_year_sort,
           cal.month_num,
           cal.month_name,
           cal.all_years,
           cal.year_num,
           cal.day_counter,
           mcal.month_counter
    FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_calendar cal
    LEFT JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_year_month_counter mcal
           ON cal.month_year = mcal.month_year
    DISTRIBUTED BY (cal_date);
    ANALYZE tmp_le_cal;

    CREATE TEMP TABLE tmp_le_do ON COMMIT DROP AS
    SELECT do_code, do_full_name, do_short_name, do_abbr, do_color, do_sort_num
    FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_do
    DISTRIBUTED BY (do_code);
    ANALYZE tmp_le_do;

    CREATE TEMP TABLE tmp_le_pg ON COMMIT DROP AS
    SELECT planner_group, pg_abbr, pg_text, pg_sort
    FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_hb_planner_group
    DISTRIBUTED BY (planner_group);
    ANALYZE tmp_le_pg;

    ------------------------------------------------------------------
    -- 1) «Сообщения»: есть order_num → окно локально после redistribute
    ------------------------------------------------------------------
    CREATE TEMP TABLE tmp_le_msg ON COMMIT DROP AS
    SELECT tl.entity,
           tl.notification,
           tl.order_num,
           tl.equipment,
           tl.do_code,
           tl.planner_group,
           tl.cost_key,
           tl.cost_fact_key,
           tl.lc_key,
           tl.eo_ext_key,
           tl.link_date,
           tl.date_type,
           tl.reduction
    FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link tl
    WHERE tl.entity = 'Сообщения'
      AND tl.order_num IS NOT NULL
    DISTRIBUTED BY (order_num);
    ANALYZE tmp_le_msg;

    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext
    SELECT coalesce(tl.notification, 'X') || coalesce(tl.order_num, 'X') AS key_ord_note,
           tl.entity,
           tl.notification,
           tl.order_num,
           tl.equipment,
           tl.do_code,
           tl.planner_group,
           tl.cost_key,
           tl.cost_fact_key,
           tl.lc_key,
           tl.eo_ext_key,
           tl.link_date,
           tl.date_type,
           tl.reduction,
           cl.cal_date,
           cl.quarter_year,
           cl.quarter_year_sort,
           cl.year_quarter,
           cl.year_month,
           cl.month_year,
           cl.month_year_sort,
           cl.month_num,
           cl.month_name,
           cl.all_years,
           cl.year_num,
           cl.day_counter,
           cl.month_counter,
           rd.do_full_name,
           rd.do_short_name,
           rd.do_abbr,
           rd.do_color,
           rd.do_sort_num,
           rg.pg_abbr,
           rg.pg_text,
           rg.pg_sort,
           ROW_NUMBER() OVER (PARTITION BY tl.order_num ORDER BY tl.link_date)::text AS ord_conser_key
    FROM tmp_le_msg tl
    LEFT JOIN tmp_le_cal cl ON cl.cal_date = tl.link_date
    LEFT JOIN tmp_le_do  rd ON rd.do_code = tl.do_code
    LEFT JOIN tmp_le_pg  rg ON rg.planner_group = tl.planner_group;

    GET DIAGNOSTICS v_cnt = ROW_COUNT;
    v_rows := v_rows + v_cnt;
    DROP TABLE IF EXISTS tmp_le_msg;

    ------------------------------------------------------------------
    -- 2) Сообщения без заказа + прочие сущности — без window, батчами
    ------------------------------------------------------------------
    FOR r IN
        SELECT e AS entity
        FROM unnest(ARRAY[
            'Сообщения',
            'ЗатратыПланФакт',
            'ЗатратыФакт',
            'LC(мес)',
            'ЕО',
            'ЕО_Ext'
        ]) AS e
    LOOP
        INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext
        SELECT coalesce(tl.notification, 'X') || coalesce(tl.order_num, 'X') AS key_ord_note,
               tl.entity,
               tl.notification,
               tl.order_num,
               tl.equipment,
               tl.do_code,
               tl.planner_group,
               tl.cost_key,
               tl.cost_fact_key,
               tl.lc_key,
               tl.eo_ext_key,
               tl.link_date,
               tl.date_type,
               tl.reduction,
               cl.cal_date,
               cl.quarter_year,
               cl.quarter_year_sort,
               cl.year_quarter,
               cl.year_month,
               cl.month_year,
               cl.month_year_sort,
               cl.month_num,
               cl.month_name,
               cl.all_years,
               cl.year_num,
               cl.day_counter,
               cl.month_counter,
               rd.do_full_name,
               rd.do_short_name,
               rd.do_abbr,
               rd.do_color,
               rd.do_sort_num,
               rg.pg_abbr,
               rg.pg_text,
               rg.pg_sort,
               NULL::text AS ord_conser_key
        FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link tl
        LEFT JOIN tmp_le_cal cl ON cl.cal_date = tl.link_date
        LEFT JOIN tmp_le_do  rd ON rd.do_code = tl.do_code
        LEFT JOIN tmp_le_pg  rg ON rg.planner_group = tl.planner_group
        WHERE tl.entity = r.entity
          AND (r.entity IS DISTINCT FROM 'Сообщения' OR tl.order_num IS NULL);

        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        v_rows := v_rows + v_cnt;
    END LOOP;

    -- На случай новых entity, не попавших в список выше
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext
    SELECT coalesce(tl.notification, 'X') || coalesce(tl.order_num, 'X'),
           tl.entity, tl.notification, tl.order_num, tl.equipment, tl.do_code, tl.planner_group,
           tl.cost_key, tl.cost_fact_key, tl.lc_key, tl.eo_ext_key, tl.link_date, tl.date_type, tl.reduction,
           cl.cal_date, cl.quarter_year, cl.quarter_year_sort, cl.year_quarter, cl.year_month,
           cl.month_year, cl.month_year_sort, cl.month_num, cl.month_name, cl.all_years, cl.year_num,
           cl.day_counter, cl.month_counter,
           rd.do_full_name, rd.do_short_name, rd.do_abbr, rd.do_color, rd.do_sort_num,
           rg.pg_abbr, rg.pg_text, rg.pg_sort,
           NULL::text
    FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link tl
    LEFT JOIN tmp_le_cal cl ON cl.cal_date = tl.link_date
    LEFT JOIN tmp_le_do  rd ON rd.do_code = tl.do_code
    LEFT JOIN tmp_le_pg  rg ON rg.planner_group = tl.planner_group
    WHERE tl.entity NOT IN (
        'Сообщения', 'ЗатратыПланФакт', 'ЗатратыФакт', 'LC(мес)', 'ЕО', 'ЕО_Ext'
    );
    GET DIAGNOSTICS v_cnt = ROW_COUNT;
    v_rows := v_rows + v_cnt;

    DROP TABLE IF EXISTS tmp_le_cal;
    DROP TABLE IF EXISTS tmp_le_do;
    DROP TABLE IF EXISTS tmp_le_pg;

    ANALYZE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_link_ext;
    RETURN v_rows;
END;
$$;
