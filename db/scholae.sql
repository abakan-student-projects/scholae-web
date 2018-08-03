CREATE TABLE users
(
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  email        VARCHAR(512) DEFAULT '' NOT NULL,
  passwordHash VARCHAR(128) DEFAULT '' NOT NULL,
  roles        INT                     NOT NULL,
  firstName VARCHAR(128) NULL,
  lastName VARCHAR(128) NULL
);
CREATE INDEX email
  ON users (email);

create table sessions
(
	id varchar(255) not null
		primary key,
	userId bigint not null,
	clientIP varchar(25) not null,
	lastRequestTime datetime not null,
	constraint userId
		unique (userId)
);

--
-- Table structure for table `CodeforcesTags`
--

CREATE TABLE `CodeforcesTags` (
  `id` bigint(20) NOT NULL,
  `name` varchar(512) NOT NULL,
  `russianName` VARCHAR(512) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `CodeforcesTasks`
--

CREATE TABLE `CodeforcesTasks` (
  `id` bigint(20) NOT NULL,
  `name` varchar(512) NOT NULL,
  `level` int(11) NOT NULL,
  `solvedCount` int(11) NOT NULL,
  `contestId` int(11) NOT NULL,
  `contestIndex` varchar(128) NOT NULL,
  `type` VARCHAR(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `CodeforcesTasksTags`
--

CREATE TABLE `CodeforcesTasksTags` (
  `tagId` bigint(11) NOT NULL,
  `taskId` bigint(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ScholaeMissions`
--

CREATE TABLE `ScholaeMissions` (
  `id` bigint(20) NOT NULL,
  `state` tinyint(1) NOT NULL,
  `task` bigint(20) NOT NULL,
  `training` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ScholaeTrainings`
--

CREATE TABLE `ScholaeTrainings` (
  `id` bigint(20) NOT NULL,
  `name` varchar(512) NOT NULL,
  `user` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Indexes for dumped tables
--

--
-- Indexes for table `CodeforcesTags`
--
ALTER TABLE `CodeforcesTags`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `CodeforcesTasks`
--
ALTER TABLE `CodeforcesTasks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `CodeforcesTasksTags`
--
ALTER TABLE `CodeforcesTasksTags`
  ADD KEY `tag` (`tagId`,`taskId`),
  ADD KEY `task` (`taskId`);

--
-- Indexes for table `ScholaeMissions`
--
ALTER TABLE Exercises
  ADD PRIMARY KEY (`id`),
  ADD KEY `task` (taskId),
  ADD KEY `training` (trainingId);

--
-- Indexes for table `ScholaeTrainings`
--
ALTER TABLE Trainings
  ADD PRIMARY KEY (`id`),
  ADD KEY `user` (userId);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `CodeforcesTags`
--
ALTER TABLE `CodeforcesTags`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `CodeforcesTasks`
--
ALTER TABLE `CodeforcesTasks`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `ScholaeMissions`
--
ALTER TABLE Exercises
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `ScholaeTrainings`
--
ALTER TABLE Trainings
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `CodeforcesTasksTags`
--
ALTER TABLE `CodeforcesTasksTags`
  ADD CONSTRAINT `CodeforcesTasksTags_ibfk_1` FOREIGN KEY (`tagId`) REFERENCES `CodeforcesTags` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `CodeforcesTasksTags_ibfk_2` FOREIGN KEY (`taskId`) REFERENCES `CodeforcesTasks` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `ScholaeMissions`
--
ALTER TABLE Exercises
  ADD CONSTRAINT `ScholaeMissions_ibfk_1` FOREIGN KEY (taskId) REFERENCES `CodeforcesTasks` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `ScholaeMissions_ibfk_2` FOREIGN KEY (trainingId) REFERENCES Trainings (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `ScholaeTrainings`
--
ALTER TABLE Trainings
  ADD CONSTRAINT `ScholaeTrainings_ibfk_1` FOREIGN KEY (userId) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

CREATE TABLE Groups
(
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(512) NOT NULL,
  signUpKey VARCHAR(512)
);

ALTER TABLE Groups ADD teacherId BIGINT NULL;
CREATE INDEX TeacherIndex ON Groups (teacherId);

CREATE TABLE GroupsLearners
(
  groupId BIGINT,
  learnerId BIGINT
);
