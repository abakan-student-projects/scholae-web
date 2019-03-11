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