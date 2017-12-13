USE [usermanager]
GO

IF NOT EXISTS ( SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'departments' )
BEGIN
	CREATE TABLE [dbo].[departments](
		[departmentId] [int] IDENTITY(1,1) NOT NULL,
		[name] [nvarchar](50) NOT NULL,
		[createdate] [datetime] NOT NULL CONSTRAINT [DF_departments_createdate] DEFAULT (GETDATE()),
		[updatedate] [datetime] NOT NULL,
	 CONSTRAINT [PK_departments] PRIMARY KEY CLUSTERED 
	(
		[departmentId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END

IF NOT EXISTS ( SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'roles' )
BEGIN
	CREATE TABLE [dbo].[roles](
		[roleId] [int] IDENTITY(1,1) NOT NULL,
		[name] [nvarchar](50) NOT NULL,
		[createdate] [datetime] NOT NULL CONSTRAINT [DF_roles_createdate] DEFAULT (GETDATE()),
		[updatedate] [datetime] NOT NULL,
	 CONSTRAINT [PK_roles] PRIMARY KEY CLUSTERED 
	(
		[roleId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END

IF NOT EXISTS ( SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'usertypes' )
BEGIN
	CREATE TABLE [dbo].[usertypes](
		[userTypeId] [int] IDENTITY(1,1) NOT NULL,
		[name] [nvarchar](50) NOT NULL,
		[createdate] [datetime] NOT NULL CONSTRAINT [DF_usertypes_createdate] DEFAULT (GETDATE()),
		[updatedate] [datetime] NOT NULL,
	 CONSTRAINT [PK_usertypes] PRIMARY KEY CLUSTERED 
	(
		[userTypeId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END

IF NOT EXISTS ( SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'users' )
BEGIN
	CREATE TABLE [dbo].[users](
		[userId] [int] IDENTITY(1,1) NOT NULL,
		[firstName] [nvarchar](50) NOT NULL,
		[lastName] [nvarchar](50) NOT NULL,
		[email] [nvarchar](50) NULL,
		[departmentId] [int] NOT NULL,
		[userTypeId] [int] NOT NULL,
		[createdate] [datetime] NOT NULL CONSTRAINT [DF_users_createdate] DEFAULT (GETDATE()),
		[updatedate] [datetime] NOT NULL,
	 CONSTRAINT [PK_users] PRIMARY KEY CLUSTERED 
	(
		[userId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END

IF ( OBJECT_ID('dbo.FK_users_departments', 'F') IS NULL )
BEGIN
	ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [FK_users_departments] FOREIGN KEY([departmentId])
	REFERENCES [dbo].[departments] ([departmentId])

	ALTER TABLE [dbo].[users] CHECK CONSTRAINT [FK_users_departments]
END

IF ( OBJECT_ID('dbo.FK_users_usertypes', 'F') IS NULL )
BEGIN
	ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [FK_users_usertypes] FOREIGN KEY([userTypeId])
	REFERENCES [dbo].[usertypes] ([userTypeId])

	ALTER TABLE [dbo].[users] CHECK CONSTRAINT [FK_users_usertypes]
END

IF NOT EXISTS ( SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'users_roles' )
BEGIN
	CREATE TABLE [dbo].[users_roles](
		[userId] [int] NOT NULL,
		[roleId] [int] NOT NULL,
	 CONSTRAINT [PK_users_roles] PRIMARY KEY CLUSTERED 
	(
		[userId] ASC,
		[roleId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END

IF ( OBJECT_ID('dbo.FK_users_roles_roles', 'F') IS NULL )
BEGIN
	ALTER TABLE [dbo].[users_roles]  WITH CHECK ADD  CONSTRAINT [FK_users_roles_roles] FOREIGN KEY([roleId])
	REFERENCES [dbo].[roles] ([roleId])

	ALTER TABLE [dbo].[users_roles] CHECK CONSTRAINT [FK_users_roles_roles]
END

IF ( OBJECT_ID('dbo.FK_users_roles_users', 'F') IS NULL )
BEGIN
	ALTER TABLE [dbo].[users_roles]  WITH CHECK ADD  CONSTRAINT [FK_users_roles_users] FOREIGN KEY([userId])
	REFERENCES [dbo].[users] ([userId])

	ALTER TABLE [dbo].[users_roles] CHECK CONSTRAINT [FK_users_roles_users]
END


-- populate departments
DECLARE @tDepartments TABLE (
	departmentId INT
	, name VARCHAR(50)
);

INSERT INTO @tDepartments ( departmentId, name )
VALUES
	(1, 'Accounting')
	,(2, 'Development')
	,(3, 'Sales')
	,(4, 'Support');

SET IDENTITY_INSERT dbo.departments ON;

MERGE INTO dbo.departments AS t
USING @tDepartments AS s
	ON t.departmentId = s.departmentId
WHEN NOT MATCHED THEN
	INSERT ( departmentId, name, updatedate ) 
	VALUES (
		s.departmentId
		, s.name
		, GETDATE()
	);

SET IDENTITY_INSERT dbo.departments OFF;


-- populate roles
DECLARE @tRoles TABLE (
	roleId INT
	, name VARCHAR(50)
);

INSERT INTO @tRoles ( roleId, name )
VALUES
	(1,'Editor')
	,(2,'Reviewer')
	,(3,'Manager');

SET IDENTITY_INSERT dbo.roles ON;

MERGE INTO dbo.roles AS t
USING @tRoles AS s
	ON t.roleId = s.roleId
WHEN NOT MATCHED THEN
	INSERT ( roleId, name, updatedate ) 
	VALUES (
		s.roleId
		, s.name
		, GETDATE()
	);

SET IDENTITY_INSERT dbo.roles OFF;


-- populate usertypes
DECLARE @tUserTypes TABLE (
	userTypeId INT
	, name VARCHAR(50)
);

INSERT INTO @tUserTypes ( userTypeId, name )
VALUES
	(1,'Admin')
	,(2,'Manager')
	,(3,'User');

SET IDENTITY_INSERT dbo.usertypes ON;

MERGE INTO dbo.usertypes AS t
USING @tUserTypes AS s
	ON t.userTypeId = s.userTypeId
WHEN NOT MATCHED THEN
	INSERT ( userTypeId, name, updatedate ) 
	VALUES (
		s.userTypeId
		, s.name
		, GETDATE()
	);

SET IDENTITY_INSERT dbo.usertypes OFF;


-- populate users
DECLARE @tUsers TABLE (
	userId INT
	, firstName VARCHAR(50)
	, lastName VARCHAR(50)
	, email VARCHAR(50)
	, departmentId INT
	, userTypeId INT
);

INSERT INTO @tUsers ( userId, firstName, lastName, email, departmentId, userTypeId )
VALUES
	(1, 'Curly', 'Stooge', 'curly@stooges.com', 1, 1)
	,(2, 'Larry', 'Stooge', 'larry@stooges.com', 2, 2)
	,(3, 'Moe', 'Stooge', 'moe@stooges.com', 3, 3);

SET IDENTITY_INSERT dbo.users ON;

MERGE INTO dbo.users AS t
USING @tUsers AS s
	ON t.userId = s.userId
WHEN MATCHED THEN
	UPDATE SET
		firstName = t.firstName
		, lastName = t.lastName
		, email = t.email
		, departmentId = t.departmentId
		, userTypeId = t.userTypeId
		, updatedate = GETDATE()

WHEN NOT MATCHED THEN
	INSERT ( userId, firstName, lastName, email, departmentId, userTypeId, updatedate ) 
	VALUES (
		s.userId
		, s.firstName
		, s.lastName
		, s.email
		, s.departmentId
		, s.userTypeId
		, GETDATE()
	);

SET IDENTITY_INSERT dbo.users OFF;


-- populate users_roles
DECLARE @tUserRoles TABLE (
	userId INT
	, roleId INT
);

INSERT INTO @tUserRoles ( userId, roleId )
VALUES
	( 1, 1 )
	,( 1, 2 )
	,( 1, 3 )
	,( 2, 1 )
	,( 2, 2 )
	,( 3, 1 )
	,( 3, 3 );

MERGE INTO dbo.users_roles AS t
USING @tUserRoles AS s
	ON t.userId = s.userId
	AND t.roleId = s.roleId
WHEN NOT MATCHED THEN
	INSERT ( userId, roleId ) 
	VALUES (
		s.userId
		, s.roleId
	);
