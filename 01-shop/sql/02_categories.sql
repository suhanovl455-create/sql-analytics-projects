-- Продажи по категориям
SELECT p.category, SUM(i.quantity) AS units,
 ROUND(SUM(i.quantity*i.unit_price_kopecks)/100.0,2) AS revenue_rub
FROM orders o JOIN order_items i ON i.order_id=o.order_id
JOIN products p ON p.product_id=i.product_id
WHERE o.status='paid' GROUP BY p.category ORDER BY revenue_rub DESC;
