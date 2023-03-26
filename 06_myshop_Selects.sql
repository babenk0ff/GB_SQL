/* Выборка #1
Определить пользователя, потратившего больше всего денег, и сколько именно он потратил.
*/

SELECT
	CONCAT(p.firstname, ' ', p.lastname) AS name,
	SUM(op.price * op.products_count) AS total
FROM profiles p
JOIN orders o ON o.user_id = p.user_id
JOIN orders_products op ON op.order_id = o.id 
WHERE o.status = 'Выполнен'
GROUP BY o.id 
ORDER BY total DESC 
LIMIT 1;


/* Выборка #2
Определить пять самых популярных товаров.
*/

SELECT 
	p.name,
	s.name,
	SUM(op.products_count) AS total_count
FROM products p 
JOIN categories s ON s.id = p.section_id 
JOIN orders_products op ON op.product_id = p.id
JOIN orders o ON o.id = op.order_id 
WHERE o.status = 'Выполнен'
GROUP BY op.product_id 
ORDER BY total_count DESC 
LIMIT 5;


/* Выборка #3
Определить самый прибыльный год.
*/

SELECT 
	YEAR(o.created_at) AS `year`,
	SUM(op.price * op.products_count) AS total
FROM orders o
JOIN orders_products op ON op.order_id = o.id 
WHERE o.status = 'Выполнен'
GROUP BY `year`
ORDER BY total DESC
LIMIT 1;


/* Выборка #4
Пользователь, написавший больше всего отзывов с наиболее низким рейтингом.
*/

SELECT
	CONCAT(p.firstname, ' ', p.lastname) AS name,
	count(*) AS cnt
FROM reviews r 
JOIN profiles p ON p.user_id = r.user_id 
WHERE r.rating = (SELECT rating FROM reviews ORDER BY rating LIMIT 1)
GROUP BY r.user_id 
ORDER BY cnt DESC
LIMIT 1;


/* Выборка #5
Товар с самым высоким рейтингом за заданный год (2003).
*/

-- JOIN
SELECT 
	p.name,
	s.name AS category
FROM reviews r 
JOIN products p ON p.id = r.product_id 
JOIN categories s ON s.id = p.section_id 
WHERE YEAR(r.created_at) = 2003
ORDER BY r.rating DESC 
LIMIT 1;


-- Сложный запрос
SELECT 
	p.name, 
	s.name AS category
FROM 
	products p, 
	categories s	
WHERE p.id = (
	SELECT 
		product_id
	FROM reviews
	WHERE YEAR(created_at) = 2003
	ORDER BY rating	DESC
	LIMIT 1
	)
AND p.section_id = s.id
