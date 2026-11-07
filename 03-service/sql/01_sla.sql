-- Сроки закрытия и соблюдение SLA
SELECT t.name, COUNT(*) AS closed_tickets,
 ROUND(AVG((julianday(k.closed_at)-julianday(k.created_at))*24),2) AS avg_resolution_hours,
 SUM(CASE WHEN k.closed_at<=datetime(k.created_at,'+24 hours') THEN 1 ELSE 0 END) AS within_sla,
 ROUND(100.0*SUM(CASE WHEN k.closed_at<=datetime(k.created_at,'+24 hours') THEN 1 ELSE 0 END)/COUNT(*),2) AS sla_pct
FROM tickets k JOIN teams t ON t.team_id=k.team_id
WHERE k.closed_at IS NOT NULL AND k.closed_at<='2026-10-31 23:59:59'
GROUP BY t.name ORDER BY sla_pct;
