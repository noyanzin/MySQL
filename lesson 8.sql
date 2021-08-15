-- Пусть задан некоторый пользователь. 
-- Из всех друзей этого пользователя найдите человека, 
-- который больше всех общался с нашим пользователем.
-- Условно USER 1
-- Притягиваем за уши 1 и 16 user. Устанавливаем для них 20 доставленных друг другу сообщений.
/* UPDATE messages 
	SET to_user_id  = 16,
			is_delivered =1,
			from_user_id = 1
WHERE is_delivered = 0
LIMIT 10;
UPDATE messages 
	SET to_user_id  = 1,
			is_delivered =1,
			from_user_id = 16
WHERE is_delivered = 0
LIMIT 10;
SELECT * FROM users u ;
SELECT  * FROM friendship f WHERE friendship_status = 'FRIENDSHIP' AND (user_id = 1 OR friend_id = 1);
*/

-- Решение:
-- Получаем всех друзей user = 1
CREATE VIEW friends_user_1 AS 
SELECT  user_id AS u_id , friend_id AS f_id FROM friendship f WHERE friendship_status = 'FRIENDSHIP' AND user_id = 1
UNION
SELECT  friend_id AS u_id ,user_id  AS f_id  FROM friendship f WHERE friendship_status = 'FRIENDSHIP' AND friend_id = 1;

-- Получаем все сообщения от и к пользователю 1
CREATE VIEW messages_user_1 AS 
SELECT id, from_user_id AS u_id, to_user_id AS to_u_id FROM messages m WHERE from_user_id = 1 AND is_delivered = 1
UNION
SELECT id, to_user_id AS u_id, from_user_id AS to_u_id  FROM messages m WHERE to_user_id = 1 AND is_delivered = 1;

SELECT * FROM messages_user_1;
SELECT * FROM friends_user_1;

SELECT f.f_id, count(1) AS c FROM 
	friends_user_1 f
	INNER JOIN
	messages_user_1 m 
	ON f.u_id = m.u_id AND f.f_id = m.to_u_id 
	GROUP  BY m.to_u_id ORDER BY c DESC LIMIT 1;

-- Пользователь 1 переписывался больше всего с пользователем 16, который является его другом. 11 сообщений в обе стороны.

-- Решение задачи 2.
-- 2. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
DROP VIEW IF EXISTS sum_young_10;
CREATE VIEW sum_young_10 AS SELECT SUM(is_positive) AS summa FROM 
 	likes l 
 	INNER JOIN 
 	users u
	ON is_positive = 1 
	AND entity_name = 'users'
	AND l.entity_id = u.id GROUP BY u.birthdate ORDER BY u.birthdate DESC LIMIT 10;
	SELECT SUM(summa) FROM sum_young_10;

-- 3.Определить кто больше поставил лайков (всего) - мужчины или женщины?

DROP VIEW IF EXISTS users_likes;
CREATE VIEW users_likes AS SELECT p.gender FROM 
likes l 
INNER JOIN 
users u
INNER JOIN 
profiles p 
	ON is_positive = 1 
	AND l.from_user_id = u.id
	AND p.user_id = u.id;

SELECT * FROM users_likes;

SELECT
    SUM(CASE WHEN gender = 'F' THEN 1 ELSE -1 END) AS 'Female'
FROM users_likes ;

-- Женщин поставило лайки на 17 меньше, чем мужчин.


-- Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
-- (явно указать критерий, по которому вы оцениваете активность в запросе).

DROP VIEW IF EXISTS activity;
CREATE VIEW activity AS SELECT
	m.from_user_id
FROM
	messages m
UNION ALL
SELECT
	p.user_id AS from_user_id
FROM
	posts p
UNION ALL
SELECT
	l.from_user_id
FROM
	likes l;

-- Критерий: количество сообщений в постах плюс количество лайков
SELECT  a.from_user_id AS inactive_user, COUNT(a.from_user_id) AS actions FROM activity a GROUP BY a.from_user_id ORDER  BY actions LIMIT 10;
-- Выведен список 10 самых неактивных пользователей.