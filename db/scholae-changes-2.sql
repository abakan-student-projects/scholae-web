ALTER TABLE `users` ADD `activationDate` DATETIME NULL DEFAULT NULL AFTER `registrationDate`;
UPDATE `users` SET `activationDate` = `registrationDate`;