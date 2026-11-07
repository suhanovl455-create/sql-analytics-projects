-- Доля покупателей с повторными покупками за весь период
WITH customer_orders AS (
 SELECT customer_id, COUNT(*) AS n FROM orders WHERE status='paid' GROUP BY customer_id
)
SELECT COUNT(*) AS paying_customers,
 SUM(CASE WHEN n>=2 THEN 1 ELSE 0 END) AS repeat_customers,
 ROUND(100.0*SUM(CASE WHEN n>=2 THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2) AS repeat_customer_pct
FROM customer_orders;
