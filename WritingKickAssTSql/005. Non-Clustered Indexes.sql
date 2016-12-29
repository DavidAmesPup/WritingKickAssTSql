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




/* 
Turn actual execution plan on 
*/


SELECT FirstName, LastName, EmailAddress
FROM Users 
WHERE EmailAddress = 'sysrscols_sysfiles1@sysrscols.com'


/*
	Note the query cost (157) & logical reads (212809) - Scan operator.
*/


/*
	Create an index 
*/
CREATE INDEX IX_Users_EmailAddress ON Users (EmailAddress)



SELECT FirstName, LastName, EmailAddress
FROM Users 
WHERE EmailAddress = 'sysrscols_sysfiles1@sysrscols.com'

/*
	Note the query cost (0.006) & logical reads (7) - Bookmark Lookup.
*/



/* 
	Create a covering index
*/

CREATE INDEX IX_Users_EmailAddress_1 ON Users (EmailAddress) INCLUDE (FirstName, LastName)


SELECT FirstName, LastName, EmailAddress
FROM Users 
WHERE EmailAddress = 'sysrscols_sysfiles1@sysrscols.com'

/*
	Note the query cost (0.003) & logical reads (3) - Bookmark Lookup.
*/




SELECT FirstName, LastName, EmailAddress
FROM Users 
WHERE EmailAddress = 'sysrscols_sysfiles1@sysrscols.com'
AND FirstName = 'sysrscols' 
AND LastName = 'sysfiles1'

/*
	Note that even though we have more predictes, the query cost does not change. (Instead, we get a residual predicate as well as our seek predicate)
*/






/*
	If we search for columns included by that index then we can scan that index, which is still bad. (note cost and logical reads.)
*/
SELECT FirstName, LastName, EmailAddress
FROM Users 
WHERE FirstName = 'sysrscols' 
AND LastName = 'sysfiles1'





CREATE INDEX IX_Users_FirstName_LastName ON Users (FirstName, LastName)


/*
	Run the same query again, the cost has gone right down, but the bookmark lookup is expensive.  
	As more rows are returned, the compatiative cost of the bookmark lookup goes up.
*/


SELECT FirstName, LastName, EmailAddress
FROM Users 
WHERE FirstName = 'sysrscols' 
AND LastName = 'sysfiles1'


/*
	Search on the first column of the index, we can seek the index.
*/
SELECT FirstName, LastName
FROM Users 
WHERE FirstName = 'sysrscols' 



/*
	Search on the last column of the index, we can not seek the index as they are based on a left-based-subset.
*/

SELECT FirstName
FROM Users 
WHERE  LastName = 'sysfiles1'

