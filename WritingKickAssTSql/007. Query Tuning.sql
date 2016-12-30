

IF object_Id('ApplicationSteps') IS NOT NULL
	DROP TABLE ApplicationSteps

IF object_Id('Applications') IS NOT NULL
	DROP TABLE Applications


IF object_Id('Jobs') IS NOT NULL
	DROP TABLE Jobs


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


CREATE TABLE Jobs (Id int NOT NULL identity,
					Name varchar(50),
					CONSTRAINT PK_Jobs PRIMARY KEY (id))

 

 

CREATE TABLE Applications (Id int NOT NULL identity,
					JobId INT NOT NULL CONSTRAINT FK_Applications_JobId REFERENCES Jobs(Id),
					UserId INT NOT NULL CONSTRAINT FK_Applications_UserId  REFERENCES Users(Id),
					CONSTRAINT PK_Applications PRIMARY KEY (id))


CREATE TABLE ApplicationSteps (Id int NOT NULL identity,
					ApplicationId INT NOT NULL CONSTRAINT FK_ApplicationSteps_ApplicationId REFERENCES Applications(Id),
					StepName varchar(20) NOT NULL,
					IsActive BIT NOT NULL CONSTRAINT DF_ApplicationSteps_IsActive DEFAULT (0)
					CONSTRAINT PK_ApplicationSteps PRIMARY KEY (id))





/* Populate it with data */


INSERT UserStatuses (Id, Name)
SELECT 1, 'Active'
UNION ALL 
SELECT 2, 'InActive'
UNION ALL
SELECT 3, 'Deleted'


INSERT Jobs (Name)
SELECT o.Name
FROM sys.objects o


INSERT Users (FirstName, 
			  LastName ,
			  EmailAddress,
			  MailingAddress,
			  HomePhoneNumber,
			  MobilePhoneNumber,
			  UserStatusId
			)

SELECT	o1.name, o2.name, o1.name + '_' + o2.name  + '@' + o2.name + '.com', REPLICATE('x', 2000), CAST(CHECKSUM(o1.object_id, o2.object_id) as varchar(10)),  CAST(CHECKSUM(o1.object_id, o2.object_id) as varchar(10)), 1
FROM	sys.objects o1
		CROSS JOIN sys.objects o2
	


UPDATE Users SET UserStatusId = 2 WHERE Id IN (
SELECT TOP 400 u.Id
FROM Users u
ORDER BY NEWID()
)



UPDATE Users SET UserStatusId = 3 WHERE Id IN (
SELECT TOP 30 u.Id
FROM Users u
ORDER BY NEWID()
)


;WITH cteUsers AS 
(
	SELECT TOP 500 u.Id
	FROM Users u
	ORDER BY newid()
)
INSERT Applications (JobId, UserId)
SELECT j.Id, u.Id
FROM	Jobs j 
CROSS JOIN cteUsers u


;with cteSteps AS
( 
SELECT 'Pre Screening' as StepName
UNION ALL 
SELECT 'Phone Interview'
UNION ALL 
SELECT 'In Person Interview'
UNION ALL 
SELECT 'Offer'
UNION ALL 
SELECT 'Offer Accepted'
UNION ALL 
SELECT 'Offer Declined'
)

INSERT ApplicationSteps (ApplicationId, StepName)
SELECT		a.Id, s.StepName
FROM		Applications a
CROSS JOIN  cteSteps s
ORDER BY newid()


UPDATE ApplicationSteps SET IsActive = 1 
WHERE Id IN 
(
	SELECT min(a.Id) as Id
	FROM ApplicationSteps a
	GROUP BY  a.ApplicationId
)



/*
	The query we want to tune
*/

SELECT		step.StepName, count(*) as countApplicants	 
FROM		Jobs j
INNER JOIN	Applications a on j.Id = a.JobId
INNER JOIN	Users u ON u.Id = a.UserId 
INNER JOIN	ApplicationSteps step ON step.ApplicationId = a.Id
INNER JOIN	UserStatuses us ON u.UserStatusId = us.Id
WHERE		j.Name = 'ServiceBrokerQueue'
			AND us.Name = 'Active'
			AND step.IsActive = 1

GROUP BY  step.StepName


--No indexes  cost = 3.05

/*
	Take a note of statistics IO output 

	
		(6 row(s) affected)
		Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
		Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
		Table 'ApplicationSteps'. Scan count 1, logical reads 1319, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
		Table 'Users'. Scan count 0, logical reads 1540, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
		Table 'Applications'. Scan count 1, logical reads 132, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
		Table 'Jobs'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
		Table 'UserStatuses'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.



		(1 row(s) affected)


	Open in Plan Explorer, note cost (3.3) find the most expensive operation. (ApplicationSteps)
	Note the optimiser wants an index on isActive which isn't really selective.

*/


CREATE INDEX IX_ApplicationSteps_ApplicationID_IsActive ON ApplicationSteps (ApplicationId, IsActive) INCLUDE (StepName)


/*
	Run query again and open again in plan explorer, note cost (1.6) find most expensive operation (Users)
*/


CREATE INDEX IX_Users_UserStatusId ON Users (UserStatusId)


/*
	Run query again and open again in plan explorer, note cost (0.99) find most expensive operation (ApplicationSteps) - find next most expensive. 
*/

CREATE INDEX IX_Applications_JobId ON Applications (JobId, UserId) INCLUDE (Id)

/*

	Run query again and open again in plan explorer, note cost (0.6)  is this good enough?

	If the answer is no, there is a predicate that we did not cover.
*/


CREATE INDEX IX_Jobs_Name ON Jobs (Name) 

/*
	We could also cover application steps another way.
*/
CREATE INDEX IX_ApplicationSteps_IsActive_ApplicationID ON ApplicationSteps (IsActive, ApplicationId) INCLUDE (StepName)



/*
	FINALLY - compare the IO's to before we started.	
*/








/* Clean Up */

IF object_Id('ApplicationSteps') IS NOT NULL
	DROP TABLE ApplicationSteps

IF object_Id('Applications') IS NOT NULL
	DROP TABLE Applications


IF object_Id('Jobs') IS NOT NULL
	DROP TABLE Jobs


IF object_Id('Users') IS NOT NULL
	DROP TABLE Users

IF object_Id('UserStatuses') IS NOT NULL
	DROP TABLE UserStatuses
