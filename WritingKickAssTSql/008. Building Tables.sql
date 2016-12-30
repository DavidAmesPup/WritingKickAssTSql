IF object_Id('Users') IS NOT NULL
	DROP TABLE Users

/* Create the table */

CREATE TABLE Users  (Id int NOT NULL identity PRIMARY KEY,
					 EmailAddress varchar(200) unique,
					 IsActive bit default(0),
				     FullName varchar(200))

sp_help Users

/*
	Change isActive to a status
*/

ALTER TABLE Users ADD UserStatusId INT NULL

/*
	A deployment cycle later, drop the old column
*/
ALTER TABLE Users DROP COLUMN IsActive 

/*
	Observe the error - the object name is differnet on every database
*/

