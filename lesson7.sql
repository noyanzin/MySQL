-- 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.

SELECT name FROM users, orders WHERE users.id = orders.user_id GROUP BY orders.created_at;

-- 2. Выведите список товаров products и разделов catalogs, который соответствует товару.;

SELECT products.name, catalogs.name FROM products, catalogs WHERE products.catalog_id = catalogs.id;

-- 3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.

DROP TABLE IF EXISTS `flights`;
CREATE TABLE `flights`(
	`id`  INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`from` VARCHAR(50),
	`to` VARCHAR(50)
	);

DROP TABLE IF EXISTS `cities`;
CREATE TABLE `cities` (
`label` VARCHAR(50),
`name` VARCHAR(50)
);

INSERT INTO `flights`(`id`, `from`, `to`) VALUES 
('1', 'moscow', 'omsk'),
('2', 'novgorod', 'kazan'),
('3', 'irkutsk', 'moscow'),
('4', 'omsk', 'irkutsk'),
('5', 'moscow', 'kazan');

INSERT INTO `cities`(label, name) VALUES
('moscow', 'Москва'),
('irkutsk', 'Иркутск'),
('novgorod', 'Новгород'),
('kazan', 'Казань'),
('omsk', 'Омск');

SELECT * FROM flights;
SELECT * FROM cities;
SELECT t1.`id`, `from_rus`, `to_rus` FROM 
(SELECT `flights`.`id` AS id, `cities`.`name` AS `from_rus` FROM `flights`, `cities` WHERE flights.`from`= cities.`label`) AS t1
,
(SELECT `flights`.`id` AS id, `cities`.`name` AS `to_rus` FROM `flights`, `cities` WHERE flights.`to` = cities.`label`) AS t2
WHERE `t1`.`id` = `t2`.`id` ORDER BY id
