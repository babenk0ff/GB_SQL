-- Триггер для пересчета сумарной стоимости корзины при обновлении цены товара
DROP TRIGGER IF EXISTS tr_update_price;
DELIMITER $$
CREATE TRIGGER tr_update_price AFTER UPDATE ON products
FOR EACH ROW 
BEGIN
	DECLARE new_sum INT;
	
	SELECT 
		SUM(p.price * cp.products_count)
	FROM carts c 				
	JOIN carts_products cp ON cp.cart_id = c.id 
	JOIN products p ON p.id = cp.product_id 
	WHERE c.id = NEW 
	INTO new_sum;
		
	UPDATE carts 
	SET total_price = new_sum
	WHERE id = NEW.id;
END $$
DELIMITER ;


-- Процедура для очистки содержимого корзины
DROP PROCEDURE IF EXISTS clear_cart;
DELIMITER $$
CREATE PROCEDURE clear_cart(crt_id INT)
BEGIN
	START TRANSACTION;
		DELETE FROM carts_products
		WHERE cart_id = crt_id;
	COMMIT;
END $$
DELIMITER ;	


-- Функция для получения текущей цены товара
DROP FUNCTION IF EXISTS get_product_price;
DELIMITER $$
CREATE FUNCTION get_product_price(prod_id INT)
RETURNS INT NOT DETERMINISTIC
BEGIN
	DECLARE prod_price INT(10);

	SELECT price INTO prod_price FROM products WHERE id = prod_id;
	RETURN prod_price;
END $$
DELIMITER ;


-- Процедура для оформления нового заказа на основе содержимого корзины
DROP PROCEDURE IF EXISTS checkout;
DELIMITER $$
CREATE PROCEDURE shop.checkout(
	from_cart_id INT,
	OUT result_string varchar(100)
)
BEGIN
	DECLARE order_number INT;
	DECLARE is_rollback BIT DEFAULT b'0';
	DECLARE error_code varchar(100);
	DECLARE error_msg varchar(100);
	
	DECLARE is_end INT DEFAULT 0;
	DECLARE order_id, prod_id, prod_count INT;	
	DECLARE cursor_products CURSOR FOR SELECT product_id, products_count 
		FROM carts_products cp 
		WHERE cp.cart_id = from_cart_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_end = 1;

	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
	 		SET is_rollback = b'1';
	 		GET stacked DIAGNOSTICS CONDITION 1
				error_code = RETURNED_SQLSTATE, error_msg = MESSAGE_TEXT;			
		END;

	START TRANSACTION;
		-- Создание нового заказа
		INSERT INTO orders(user_id, status)
		SELECT 
			user_id,
			'Оформлен'
		FROM carts
		WHERE id = from_cart_id
		FOR UPDATE;
	
		SET order_number = last_insert_id();
	
		-- Копирование содержимого корзины в содержимое вновь созданного заказа		
		OPEN cursor_products;
			cursor_loop: LOOP
				FETCH cursor_products INTO prod_id, prod_count;
				IF is_end THEN LEAVE cursor_loop;
				END IF;
				INSERT INTO orders_products(order_id, product_id, price, products_count) 
				VALUES (
					order_number,
					prod_id,
					get_product_price(prod_id),
					prod_count
				);
			END LOOP cursor_loop;
		CLOSE cursor_products;
	
		-- Очистка содержимого корзины
		CALL clear_cart(from_cart_id);
		
		IF is_rollback THEN
			SET result_string = CONCAT('Оформление заказа не удалось. Код ошибки: ', error_code, ', ошибка: ', error_msg);
			ROLLBACK;
		ELSE
			SET result_string = CONCAT('Заказ №', order_number, ' успешно оформлен');
			COMMIT;
		END IF;	
END $$
DELIMITER ;


-- Выполнение процедуры по оформлению нового заказа
CALL checkout(31, @result_string);
SELECT @result_string


INSERT INTO 

SELECT 
	u.id AS user_id,
	c.id AS cart_id,
	cp.product_id,
	o.id AS order_id,
	o.status,
	op.product_id 
FROM users u 
LEFT JOIN carts c ON c.user_id = u.id 
LEFT JOIN carts_products cp ON cp.cart_id = c.id 
LEFT JOIN orders o ON o.user_id = u.id 
LEFT JOIN orders_products op ON op.order_id = o.id 
WHERE u.id = 21










