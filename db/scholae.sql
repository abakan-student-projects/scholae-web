create table Assignments
(
  id bigint auto_increment
    primary key,
  startDateTime datetime null,
  finishDateTime datetime null,
  name varchar(512) null,
  learnerIds text null,
  metaTrainingId bigint null,
  groupId bigint null
)
;

create table Attempts
(
  id bigint auto_increment
    primary key,
  taskId bigint null,
  userId bigint null,
  description text null,
  solved tinyint null
)
;

create table CodeforcesTags
(
  id bigint auto_increment
    primary key,
  name varchar(512) not null,
  russianName varchar(256) null
)
;

create table CodeforcesTasks
(
  id bigint auto_increment
    primary key,
  name varchar(512) not null,
  level int not null,
  solvedCount int not null,
  contestId int not null,
  contestIndex varchar(128) not null,
  type varchar(128) null
)
;

create table CodeforcesTasksTags
(
  tagId bigint(11) not null,
  taskId bigint(11) not null
)
;

create index tag
  on CodeforcesTasksTags (tagId, taskId)
;

create index task
  on CodeforcesTasksTags (taskId)
;

create table Exercises
(
  id bigint auto_increment
    primary key,
  taskId bigint not null,
  trainingId bigint not null
)
;

create table Groups
(
  id bigint auto_increment
    primary key,
  name varchar(512) not null,
  signUpKey varchar(512) null,
  teacherId bigint null
)
;

create index TeacherIndex
  on Groups (teacherId)
;

create table GroupsLearners
(
  groupId bigint null,
  learnerId bigint null
)
;

create table MetaTrainings
(
  id bigint auto_increment
    primary key,
  minLevel int default '1' null,
  maxLevel int default '5' null,
  tagIds text null,
  length int null
)
;

create table Trainings
(
  id bigint auto_increment
    primary key,
  name varchar(512) not null,
  userId bigint not null,
  assignmentId bigint null
)
;

create table sessions
(
  id varchar(255) not null
    primary key,
  userId bigint not null,
  clientIP varchar(25) not null,
  lastRequestTime datetime not null,
  constraint userId
  unique (userId)
)
;

create table users
(
  id bigint auto_increment
    primary key,
  email varchar(512) default '' not null,
  passwordHash varchar(128) default '' not null,
  roles int not null,
  firstName varchar(128) null,
  lastName varchar(128) null
)
;

create index email
  on users (email)
;

