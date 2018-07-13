CREATE TABLE users
(
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  email        VARCHAR(512) DEFAULT '' NOT NULL,
  passwordHash VARCHAR(128) DEFAULT '' NOT NULL,
  roles        INT                     NOT NULL
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
ALTER TABLE `ScholaeMissions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `task` (`task`),
  ADD KEY `training` (`training`);

--
-- Indexes for table `ScholaeTrainings`
--
ALTER TABLE `ScholaeTrainings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user` (`user`);

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
ALTER TABLE `ScholaeMissions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `ScholaeTrainings`
--
ALTER TABLE `ScholaeTrainings`
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
ALTER TABLE `ScholaeMissions`
  ADD CONSTRAINT `ScholaeMissions_ibfk_1` FOREIGN KEY (`task`) REFERENCES `CodeforcesTasks` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `ScholaeMissions_ibfk_2` FOREIGN KEY (`training`) REFERENCES `ScholaeTrainings` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `ScholaeTrainings`
--
ALTER TABLE `ScholaeTrainings`
  ADD CONSTRAINT `ScholaeTrainings_ibfk_1` FOREIGN KEY (`user`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;
