IF object_Id('Users') IS NOT NULL
	DROP TABLE Users


SET STATISTICS IO ON

/* Create the table */

CREATE TABLE Users  (Id int NOT NULL identity,
				     FirstName varchar(200),
					 LastName varchar(200),
					 EmailAddress varchar(200),
					 MailingAddress varchar(2000),
					 HomePhoneNumber varchar(200),
					 MobilePhoneNumber varchar(200),					 					 
					 CONSTRAINT PK_Users PRIMARY KEY (id))



 
/* Populate it with data */
INSERT Users (FirstName, 
			  LastName ,
			  EmailAddress,
			  MailingAddress,
			  HomePhoneNumber,
			  MobilePhoneNumber
			)

SELECT	o1.name, o2.name, o1.name + '_' + o2.name  + '@' + o3.name + '.com', REPLICATE('x', 2000), CAST(CHECKSUM(o1.object_id, o2.object_id, o3.object_id) as varchar(10)),  CAST(CHECKSUM(o1.object_id, o2.object_id, o3.object_id) as varchar(10))
FROM	sys.objects o1
		CROSS JOIN sys.objects o2
		CROSS JOIN sys.objects o3



		
CREATE INDEX IX_Users_EmailAddress ON Users (EmailAddress) INCLUDE (FirstName, MobilePhoneNumber)


/*
	Turn on show actual execution plan
*/


--First example 
SELECT * 
FROM Users 
WHERE EmailAddress LIKE 'sysfiles1_sysbrickfiles%'



--Second Example, only getting the rows we need
SELECT EmailAddress, FirstName, MobilePhoneNumber
FROM Users 
WHERE EmailAddress LIKE 'sysfiles1_sysbrickfiles%'



/* Clean Up */

IF object_Id('Users') IS NOT NULL
	DROP TABLE Users

