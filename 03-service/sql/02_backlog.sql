-- Открытые заявки на фиксированную дату
SELECT t.name, COUNT(*) AS open_tickets,
 SUM(CASE WHEN datetime(k.created_at,'+24 hours')<'2026-10-31 23:59:59' THEN 1 ELSE 0 END) AS overdue_tickets
FROM tickets k JOIN teams t ON t.team_id=k.team_id
WHERE k.created_at<='2026-10-31 23:59:59'
AND (k.closed_at IS NULL OR k.closed_at>'2026-10-31 23:59:59')
GROUP BY t.name ORDER BY overdue_tickets DESC;
