-- Проверки качества событий
SELECT 'duplicate_user_event_groups' AS check_name, COUNT(*) AS issue_count FROM (
 SELECT user_id,event_name FROM events GROUP BY user_id,event_name HAVING COUNT(*)>1
)
UNION ALL
SELECT 'events_before_signup',COUNT(*) FROM events e JOIN users u ON u.user_id=e.user_id
WHERE e.event_time < u.signup_date;
