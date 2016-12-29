USE TEMPDB

SET STATISTICS IO ON

IF object_Id('UserLoginLog') IS NOT NULL
	DROP TABLE UserLoginLog

/* Create the table */
CREATE TABLE UserLoginLog  (Id int NOT NULL identity,
							UserID int NOT NULL, 
							LastLoginDate datetime NOT NULL,
							CONSTRAINT PK_UserLoginLog PRIMARY KEY (id))

CREATE INDEX IX_UserLoginLog_LastLoginDate_UserID ON UserLoginLog (LastLoginDate, UserID)

/* Populate it with data */

;WITH cteNumbers AS 
 (
	SELECT o1.OBJECT_ID, row_number() OVER (PARTITION BY o1.object_ID ORDER BY o1.object_ID) as number
	FROM sys.objects o1
	CROSS JOIN sys.objects o2
)

INSERT UserLoginLog (UserID, LastLoginDate)
SELECT n.OBJECT_ID, DATEADD(minute, -n.number, getdate())
FROM cteNumbers n

/*
	Turn on show actual execution plan
*/

/* How many times did userId 3 login in the last 10 minutes? */

--Option 1 
SELECT	COUNT(*) 
FROM	UserLoginLog l
WHERE	DATEDIFF(minute, l.LastLoginDate, getdate()) < 10		
		AND l.UserID = 3

--Option 2
SELECT	COUNT(*) 
FROM	UserLoginLog l
WHERE l.LastLoginDate >= DateAdd(minute, -10, getDate())	
		AND l.UserID = 3


/*
	Observe the difference in:
	* Execution plan costs.
	* Estimated vs actual rows in Option 1's Index Scan operator.
	* Actual IO
*/



