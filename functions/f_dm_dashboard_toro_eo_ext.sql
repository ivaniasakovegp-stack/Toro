

CREATE OR REPLACE FUNCTION dp_rid_dmt_cns_corp_pixbi_brd_toro.f_dm_dashboard_toro_eo_ext() RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE v_rows bigint;
BEGIN
    TRUNCATE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext;
    INSERT INTO dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext
    WITH iv AS (
        SELECT equipment, ts_start, ts_end
        FROM (
            -- [ЕО.Расширенная.temp1]: интервалы заказов (Load Distinct)
            SELECT DISTINCT equipment,
                   ord_fact_start_date + ord_fact_start_time AS ts_start,   -- ДатаВремя начала
                   ord_fact_end_date   + ord_fact_end_time   AS ts_end      -- ДатаВремя завершения
            FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_messages
            WHERE ord_fact_start_date IS NOT NULL
              AND ord_fact_end_date   IS NOT NULL
              AND coalesce(toro_work_type, '') <> 'SRV'
            UNION ALL
            -- [ВремяЭкспл]: Peek() идёт по ВСЕМ точкам ЕО, фильтр по точке — после (preceding load)
            SELECT equipment, ts_start, ts_end
            FROM (SELECT equipment, point_name,
                         change_date + meas_moment AS ts_end,
                         CASE WHEN row_number() OVER w = 1
                              THEN change_date + meas_moment - counter_diff * interval '1 hour'
                              ELSE lag(change_date + meas_moment) OVER w
                         END AS ts_start
                  FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_src_eo_oper_time
                  WINDOW w AS (PARTITION BY equipment ORDER BY change_date, meas_moment)) x
            WHERE point_name = 'Часы в нерабочем состоянии'
        ) u
        -- интервалы без времени в Qlik дают NULL-метки и не порождают ни одного дня
        WHERE equipment IS NOT NULL AND ts_start IS NOT NULL AND ts_end IS NOT NULL
    ),
    isl AS (
        -- новый «остров», если начало >= максимального конца всех предыдущих интервалов ЕО
        SELECT equipment, min(ts_start) AS ts_start, max(ts_end) AS ts_end
        FROM (SELECT equipment, ts_start, ts_end,
                     sum(is_new) OVER (PARTITION BY equipment ORDER BY ts_start, ts_end
                                       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS grp
              FROM (SELECT equipment, ts_start, ts_end,
                           CASE WHEN ts_start < max(ts_end) OVER (PARTITION BY equipment ORDER BY ts_start, ts_end
                                                                  ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
                                THEN 0 ELSE 1 END AS is_new
                    FROM iv) a) b
        GROUP BY equipment, grp
    ),
    dh AS (
        -- [ЕО.Расширенная.temp3] + [temp3_1]: часы интервала по дням, Σ за день не более 24 ч
        SELECT equipment, work_day, least(sum(h), 24) AS day_hours
        FROM (SELECT i.equipment, d.dt AS work_day,
                     CASE WHEN i.ts_start = i.ts_end THEN 0
                          ELSE extract(epoch FROM (
                                 CASE WHEN d.dt = i.ts_end::date THEN i.ts_end
                                      ELSE d.dt + interval '1 day' - interval '1 millisecond' END   -- DayEnd()
                               - CASE WHEN d.dt = i.ts_start::date THEN i.ts_start
                                      ELSE d.dt::timestamp END                                       -- DayStart()
                               )) / 3600.0
                     END AS h
              FROM isl i
              JOIN dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_dim_day d ON d.dt BETWEEN i.ts_start::date AND i.ts_end::date
              -- [ЕО.Расширенная.temp2]: исключаемые статусы (ЕО без статуса / вне справочника — остаются)
              WHERE NOT EXISTS (SELECT 1 FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo e
                                WHERE e.equipment = i.equipment
                                  AND dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_wm(e.eo_status, ARRAY['Бездействие','На консервации','Проектируемый',
                                                                'Списано','Строительство']))) t
        GROUP BY equipment, work_day
    ),
    mh AS (
        -- [ЕО.Расширенная.temp4/temp5]
        SELECT equipment, date_trunc('month', work_day)::date AS month_start, sum(day_hours) AS work_hours_month
        FROM dh
        WHERE work_day >= date '2022-01-01'
        GROUP BY equipment, date_trunc('month', work_day)::date
    ),
    top AS (
        -- [ЕО.КТГ.ТОП10.temp1..temp4]
        SELECT e.equipment, m.month_start,
               coalesce(h.work_hours_month, 0) AS work_hours_month,
               CASE WHEN e.kpi6_ktg_bi = 0 THEN 0
                    ELSE (24 * m.days_in_month - coalesce(h.work_hours_month, 0)) / (24.0 * m.days_in_month)
               END AS ktg
        FROM (SELECT equipment, kpi6_ktg_bi
              FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo
              WHERE kpi6_ktg_ei = 1
                AND lower(eo_type_descr) IN (SELECT lower(eo_type_descr) FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.v_ref_eo_type_tracked
                                             WHERE dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_nz(eo_type_descr) IS NOT NULL)) e
        CROSS JOIN (SELECT dt AS month_start,
                           ((dt + interval '1 month')::date - dt) AS days_in_month
                    FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_etl_dim_day
                    WHERE extract(day FROM dt) = 1
                      AND dt BETWEEN date '2022-01-01' AND date_trunc('month', current_date)::date) m
        LEFT JOIN mh h ON h.equipment = e.equipment AND h.month_start = m.month_start
    )
    -- Outer Join [temp5] с ТОП-10 + Left Join КТГ + атрибуты ЕО + RowNo()
    SELECT row_number() OVER (ORDER BY u.equipment, u.month_start) AS eo_ext_key,
           u.equipment, u.month_start, u.work_hours_month, u.ktg,
           a.do_code, a.planner_group, a.resp_workcenter
    FROM (SELECT coalesce(h.equipment, t.equipment)               AS equipment,
                 coalesce(h.month_start, t.month_start)           AS month_start,
                 coalesce(h.work_hours_month, t.work_hours_month) AS work_hours_month,
                 t.ktg
          FROM mh h
          FULL OUTER JOIN top t ON t.equipment = h.equipment AND t.month_start = h.month_start) u
    LEFT JOIN (SELECT DISTINCT equipment, do_code, planner_group, resp_workcenter FROM dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo) a
           ON a.equipment = u.equipment;
    GET DIAGNOSTICS v_rows = ROW_COUNT;
    ANALYZE dp_rid_dmt_cns_corp_pixbi_brd_toro.dm_dashboard_toro_eo_ext;
    RETURN v_rows;
END;
$$;
