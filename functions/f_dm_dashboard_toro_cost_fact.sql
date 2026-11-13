

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_cost_fact() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint := 0; v_cnt bigint;
BEGIN
    --TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact;
    --INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_plan_fact SELECT * FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_plan_fact;
    --GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows := v_rows + v_cnt;

    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_cost_fact 
    SELECT md5(concat(cost_fact_key, do_code, cost_group, field_name, workshop, account_1, account_2, account))::text as cost_fact_key,
            do_code, month_start, cost_group, field_name, workshop, account_1, account_2, account,
            sum(cost_fact) as cost_fact, sum(cost_plan) as cost_plan
            FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_cost_fact
            group by cost_fact_key,do_code,month_start,cost_group,field_name,workshop,account_1,account_2,account;
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows := v_rows + v_cnt;

    RETURN v_rows;
END;
$$;
