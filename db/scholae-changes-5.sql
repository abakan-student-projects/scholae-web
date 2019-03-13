create table Notification
(
  id bigint auto_increment
    primary key,
  userId bigint not null,
  type mediumtext not null,
  status tinyint(4) not null,
  date datetime not null,
  primaryDestination tinyint(4) not null,
  delayBetweenSending int(11) null,
  secondaryDestination tinyint(4) null
);

create table Achievement
(
  id bigint auto_increment
    primary key,
  title varchar(512) not null,
  description text not null,
  category tinyint(4) not null,
  parameters text null
);

create table UserAchievement
(
  id bigint auto_increment
    primary key,
  userId bigint(11) not null,
  achievementId bigint(11) not null,
  grade int(11) not null,
  date datetime not null
);

ALTER TABLE `users` ADD `rating` INT NULL AFTER `lastResultsUpdateDate`;

create table CategoryRating
(
  id bigint auto_increment
    primary key,
  userId bigint(11) not null,
  categoryId bigint(11) not null,
  grade float not null
);

INSERT INTO `achievement` (`id`, `title`, `description`, `category`, `parameters`) VALUES
(NULL, 'Начало пути', 'Решена как минимум одна задача на codeforces', 1, null),
(NULL, 'Категория \"2-SAT\"', 'Достижение за решение задач в категории \"2-SAT\"', 3, 'jy33:achievement.AchievementParameters:0:1i35'),
(NULL, 'Категория \"Бинарный поиск\"', 'Достижение за решение задач в категории \"Бинарный поиск\"', 3, 'jy33:achievement.AchievementParameters:0:1i11'),
(NULL, 'Категория \"Битовые маски\"', 'Достижение за решение задач в категории \"Битовые маски\"', 3, 'jy33:achievement.AchievementParameters:0:1i8'),
(NULL, 'Категория \"Быстрое преобразование Фурье\"', 'Достижение за решение задач в категории \"Быстрое преобразование Фурье\"', 3, 'jy33:achievement.AchievementParameters:0:1i23'),
(NULL, 'Категория \"Геометрия\"', 'Достижение за решение задач в категории \"Геометрия\"', 3, 'jy33:achievement.AchievementParameters:0:1i22'),
(NULL, 'Категория \"Графы\"', 'Достижение за решение задач в категории \"Графы\"', 3, 'jy33:achievement.AchievementParameters:0:1i18'),
(NULL, 'Категория \"Два указателя\"', 'Достижение за решение задач в категории \"Два указателя\"', 3, 'jy33:achievement.AchievementParameters:0:1i27'),
(NULL, 'Категория \"Декартово дерево\"', 'Достижение за решение задач в категории \"Декартово дерево\"', 3, 'jy33:achievement.AchievementParameters:0:1i42'),
(NULL, 'Категория \"Деревья\"', 'Достижение за решение задач в категории \"Деревья\"', 3, 'jy33:achievement.AchievementParameters:0:1i13'),
(NULL, 'Категория \"Динамическое программирование\"', 'Достижение за решение задач в категории \"Динамическое программирование\"', 3, 'jy33:achievement.AchievementParameters:0:1i5'),
(NULL, 'Категория \"Жадные алгоритмы\"', 'Достижение за решение задач в категории \"Жадные алгоритмы\"', 3, 'jy33:achievement.AchievementParameters:0:1i12'),
(NULL, 'Категория \"Задачи на реализацию\"', 'Достижение за решение задач в категории \"Задачи на реализацию\"', 3, 'jy33:achievement.AchievementParameters:0:1i7'),
(NULL, 'Категория \"Запросы на интервалах (отрезках)\"', 'Достижение за решение задач в категории \"Запросы на интервалах (отрезках)\"', 3, 'jy33:achievement.AchievementParameters:0:1i38'),
(NULL, 'Категория \"Игры, функция Шпрага-Гранди\"', 'Достижение за решение задач в категории \"Игры, функция Шпрага-Гранди\"', 3, 'jy33:achievement.AchievementParameters:0:1i29'),
(NULL, 'Категория \"Интерактивные задачи\"', 'Достижение за решение задач в категории \"Интерактивные задачи\"', 3, 'jy33:achievement.AchievementParameters:0:1i37'),
(NULL, 'Категория \"Китайская теорема об остатках\"', 'Достижение за решение задач в категории \"Китайская теорема об остатках\"', 3, 'jy33:achievement.AchievementParameters:0:1i34'),
(NULL, 'Категория \"Комбинаторика\"', 'Достижение за решение задач в категории \"Комбинаторика\"', 3, 'jy33:achievement.AchievementParameters:0:1i20'),
(NULL, 'Категория \"Конструктивные алгоритмы\"', 'Достижение за решение задач в категории \"Конструктивные алгоритмы\"', 3, 'jy33:achievement.AchievementParameters:0:1i14'),
(NULL, 'Категория \"Кратчайшие пути\"', 'Достижение за решение задач в категории \"Кратчайшие пути\"', 3, 'jy33:achievement.AchievementParameters:0:1i3'),
(NULL, 'Категория \"Математика\"', 'Достижение за решение задач в категории \"Математика\"', 3, 'jy33:achievement.AchievementParameters:0:1i15'),
(NULL, 'Категория \"Матрицы\"', 'Достижение за решение задач в категории \"Матрицы\"', 3, 'jy33:achievement.AchievementParameters:0:1i25'),
(NULL, 'Категория \"Метод встречи посередине\"', 'Достижение за решение задач в категории \"Метод встречи посередине\"', 3, 'jy33:achievement.AchievementParameters:0:1i21'),
(NULL, 'Категория \"Наименьший общий предок (LCP)\"', 'Достижение за решение задач в категории \"Наименьший общий предок (LCP)\"', 3, 'jy33:achievement.AchievementParameters:0:1i41'),
(NULL, 'Категория \"Непересекающиеся множества\"', 'Достижение за решение задач в категории \"Непересекающиеся множества\"', 3, 'jy33:achievement.AchievementParameters:0:1i24'),
(NULL, 'Категория \"Особенные задачи\"', 'Достижение за решение задач в категории \"Особенные задачи\"', 3, 'jy33:achievement.AchievementParameters:0:1i19'),
(NULL, 'Категория \"Отсортированное множество\"', 'Достижение за решение задач в категории \"Отсортированное множество\"', 3, 'jy33:achievement.AchievementParameters:0:1i40'),
(NULL, 'Категория \"Паросочетания, теорема Кёнига, вершинные и реберные покрытия в двудольных графах\"', 'Достижение за решение задач в категории \"Паросочетания, теорема Кёнига, вершинные и реберные покрытия в двудольных графах\"', 3, 'jy33:achievement.AchievementParameters:0:1i28'),
(NULL, 'Категория \"Поиск в глубину и подобное\"', 'Достижение за решение задач в категории \"Поиск в глубину и подобное\"', 3, 'jy33:achievement.AchievementParameters:0:1i2'),
(NULL, 'Категория \"Полный перебор\"', 'Достижение за решение задач в категории \"Полный перебор\"', 3, 'jy33:achievement.AchievementParameters:0:1i1'),
(NULL, 'Категория \"Потоки в графах\"', 'Достижение за решение задач в категории \"Потоки в графах\"', 3, 'jy33:achievement.AchievementParameters:0:1i30'),
(NULL, 'Категория \"Разбор выражений\"', 'Достижение за решение задач в категории \"Разбор выражений\"', 3, 'jy33:achievement.AchievementParameters:0:1i32'),
(NULL, 'Категория \"Разделяй и властвуй\"', 'Достижение за решение задач в категории \"Разделяй и властвуй\"', 3, 'jy33:achievement.AchievementParameters:0:1i10'),
(NULL, 'Категория \"Связанные компоненты графа\"', 'Достижение за решение задач в категории \"Связанные компоненты графа\"', 3, 'jy33:achievement.AchievementParameters:0:1i39'),
(NULL, 'Категория \"Сортировки\"', 'Достижение за решение задач в категории \"Сортировки\"', 3, 'jy33:achievement.AchievementParameters:0:1i4'),
(NULL, 'Категория \"Строки\"', 'Достижение за решение задач в категории \"Строки\"', 3, 'jy33:achievement.AchievementParameters:0:1i17'),
(NULL, 'Категория \"Структуры данных\"', 'Достижение за решение задач в категории \"Структуры данных\"', 3, 'jy33:achievement.AchievementParameters:0:1i9'),
(NULL, 'Категория \"Сумма подпоследовательности\"', 'Достижение за решение задач в категории \"Сумма подпоследовательности\"', 3, 'jy33:achievement.AchievementParameters:0:1i43'),
(NULL, 'Категория \"Суффиксные массивы, деревья и автоматы\"', 'Достижение за решение задач в категории \"Суффиксные массивы, деревья и автоматы\"', 3, 'jy33:achievement.AchievementParameters:0:1i31'),
(NULL, 'Категория \"Теория вероятностей\"', 'Достижение за решение задач в категории \"Теория вероятностей\"', 3, 'jy33:achievement.AchievementParameters:0:1i26'),
(NULL, 'Категория \"Теория расписаний\"', 'Достижение за решение задач в категории \"Теория расписаний\"', 3, 'jy33:achievement.AchievementParameters:0:1i36'),
(NULL, 'Категория \"Теория чисел\"', 'Достижение за решение задач в категории \"Теория чисел\"', 3, 'jy33:achievement.AchievementParameters:0:1i6'),
(NULL, 'Категория \"Тернарный поиск\"', 'Достижение за решение задач в категории \"Тернарный поиск\"', 3, 'jy33:achievement.AchievementParameters:0:1i33'),
(NULL, 'Категория \"Хэширование\"', 'Достижение за решение задач в категории \"Хэширование\"', 3, 'jy33:achievement.AchievementParameters:0:1i16'),
(NULL, 'Первая сотня', 'Вы решили более 100 задач на codeforces. Так держать!', '1', NULL),
(NULL, '666 задач', 'Вы решили более 666 задач. Теперь сам сатана может позавидовать вашему навыку олимпиадного программирования', '1', NULL),
(NULL, 'IT’S OVER NINE THOUSAAAAAND!', 'Вы решили более 9000 задач. Уровень вашей силы превосходит любые ожидания', '1', NULL);

ALTER TABLE `codeforcestasks` ADD `rating` INT NULL AFTER `active`;

