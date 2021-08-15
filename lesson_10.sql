-- 1. Проанализировать какие запросы могут выполняться наиболее часто в процессе работы приложения и 
-- добавить необходимые индексы.
-- Таблица	Описание				
-- communities	Сообщества пользователей				
-- communities_users	Связывает пользователей с сообществами	many	many		
-- likes	Связывает таблицу пользователей, таблицу entities и entity_types	many	many	from_user_id	Кто поставил лайк из таблицы пользователей
-- 				entity_id	Номер строки таблицы, которой поставили лайк
-- 				entity_name	Название таблицы, которой поставили лайк
-- entities 	лишняя таблица				
-- entity_types	Таблица описания других таблиц, используемых в качестве сущностей				
-- friendship	связывает 2 пользователей из таблицы users	many	many	requested_at	запрос на дружбу
-- 				confirmed_at	подтверждение дружбы
-- media	Ссылки на медиафайлы			media_type	Тип файла
-- 				link	Ссылка
-- media_types	Типы медиафайлов			type	varchar(100)
-- messages	Связывает от пользователя к пользователю сообщения			Все о сообщениях	
-- messages_media	Связывает таблицу messages с прикрепленными к messages файлами из таблицы media				
-- post	Связывает таблицу communities и users с posts и posts_media				
-- profiles	расширение таблицы users				
-- users					Не индексирован birthdate

 -- Проиндексируем следующие поля по странам, городам, ФИО, датам рождения и заголовкам сообщений:

CREATE INDEX ix_profiles_country ON profiles(country); 
CREATE INDEX ix_profiles_last_name ON profiles(last_name); 
CREATE INDEX ix_profile_first_last_name ON profiles(first_name, last_name);
CREATE INDEX ix_profiles_birth_date ON profiles(birth_date); 
CREATE INDEX ix_profiles_city ON profiles(city); 
CREATE INDEX ix_communities_name ON communities(name);
CREATE INDEX ix_messages_message_header ON messages(message_header);

-- 2. Задание на оконные функции. Построить запрос, который будет выводить следующие столбцы:
--
-- имя группы;
-- среднее количество пользователей в группах;
-- самый молодой пользователь в группе;
-- самый старший пользователь в группе;
-- общее количество пользователей в группе;
-- всего пользователей в системе;
-- отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100.
-- 
SELECT p.country , p.city, count(1) FROM profiles p GROUP BY country, city;

;
SELECT * FROM (
SELECT DISTINCT 
	mt.type_name,
	SUM(m.metadata->>"$.size") OVER (w) AS part_size,
	SUM(m.metadata->>"$.size") OVER () AS part_size1,
	SUM(m.metadata->>"$.size") OVER (w) / SUM(m.metadata->>"$.size") OVER () * 100 AS percentage,
	ROW_NUMBER() OVER(w) AS part_rn
FROM media m
INNER JOIN media_types mt on(
	m.media_type = mt.id 
) WINDOW w AS (PARTITION BY mt.type_name)
)  t1 WHERE t1.part_rn IN (1, 2, 3);

-- Подготовка таблиц для задания 2.
ALTER TABLE posts DROP CONSTRAINT fk_post_community_id;
ALTER TABLE communities_users DROP CONSTRAINT fk_cu_community_id;

UPDATE `communities_users` SET community_id = rand() * 6;
UPDATE `posts` SET community_id = rand() * 6;

ALTER TABLE `posts` ADD CONSTRAINT fk_post_community_id FOREIGN KEY(community_id) REFERENCES communities(id);--
ALTER TABLE `communities_users` ADD CONSTRAINT fk_cu_comunities_id FOREIGN KEY (community_id) REFERENCES communities(id);

SELECT u.id AS u_id, c.name AS c_name FROM users u, communities c, communities_users cu WHERE cu.community_id = c.id AND  cu.user_id = u.id;
SELECT c.name, count(u.id) FROM users u, communities c, communities_users cu WHERE cu.community_id = c.id AND  cu.user_id = u.id GROUP BY c.name;

-- SELECT 
-- 		c.name, 
-- 		u.id,
-- 		(
-- 			SELECT count(1)	FROM users
-- 		) 
-- 		/
-- 		(
-- 			SELECT 
-- 				count(1) 
-- 			FROM 	
-- 						communities 
-- 		) AS average_count,
-- 		max(p.birth_date) OVER(PARTITION BY c.name) AS youngest,
-- 		min(p.birth_date) OVER(PARTITION BY c.name) AS oldest,
-- 		count(1) over(PARTITION BY c.name) AS count_users_by_group,
-- 		count(1) over() AS all_users,
-- 		count(1) over(PARTITION BY c.name) / count(1) over() * 100 AS percentage_users 
-- 	FROM 
-- 		users u,
-- 		communities c, 
-- 		communities_users cu,
-- 		profiles p
-- 	WHERE 
-- 		cu.community_id = c.id 
-- 		AND  
-- 		cu.user_id = u.id
-- 		AND 
-- 		p.user_id = u.id;
-- 		
-- 	SELECT 
-- 			c.name,
-- 			p.first_name, 
--  			p.last_name, 
--  			max(p.birth_date) OVER(PARTITION BY c.name) AS youngest
-- 		FROM 
-- 			profiles p, 
-- 			communities c,
-- 			users u,
-- 			communities_users cu 
-- 		WHERE 
-- 			u.id = p.user_id 
-- 		AND 
-- 			cu.user_id = u.id 
-- 		AND 
-- 			cu.community_id = c.id;
-- 			
	SELECT 
		c.name, 
		u.id,
		count(u.id) over()
		/  
		(SELECT count(c.name) FROM communities c ) AS average_count,
		max(p.birth_date) OVER(PARTITION BY c.name) AS youngest,
		min(p.birth_date) OVER(PARTITION BY c.name) AS oldest,
		count(1) over(PARTITION BY c.name) AS count_users_by_group,
		count(1) over() AS all_users,
		count(1) over(PARTITION BY c.name) / count(1) over() * 100 AS percentage_users 
	FROM 
		users u,
		communities c, 
		communities_users cu,
		profiles p
	WHERE 
		cu.community_id = c.id 
		AND  
		cu.user_id = u.id
		AND 
		p.user_id = u.id;
		
	SELECT 
			c.name,
			p.first_name, 
 			p.last_name, 
 			max(p.birth_date) OVER(PARTITION BY c.name) AS youngest
		FROM 
			profiles p, 
			communities c,
			users u,
			communities_users cu 
		WHERE 
			u.id = p.user_id 
		AND 
			cu.user_id = u.id 
		AND 
			cu.community_id = c.id;
			
		SELECT count(c.name) FROM communities c ;