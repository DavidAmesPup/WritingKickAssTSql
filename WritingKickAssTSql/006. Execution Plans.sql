IF object_Id('Users') IS NOT NULL
	DROP TABLE Users

IF object_Id('UserStatuses') IS NOT NULL
	DROP TABLE UserStatuses
	
SET STATISTICS IO ON

/* Create the table */

CREATE TABLE UserStatuses  (Id int NOT NULL,
							Name varchar(50),
							CONSTRAINT PK_UserStatuses PRIMARY KEY (id))
							

CREATE TABLE Users  (Id int NOT NULL identity,
				     FirstName varchar(200),
					 LastName varchar(200),
					 EmailAddress varchar(200),
					 MailingAddress varchar(2000),
					 HomePhoneNumber varchar(200),
					 MobilePhoneNumber varchar(200),
					 UserStatusId INT NOT NULL CONSTRAINT FK_Users_UserStatusId FOREIGN KEY REFERENCES UserStatuses(ID)
					 CONSTRAINT PK_Users PRIMARY KEY (id))

CREATE INDEX IX_Users_UserStatusId ON Users (UserStatusId) INCLUDE (EmailAddress)


 
/* Populate it with data */


INSERT UserStatuses (Id, Name)
SELECT 1, 'Active'
UNION ALL 
SELECT 2, 'InActive'
UNION ALL
SELECT 3, 'Deleted'


INSERT Users (FirstName, 
			  LastName ,
			  EmailAddress,
			  MailingAddress,
			  HomePhoneNumber,
			  MobilePhoneNumber,
			  UserStatusId
			)

SELECT	o1.name, o2.name, o1.name + '_' + o2.name  + '@' + o3.name + '.com', REPLICATE('x', 2000), CAST(CHECKSUM(o1.object_id, o2.object_id, o3.object_id) as varchar(10)),  CAST(CHECKSUM(o1.object_id, o2.object_id, o3.object_id) as varchar(10)), 1
FROM	sys.objects o1
		CROSS JOIN sys.objects o2
		CROSS JOIN sys.objects o3


UPDATE Users SET UserStatusId = 2 WHERE Id IN (
SELECT TOP 10000 u.Id
FROM Users u
ORDER BY NEWID()
)



UPDATE Users SET UserStatusId = 3 WHERE Id IN (
SELECT TOP 30 u.Id
FROM Users u
ORDER BY NEWID()
)


/* 
	Turn actual execution plan on 
*/



/*
	Control flows left to right.
	Data flows right to left.
	Note the estimated cost. (costs are STILL estimates even though we have an actual plan)
	Note the estimated rows. 
	Sort is a Top-Go operator.
*/

GO  

SELECT u.EmailAddress
FROM Users u
INNER JOIN UserStatuses us ON u.UserStatusId = us.Id
WHERE us.Name = 'Deleted'
ORDER BY u.EmailAddress


/*
	Compare to this query.
	Note the cost difference.
	Note the IO difference.
*/

SELECT u.EmailAddress
FROM Users u
WHERE u.UserStatusId = 3 /* This could be an enum/const in code. */
ORDER BY u.EmailAddress


