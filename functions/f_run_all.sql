


/* Ошибка на шаге: изменения шага откатываются (подтранзакция), предыдущие шаги сохраняются,
   ошибка пишется в dm_dashboard_toro_etl_log, дальнейшие шаги не выполняются. */
CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_run_all(p_from_step int DEFAULT 0) RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
    v_run_id bigint := nextval('dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_seq_run_id');
    r        record;
    v_rows   bigint;
    v_start  timestamp;
BEGIN
    FOR r IN SELECT step_no, func_name FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_step
             WHERE is_active AND step_no >= p_from_step ORDER BY step_no
    LOOP
        v_start := clock_timestamp();
        BEGIN
            EXECUTE 'SELECT ' || r.func_name || '()' INTO v_rows;
            INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_log
            VALUES (v_run_id, r.step_no, r.func_name, v_start, clock_timestamp(), v_rows, 'OK', NULL);
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_log
            VALUES (v_run_id, r.step_no, r.func_name, v_start, clock_timestamp(), NULL, 'ERROR', SQLERRM);
            RETURN 'run_id=' || v_run_id || ': ERROR on step ' || r.step_no || ' ' || r.func_name || ': ' || SQLERRM;
        END;
    END LOOP;
    RETURN 'run_id=' || v_run_id || ': OK';
END;
$$;
