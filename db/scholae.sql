create index email
	on users (email);

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
  `name` varchar(512) NOT NULL
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
  `contestIndex` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `CodeforcesTasksTags`
--

CREATE TABLE `CodeforcesTasksTags` (
  `tag` bigint(11) NOT NULL,
  `task` bigint(11) NOT NULL
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
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) NOT NULL,
  `email` varchar(512) NOT NULL DEFAULT '',
  `passwordHash` varchar(128) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `passwordHash`) VALUES
(1, 'user1@qwe.ru', '5f4dcc3b5aa765d61d8327deb882cf99'),
(2, 'asd@zxc.com', 'asdasjdlkasjdlk');

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
  ADD KEY `tag` (`tag`,`task`),
  ADD KEY `task` (`task`);

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
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `email` (`email`(255));

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
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `CodeforcesTasksTags`
--
ALTER TABLE `CodeforcesTasksTags`
  ADD CONSTRAINT `CodeforcesTasksTags_ibfk_1` FOREIGN KEY (`tag`) REFERENCES `CodeforcesTags` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `CodeforcesTasksTags_ibfk_2` FOREIGN KEY (`task`) REFERENCES `CodeforcesTasks` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

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
