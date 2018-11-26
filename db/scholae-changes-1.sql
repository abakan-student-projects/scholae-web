ALTER TABLE users MODIFY lastCodeforcesSubmissionId BIGINT(20) DEFAULT 0;
ALTER TABLE CodeforcesTasks ALTER COLUMN level SET DEFAULT 0;
ALTER TABLE Assignments ADD COLUMN deleted tinyint(4) DEFAULT 0;
ALTER TABLE Exercises ADD COLUMN deleted tinyint(4) DEFAULT 0;
ALTER TABLE Groups ADD COLUMN deleted tinyint(4) DEFAULT 0;
ALTER TABLE Trainings ADD COLUMN deleted tinyint(4) DEFAULT 0;

