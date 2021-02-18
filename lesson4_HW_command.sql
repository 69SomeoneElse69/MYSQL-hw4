ALTER TABLE profiles MODIFY COLUMN gender ENUM('M', 'F');

ALTER TABLE communities ADD COLUMN owner_id INT UNSIGNED NOT NULL AFTER id;

UPDATE users SET updated_at = NOW() WHERE updated_at < created_at; 
UPDATE profiles SET updated_at = NOW() WHERE updated_at < created_at;    
UPDATE media_types SET updated_at = NOW() WHERE updated_at < created_at; 
UPDATE media SET updated_at = NOW() WHERE updated_at < created_at;
UPDATE friendship_statuses SET updated_at = NOW() WHERE updated_at < created_at;

UPDATE friendship SET updated_at = NOW() WHERE updated_at < created_at; 
UPDATE friendship SET requested_at = NOW() WHERE confirmed_at < requested_at ;

UPDATE communities SET updated_at = NOW() WHERE updated_at < created_at;    

UPDATE messages SET 
  from_user_id = FLOOR(1 + RAND() * 100),
  to_user_id = FLOOR(1 + RAND() * 100);

UPDATE media SET user_id = FLOOR(1 + RAND() * 100);


-- Создаём временную таблицу форматов медиафайлов
CREATE TEMPORARY TABLE extensions (name VARCHAR(10));

-- Заполняем значениями
INSERT INTO extensions VALUES ('jpeg'), ('avi'), ('mpeg'), ('png');

-- Обновляем ссылку на файл
UPDATE media SET filename = CONCAT(
  'http://dropbox.net/vk/',
  filename,
  '.',
  (SELECT name FROM extensions ORDER BY RAND() LIMIT 1)
);

-- Обновляем размер файлов
UPDATE media SET size = FLOOR(10000 + (RAND() * 1000000)) WHERE size < 1000;

-- Заполняем метаданные
UPDATE media SET metadata = CONCAT('{"owner":"', 
  (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = user_id),
  '"}');  

-- Возвращаем столбцу метеданных правильный тип, если нужно
ALTER TABLE media MODIFY COLUMN metadata JSON;

-- Удаляем все типы
DELETE FROM media_types;
-- DELETE не сбрасывает счётчик автоинкрементирования,
-- поэтому применим TRUNCATE
TRUNCATE media_types;

-- Добавляем нужные типы
INSERT INTO media_types (name) VALUES
  ('photo'),
  ('video'),
  ('audio')
;

-- Анализируем данные
SELECT * FROM media mt LIMIT 10;

-- Обновляем данные для ссылки на тип
UPDATE media SET media_type_id = FLOOR(1 + RAND() * 3);

-- Обновляем ссылки на друзей
UPDATE friendship SET 
  friend_id = FLOOR(1 + RAND() * 100);

-- Исправляем случай когда user_id = friend_id
UPDATE friendship SET friend_id = friend_id + 1 WHERE user_id = friend_id;

-- Очищаем таблицу
TRUNCATE friendship_statuses;

-- Вставляем значения статусов дружбы
INSERT INTO friendship_statuses (name) VALUES
  ('Requested'),
  ('Confirmed'),
  ('Rejected');
 
-- Обновляем ссылки на статус 
UPDATE friendship SET friendship_status_id = FLOOR(1 + RAND() * 3); 

-- Удаляем часть групп
DELETE FROM communities WHERE id > 20;

-- Добавляем владельцев групп 
UPDATE communities SET owner_id = FLOOR(1 + RAND() * 100); 

-- Обновляем значения community_id
UPDATE communities_users SET community_id = FLOOR(1 + RAND() * 20);


-- Практическое задание по теме “CRUD - операции”

-- 1.Повторить все действия по доработке БД vk на своих данных.
-- Необходимо проанализировать данные каждой таблицы и исправить 
-- ошибки и несоответствия, в том числе по столбцам связи,
-- используя команды CRUD  

-- 2.Подобрать сервис который будет служить основой для вашей курсовой работы.

-- 	Сервис яндекс фото

-- 3(по желанию) Предложить свою реализацию лайков и постов.

