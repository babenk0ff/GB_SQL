-- 1) Корзина с общей суммой цен товаров в зависимости от их количества
CREATE OR REPLACE VIEW v_carts
AS 
SELECT 
	cp.cart_id,
	p.name,
	p.price,
	cp.products_count,
	(p.price * cp.products_count) AS `sum`
FROM carts_products cp
JOIN products p ON p.id = cp.product_id
ORDER BY cp.cart_id;


SELECT cart_id, name, price, products_count, `sum` FROM v_carts;


-- 2) Список всех полных отзывов (с прикрипленными фотографиями)
CREATE OR REPLACE VIEW v_reviews
AS
SELECT 
	p.name,
	r.rating,
	r.body,
	rp.photo_id 
FROM reviews r
JOIN products p ON p.id = r.product_id 
LEFT JOIN reviews_photos rp ON r.id = rp.review_id
ORDER BY r.id;


SELECT name, rating, body, photo_id FROM v_reviews;