-- Практическое задание по теме “Оптимизация запросов”
-- 1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, 
-- catalogs и products в таблицу logs помещается время и дата создания записи, название таблицы, 
-- идентификатор первичного ключа и содержимое поля name.

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
	created_at DATETIME NOT NULL,
	table_name VARCHAR(45) NOT NULL,
	subj_id INT UNSIGNED  NOT NULL,
	name_value VARCHAR(45) NOT NULL
) ENGINE = ARCHIVE;

DROP TRIGGER IF EXISTS on_insert_users_to_log;
CREATE TRIGGER on_insert_users_to_log AFTER INSERT ON users
FOR EACH ROW 
INSERT INTO logs(created_at, table_name, subj_id, name_value) VALUES (NOW(), 'users', NEW.`id`,NEW.`name`);

DROP TRIGGER IF EXISTS on_insert_catalogs_to_log;
CREATE TRIGGER on_insert_catalogs_to_log AFTER INSERT ON catalogs
FOR EACH ROW 
INSERT INTO logs(created_at, table_name, subj_id, name_value) VALUES (NOW(), 'catalogs', NEW.`id`,NEW.`name`);

DROP TRIGGER IF EXISTS on_insert_products_to_log;
CREATE TRIGGER on_insert_products_to_log AFTER INSERT ON products
FOR EACH ROW 
INSERT INTO logs(created_at, table_name, subj_id, name_value) VALUES (NOW(), 'products', NEW.`id`,NEW.`name`);

INSERT INTO users(`name`,`birthday_at`) VALUES ('Mark','1974-07-26');
INSERT INTO catalogs(`name`) VALUES ('Блоки питания');
INSERT INTO products(`name`) VALUE ('Arduino Uno');


-- Практическое задание по теме “NoSQL”
-- 1. В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.

-- Открываем описание REDIS и читаем возможные варианты:
-- 1. Binary-safe strings.
-- 2. Lists: collections of string elements sorted according to the order of insertion. They are basically linked lists.
-- 3. Sets: collections of unique, unsorted string elements.
-- 4. Sorted sets, similar to Sets but where every string element is associated to a floating number value, called score. 
-- The elements are always taken sorted by their score, so unlike Sets it is possible to retrieve a range of elements 
-- (for example you may ask: give me the top 10, or the bottom 10).
-- 5. Hashes, which are maps composed of fields associated with values. 
-- Both the field and the value are strings. This is very similar to Ruby or Python hashes.
-- 6. Bit arrays (or simply bitmaps): it is possible, using special commands, 
-- to handle String values like an array of bits: you can set and clear individual bits, count all the bits set to 1,
-- find the first set or unset bit, and so forth.
-- 7. HyperLogLogs: this is a probabilistic data structure which is used in order to estimate the cardinality of a set. 
-- Don't be scared, it is simpler than it seems... See later in the HyperLogLog section of this tutorial.

-- Из 7 вариантов наиболее подходит для поставленной задачи SORTED SET, который сразу сортирует SET по значению.
-- Им и воспользуемся.

-- Добавим в коллекцию 3 IP адреса:
-- 127.0.0.1:6379> zadd ip 0 192.168.120.10 0 192.168.120.11 0 192.168.120.12
-- (integer) 3
-- Посмотрим на них:
-- 127.0.0.1:6379> zrange ip 0 -1
-- 1) "192.168.120.10"
-- 2) "192.168.120.11"
-- 3) "192.168.120.12"

-- Пусть адрес 192.168.120.10 посетил нас 3 раза, а адрес 192.168.120.11 - 2 раза.
-- Увеличим счетчик посещений 2 адресов:
-- 127.0.0.1:6379> ZINCRBY ip 1 192.168.120.10
-- "1"
-- 127.0.0.1:6379> ZINCRBY ip 1 192.168.120.10
-- "2"
-- 127.0.0.1:6379> ZINCRBY ip 1 192.168.120.10
-- "3"
-- 127.0.0.1:6379> ZINCRBY ip 1 192.168.120.11
-- "1"
-- 127.0.0.1:6379> ZINCRBY ip 1 192.168.120.11
-- "2"

-- Посмотрим, что получилось:
-- 127.0.0.1:6379> zrange ip 0 -1 withscores
-- 1) "192.168.120.12"
-- 2) "0"
-- 3) "192.168.120.11"
-- 4) "2"
-- 5) "192.168.120.10"
-- 6) "3"
-- 127.0.0.1:6379>

--

-- 2.При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу
-- и наоборот, поиск электронного адреса пользователя по его имени.

-- Задачу можно решить составлением 2 ключей для каждой позиции.
-- 127.0.0.1:6379> mset user1@mail.ru User1 user2@mail.ru User2 user3@mail.ru User3
-- И наоборот
-- 127.0.0.1:6379> mset User1 user1@mail.ru User2 user2@mail.ru User3 user3@mail.ru
-- Тогда чтобы найти User1 или user1@mail.ru:
-- 127.0.0.1:6379> get User1
-- "user1@mail.ru"
-- 127.0.0.1:6379> get user1@mail.ru
-- "User1"

-- 3. Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.


-- use products

-- db.products.insertMany([
	
	-- {
	-- 'name': 'Intel Core i3-8100',
	--  'description': 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.',
	--  'price': '7890.00',
	--  'catalog_id': '1'
	-- },
  -- {
  -- 'name': 'Intel Core i5-7400', 
  -- 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 
  -- 'price': '12700.00', 
  -- 'catalog_id','1'
  -- },
--   {
--   'name': 'AMD FX-8320E', 
--   'description': 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 
--   'price': '4780.00', 
--   'catalog_id':'1'
--   },
--   {
--   name: 'AMD FX-8320', 
--   'description':'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 
--   'price':'7120.00'
--   'catalog_id:, 1
--   }
--   ])

-- use catalogs
-- db.catalogs.insertMany([
-- 	{"name": "Процессоры"}, 
-- 	{"name": "Материнские платы"}, 
-- 	{"name": "Видеокарты"},
-- --{"name": "Жесткие диски"}, 
-- 	{"name": "Оперативная память"}
-- 	]) 
-- 	 




