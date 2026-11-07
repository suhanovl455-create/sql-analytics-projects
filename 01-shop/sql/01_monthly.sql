-- Выручка и средний чек по месяцам
SELECT substr(o.order_date,1,7) AS month,
 COUNT(DISTINCT o.order_id) AS paid_orders,
 ROUND(SUM(i.quantity*i.unit_price_kopecks)/100.0,2) AS revenue_rub,
 ROUND(SUM(i.quantity*i.unit_price_kopecks)/100.0/COUNT(DISTINCT o.order_id),2) AS avg_order_rub
FROM orders o JOIN order_items i ON i.order_id=o.order_id
WHERE o.status='paid' GROUP BY substr(o.order_date,1,7) ORDER BY month;
