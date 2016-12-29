USE TEMPDB

SET STATISTICS IO ON

IF object_Id('Users') IS NOT NULL
	DROP TABLE Users

/* Create the table */
CREATE TABLE Users  (Id int NOT NULL identity,
				     FullName varchar(200), 						
					 CONSTRAINT PK_Users PRIMARY KEY (id))

CREATE INDEX IX_Users_FullName ON Users (FullName)


/* Populate it with data */
INSERT Users (FullName)

SELECT	o1.name + ' ' + o2.name + ' ' + o3.name
FROM	sys.objects o1
		CROSS JOIN sys.objects o2
		CROSS JOIN sys.objects o3




/*
	Turn on show actual execution plan
*/



/* Option 1, types are same */
SELECT * From Users  WHERE FullName LIKE 'sysxsrvs sysfoqueues%'

/* Option 2, types are different */
SELECT * From Users  WHERE FullName LIKE N'sysxsrvs sysfoqueues%'


/*
	Observe the difference in:
	* Execution plan costs.
	* Estimated vs actual rows in Option 1's Index Scan operator.
	* Actual IO for both executions.
*/
