-- Последовательная воронка с окном 7 дней
WITH signup AS (
 SELECT user_id, MIN(event_time) AS signup_at FROM events WHERE event_name='signup' GROUP BY user_id
), verified AS (
 SELECT s.user_id, MIN(e.event_time) AS verified_at FROM signup s JOIN events e ON e.user_id=s.user_id
 WHERE e.event_name='verify' AND e.event_time>=s.signup_at
 AND e.event_time<=datetime(s.signup_at,'+7 days') GROUP BY s.user_id
), activated AS (
 SELECT v.user_id, MIN(e.event_time) AS activated_at FROM verified v
 JOIN signup s ON s.user_id=v.user_id JOIN events e ON e.user_id=v.user_id
 WHERE e.event_name='activate' AND e.event_time>=v.verified_at
 AND e.event_time<=datetime(s.signup_at,'+7 days') GROUP BY v.user_id
)
SELECT u.channel, COUNT(*) AS signups, COUNT(v.user_id) AS verified, COUNT(a.user_id) AS activated,
 ROUND(100.0*COUNT(v.user_id)/COUNT(*),2) AS signup_to_verify_pct,
 ROUND(100.0*COUNT(a.user_id)/NULLIF(COUNT(v.user_id),0),2) AS verify_to_activate_pct,
 ROUND(100.0*COUNT(a.user_id)/COUNT(*),2) AS total_conversion_pct
FROM users u JOIN signup s ON s.user_id=u.user_id
LEFT JOIN verified v ON v.user_id=u.user_id LEFT JOIN activated a ON a.user_id=u.user_id
GROUP BY u.channel ORDER BY total_conversion_pct DESC;
