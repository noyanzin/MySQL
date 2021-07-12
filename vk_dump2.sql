DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;



USE vk;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `phone` VARCHAR(100) NOT NULL UNIQUE,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
  `id`  INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `birth_date` DATE,
  `user_id` INT UNSIGNED DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `profile_status` enum('ONLINE','OFFLINE','INACTIVE') NOT NULL DEFAULT 'ONLINE',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS `comunities_users`;
CREATE TABLE `comunities_users` (
  `comunity_id` INT UNSIGNED DEFAULT NULL,
  `user_id` int UNSIGNED DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS `comunities`;
CREATE TABLE `comunities` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE if EXISTS `posts`;
CREATE TABLE `posts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL,
  `comunity_id` INT UNSIGNED DEFAULT NULL,
  `post_content` TEXT,
  `visibility_value` VARCHAR(100) DEFAULT NULL COMMENT "Ссылка на вариант видимости поста",
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);	

DROP TABLE IF EXISTS `visibility`;
 CREATE TABLE `visibility` (
	`value` VARCHAR(100) NOT NULL UNIQUE
    ) COMMENT 'Справочник вариантов видимости объектов на странице.';
    

 
DROP TABLE IF EXISTS `media`;
CREATE TABLE `media`(
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `media_type` VARCHAR(100) NOT NULL,
    `link` VARCHAR(1000) NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
    
DROP TABLE IF EXISTS `media_types`;
CREATE TABLE `media_types`(
	`type` VARCHAR(100) NOT NULL UNIQUE
    );
    
 
DROP TABLE IF EXISTS `posts_media`;
CREATE TABLE `posts_media` (
	`post_id` INT UNSIGNED NOT NULL,
    `media_id` INT UNSIGNED NOT NULL,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (post_id, media_id)
    );
    

DROP TABLE IF EXISTS `messages_media`;
CREATE TABLE `messages_media` (
	`message_id` INT UNSIGNED NOT NULL,
	`media_id` INT UNSIGNED NOT NULL,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (message_id, media_id)
    );

DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `from_user_id` INT UNSIGNED DEFAULT NULL,
  `to_user_id` INT UNSIGNED DEFAULT NULL,
  `message_header` VARCHAR(255) DEFAULT NULL,
  `message_body` TEXT,
  `sent_flag` tinyint DEFAULT NULL,
  `recieved_flag` tinyint DEFAULT NULL,
  `edited_flag` tinyint DEFAULT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

); 


DROP TABLE IF EXISTS `entity_types`;
CREATE TABLE entity_types (
	`name` VARCHAR(100) NOT NULL UNIQUE,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

    ) COMMENT 'Справочная таблица с перечнем сущностей, которым можно поставить лайк';
    
DROP TABLE IF EXISTS `likes`;
CREATE TABLE `likes` ( 
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `from_user_id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL, 
  `entity_name` VARCHAR(128) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_positive` tinyint(1) DEFAULT NULL
);


DROP TABLE IF EXISTS `entities`;
CREATE TABLE `entities` (
	`entity_id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `entity_name` VARCHAR(128) NOT NULL,
    `link` VARCHAR(1000) NOT NULL, 
    `comment_message` TEXT NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
 );
   
 



DROP TABLE IF EXISTS `friendship`;
CREATE TABLE `friendship` (
  `user_id` INT UNSIGNED DEFAULT NULL,
  `friend_id` INT UNSIGNED DEFAULT NULL,
  `friendship_status` varchar(100) DEFAULT NULL,
  `requested_at` datetime DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Все связи таблиц 
ALTER TABLE `posts` ADD CONSTRAINT fk_post_user_id FOREIGN KEY (user_id) REFERENCES users(id);--
ALTER TABLE `posts` ADD CONSTRAINT fk_post_comunity_id FOREIGN KEY(comunity_id) REFERENCES comunities(id);--
ALTER TABLE `posts` ADD CONSTRAINT fk_post_visibility_value FOREIGN KEY(visibility_value) REFERENCES visibility(`value`);--
ALTER TABLE `messages_media` ADD CONSTRAINT fk_nm_media_id FOREIGN KEY (media_id) REFERENCES media(id); --
ALTER TABLE `messages_media` ADD CONSTRAINT fk_nm_message_id FOREIGN KEY (message_id) REFERENCES messages(id); --
ALTER TABLE `media` ADD CONSTRAINT fk_media_type FOREIGN KEY (media_type) REFERENCES media_types(`type`);
ALTER TABLE `posts_media` ADD CONSTRAINT fk_pm_media_id FOREIGN KEY (media_id) REFERENCES media(id);
ALTER TABLE `posts_media` ADD CONSTRAINT fk_pm_post_id FOREIGN KEY (post_id) REFERENCES posts(id);
ALTER TABLE `likes` ADD CONSTRAINT fk_likes_entity_name FOREIGN KEY (entity_name) REFERENCES entity_types(`name`);
ALTER TABLE `profiles` ADD CONSTRAINT fk_profiles_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE `friendship` ADD CONSTRAINT fk_friendship_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE `friendship` ADD CONSTRAINT fk_friendship_friend_id FOREIGN KEY (friend_id) REFERENCES users(id);
ALTER TABLE `messages` ADD CONSTRAINT fk_messages_from_user_id FOREIGN KEY (from_user_id) REFERENCES users(id);
ALTER TABLE `messages` ADD CONSTRAINT fk_messages_to_user_id FOREIGN KEY (to_user_id) REFERENCES users(id);
ALTER TABLE `comunities_users` ADD CONSTRAINT fk_comunities_users_comunities_id FOREIGN KEY (comunity_id) REFERENCES comunities(id);
ALTER TABLE `comunities_users` ADD CONSTRAINT fk_comunities_users_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE `users` ADD CONSTRAINT phone_check CHECK (REGEXP_LIKE(phone,'\\+7[0-9]{10}$'));

-- C R U D
-- ALTER TABLE profiles DROP COLUMN gender;
ALTER TABLE profiles ADD COLUMN gender ENUM('M','F');
