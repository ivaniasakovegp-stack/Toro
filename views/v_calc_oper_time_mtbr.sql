/* ===================== НАРАБОТКА (Code/02.09) =====================
   FirstSortedValue(value, weight): при нескольких РАЗНЫХ значениях с одинаковым весом -> NULL.
   Повторено через CASE WHEN count(DISTINCT value) = 1. */

-- MTBR/MTBF: Наработка_средняя = (показание на макс. дату - на мин. дату) / (MaxDate - MinDate + 1)
CREATE OR REPLACE VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_calc_oper_time_mtbr AS
with src_oper_time as -- Начало Аналог v_src_oper_time
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
SELECT equipment,
       (max_value - min_value) / (max_date - min_date + 1) AS avg_oper_time   -- Наработка_средняя
FROM (SELECT equipment,
             max(meas_date) AS max_date,
             min(meas_date) AS min_date,
             CASE WHEN count(DISTINCT CASE WHEN rk_min = 1 THEN counter_value END) = 1
                  THEN max(CASE WHEN rk_min = 1 THEN counter_value END) END AS min_value,
             CASE WHEN count(DISTINCT CASE WHEN rk_max = 1 THEN counter_value END) = 1
                  THEN max(CASE WHEN rk_max = 1 THEN counter_value END) END AS max_value
      FROM (SELECT equipment, meas_date, counter_value,
                   rank() OVER (PARTITION BY equipment ORDER BY meas_date)      AS rk_min,
                   rank() OVER (PARTITION BY equipment ORDER BY meas_date DESC) AS rk_max
            FROM src_oper_time
            WHERE point_name = 'Наработка с начала эксплуатации') s
      GROUP BY equipment) a;
-- v_calc_oper_time_mtbr (S2T: https://kb.gazprom-neft.local/pages/viewpage.action?pageId=850919657)
COMMENT ON VIEW dp_rid_dmt_cns_corp_pixbi_brd_toro.v_calc_oper_time_mtbr IS 'Средняя наработка ЕО (MTBR/MTBF) по точке «Наработка с начала эксплуатации»';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_calc_oper_time_mtbr."equipment" IS 'Единица оборудования';
COMMENT ON COLUMN dp_rid_dmt_cns_corp_pixbi_brd_toro.v_calc_oper_time_mtbr."avg_oper_time" IS 'Наработка_средняя';
