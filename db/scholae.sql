create table users
(
	id bigint auto_increment
		primary key,
	email varchar(512) default '' not null,
	passwordHash varchar(128) default '' not null
);

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