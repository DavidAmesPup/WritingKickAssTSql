IF object_Id('Users') IS NOT NULL
	DROP TABLE Users

/* Allow us to dump pages to the T-SQL messages tab */
DBCC TRACEON(3604)

/* Create the table */

CREATE TABLE Users  (Id int NOT NULL identity,
				     FirstName varchar(200),
					 LastName varchar(200),					 					 					 
					 CONSTRAINT PK_Users PRIMARY KEY NONCLUSTERED (id))

INSERT Users (FirstName, LastName)
SELECT 'David', 'Ames'
UNION ALL 
SELECT 'Anton', 'Felich'

/* Look at the data - the 3rd parameter is the location of the data.*/
SELECT FirstName, LastName, sys.fn_PhysLocFormatter(%%physloc%%)
FROM Users




/* Look at the physical page - what order are the rows in? */
DBCC PAGE (tempDb,1,174,3)



/* Create a clustered index on First Name */
CREATE CLUSTERED INDEX CIX_Users_FirstName ON Users(FirstName)


/* Look at the physical page - the rows are ordered as ? [Anton, David] */
 
SELECT FirstName, LastName, sys.fn_PhysLocFormatter(%%physloc%%)
FROM Users

DBCC PAGE (tempDb,1,338,3)


/* Create a clustered index on Last Name */
CREATE CLUSTERED INDEX CIX_Users_LastName ON Users(LastName)



/* Fail...The Data can stored in 1 physical order. */
DROP INDEX CIX_Users_FirstName ON Users
CREATE CLUSTERED INDEX CIX_Users_LastName ON Users(LastName)

/* Look at the physical page - the rows are ordered as ? [David, Anton] */
 
SELECT FirstName, LastName, sys.fn_PhysLocFormatter(%%physloc%%)
FROM Users

DBCC PAGE (tempDb,1,341,3)

/* Clean Up */
IF object_Id('Users') IS NOT NULL
	DROP TABLE Users

