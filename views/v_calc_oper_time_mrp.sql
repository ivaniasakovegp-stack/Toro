-- МРП по ЕО = Alt(Наработка по КР, Наработка по экспл, 0)
--   по КР = (Σ показаний перед сбросом в 0 + последнее показание) / кол-во сбросов (0 сбросов -> NULL)
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_calc_oper_time_mrp AS
with src_oper_time as  -- Начало Аналог v_src_oper_time
(SELECT equipment,                                   -- Единица оборудования
       meas_point,                                  -- Точка измерений
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_dt(meas_date)      AS meas_date,      -- Дата измерений
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_tm(meas_moment)    AS meas_moment,    -- Момент измерений
       dp_rid_dmt_cns_corp_pixbi_brd_toro.f_h_to_num(counter_value) AS counter_value,  -- Показания счетчика
       point_name                                   -- Название точки измерений
FROM dp_rid_ods_corp_dfs_dashboard_toro.oper_time
union all -- данные из Источника SAP ТОРО, КСУ НСИ
SELECT eo.inventory_number                    AS equipment,      -- Единица оборудования (инв. номер)
       mp.id_nsi                              AS meas_point,     -- Точка измерений (ВЭ)
       i.idate                                AS change_date,    -- Дата изменения ВЭ
       i.itime                                AS meas_moment,    -- Момент измерений ВЭ
       i.cntrr::numeric                        AS counter_value,  -- Показания счетчика ВЭ
       mp.name                                AS point_name     -- Название точки измерений ВЭ
       --i.cdiff::numeric                        AS counter_diff   -- Разница ПоказанСчетчик ВЭ
FROM dp_rid_ods_corp_torobrd_src.imrg i
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_equipments eo
       ON eo.guid::text= i.equnr_guid
      AND eo.is_blocked = false
LEFT JOIN dp_rid_ods_corp_ksunsiups_nsi.toro_measurement_points mp
       ON mp.guid::text= i.point_guid
      AND mp.is_deleted = false
WHERE i.lvorm <> 'X' 
		and i.equnr_guid='X' -- Убрать для переключения источника  
		AND i.cancl <> 'X') 
-- Окончание аналога v_src_oper_time
SELECT coalesce(kr.equipment, expl.equipment)           AS equipment,
       coalesce(kr.oper_by_kr, expl.oper_by_expl, 0)    AS mrp            -- МРП по ЕО (Наработка_базовая)
FROM (
    SELECT equipment,
           (sum(kr_value_for_sum)
            + CASE WHEN count(DISTINCT CASE WHEN rk_last = 1 THEN counter_value END) = 1
                   THEN max(CASE WHEN rk_last = 1 THEN counter_value END) END)
           / nullif(sum(kr_flag), 0) AS oper_by_kr
    FROM (SELECT equipment, counter_value,
                 CASE WHEN rn > 1 AND counter_value = 0 THEN prev_value ELSE 0 END AS kr_value_for_sum,
                 CASE WHEN rn > 1 AND counter_value = 0 THEN 1 ELSE 0 END          AS kr_flag,
                 rank() OVER (PARTITION BY equipment ORDER BY meas_date DESC)      AS rk_last
          FROM (SELECT equipment, meas_date, counter_value,
                       row_number() OVER w AS rn,
                       lag(counter_value) OVER w AS prev_value
                FROM src_oper_time
                WHERE point_name = 'Наработка с последнего КР'
                WINDOW w AS (PARTITION BY equipment ORDER BY meas_date, meas_moment)) r) f
    GROUP BY equipment
) kr
FULL OUTER JOIN (
    SELECT equipment,
           CASE WHEN count(DISTINCT counter_value) = 1 THEN max(counter_value) END AS oper_by_expl
    FROM (SELECT equipment, counter_value,
                 rank() OVER (PARTITION BY equipment ORDER BY meas_date DESC) AS rk
          FROM src_oper_time
          WHERE point_name = 'Наработка с начала эксплуатации') x
    WHERE rk = 1
    GROUP BY equipment
) expl ON expl.equipment = kr.equipment;
-- v_calc_oper_time_mrp (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919661)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_calc_oper_time_mrp IS 'МРП по ЕО: наработка с последнего КР, при отсутствии — с начала эксплуатации';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_calc_oper_time_mrp."equipment" IS 'Единица оборудования';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_calc_oper_time_mrp."mrp" IS 'МРП по ЕО';
