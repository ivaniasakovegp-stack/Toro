

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_service_cost() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint := 0; v_cnt bigint;
BEGIN
    
    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_service_cost;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_service_cost 
    SELECT order_num, contractor_name, service_name, sum(service_cost) as service_cost,
                md5(concat(order_num, contractor_name, service_name))::text as ord_conser_key
            FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_service_cost
            group by order_num, contractor_name, service_name;
    GET DIAGNOSTICS v_cnt = ROW_COUNT; v_rows := v_rows + v_cnt;

    RETURN v_rows;
END;
$$;
