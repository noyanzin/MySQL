-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

SELECT * FROM shop.users;
SELECT * FROM sample.users;
TRUNCATE TABLE sample.users;

START TRANSACTION;
	INSERT INTO sample.users SELECT * FROM shop.users WHERE id = 1;
	DELETE FROM shop.users WHERE id = 1;
COMMIT;

-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products 
-- и соответствующее название каталога name из таблицы catalogs.

USE shop;
CREATE OR REPLACE VIEW product_catalogs AS
(SELECT 
	`p`.`name` AS `product`,
	`c`.`name` AS `catalog`
FROM 
	`products` AS `p` 
INNER JOIN 
	`catalogs` AS `c`
ON 
	`p`.`catalog_id` = `c`.`id`)
;

SELECT * FROM product_catalogs;

-- II. Администрирование. 
 
-- 1. Создайте двух пользователей которые имеют доступ к базе данных shop. 
-- Первому пользователю shop_read должны быть доступны только запросы на чтение данных, 
-- второму пользователю shop — любые операции в пределах базы данных shop.

CREATE USER 'user_r'@'localhost';
GRANT SELECT, SHOW VIEW ON shop.* TO 'user_r'@'localhost';
SHOW DATABASES; 

CREATE USER 'user_rw'@'localhost';
GRANT ALL ON shop.* TO 'user_rw'@'localhost';

-- III. Хранимые процедуры и функции
-- 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, 
-- в зависимости от текущего времени суток.
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
-- с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

USE vk;

DROP FUNCTION IF EXISTS hello;

DELIMITER //

CREATE FUNCTION hello()
RETURNS VARCHAR(50) NO SQL 
BEGIN
DECLARE hour INT;
SET hour = HOUR(NOW());
CASE 
	WHEN hour BETWEEN 0 AND 5 THEN RETURN "Доброй ночи";
	WHEN hour BETWEEN 6 AND 11 THEN RETURN "Доброе утро";
	WHEN hour BETWEEN 12 AND 16 THEN RETURN "Добрый день";
	WHEN hour BETWEEN 17 AND 23 THEN RETURN "Добрый вечер";
END CASE;
END//

DELIMITER  ;
SELECT NOW(), hello();

-- 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием.
-- Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.

USE shop;

DELIMITER //

CREATE TRIGGER validate_name_description_insert BEFORE INSERT ON products
FOR EACH ROW
BEGIN
  IF NEW.name IS NULL AND NEW.description IS NULL THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Both name and descripion are NULL';
  END IF;
END//

INSERT INTO products (name, description, price, catalog_id)
VALUES ('ASUS PRIME 222','HDMI 4 ports, 3 USB', 9360.0, 2)//

INSERT INTO products (name, description, price, catalog_id)
VALUES (NULL, NULL, 9360.0, 2)//

CREATE TRIGGER validate_name_description_update BEFORE UPDATE ON products
FOR EACH ROW BEGIN
	IF NEW.name IS NULL AND NEW.description IS NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Both name and descripion are NULL';
	END IF;
END//

DELIMITER  ;