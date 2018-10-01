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

create index Assignments_groupId_index
  on Assignments (groupId)
;

create table Attempts
(
  id bigint auto_increment
    primary key,
  taskId bigint null,
  userId bigint null,
  description text null,
  solved tinyint null,
  datetime datetime null,
  vendorId bigint null
)
;

create index Attempts_solved_index
  on Attempts (solved)
;

create index Attempts_taskId_index
  on Attempts (taskId)
;

create index Attempts_userId_index
  on Attempts (userId)
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
  type varchar(128) null,
  active tinyint default '1' null
)
;

create index CodeforcesTasks_contestId_index
  on CodeforcesTasks (contestId, contestIndex)
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

create index Exercises_taskId_index
  on Exercises (taskId)
;

create index Exercises_trainingId_index
  on Exercises (trainingId)
;

create table Groups
(
  id bigint auto_increment
    primary key,
  name varchar(512) not null,
  signUpKey varchar(128) null,
  teacherId bigint null,
  constraint Groups_signUpKey_uindex
  unique (signUpKey)
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

create index GroupsLearners_groupId_index
  on GroupsLearners (groupId)
;

create index GroupsLearners_learnerId_index
  on GroupsLearners (learnerId)
;

create table MetaTrainings
(
  id bigint auto_increment
    primary key,
  minLevel int default '1' null,
  maxLevel int default '5' null,
  tagIds text null,
  taskIds text null,
  length int null
)
;

create table Trainings
(
  id bigint auto_increment
    primary key,
  name varchar(512) null,
  userId bigint not null,
  assignmentId bigint null
)
;

create index Trainings_userId_index
  on Trainings (userId)
;

create index Trainings_assignmentId_index
  on Trainings (assignmentId)
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
  lastName varchar(128) null,
  codeforcesHandle varchar(512) null,
  lastCodeforcesSubmissionId bigint null,
  emailActivationCode varchar(128) null,
  registrationDate datetime null,
  emailActivated tinyint default '0' not null
)
;

create index email
  on users (email)
;

