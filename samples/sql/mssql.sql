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

-- populate tables
INSERT INTO departments (name, createdate, updatedate)
VALUES
	('Accounting', GETDATE(), GETDATE())
	,('Development', GETDATE(), GETDATE())
	,('Sales', GETDATE(), GETDATE())
	,('Support', GETDATE(), GETDATE());

INSERT INTO roles (name, createdate, updatedate)
VALUES
	('Editor', GETDATE(), GETDATE())
	,('Reviewer', GETDATE(), GETDATE())
	,('Manager', GETDATE(), GETDATE());

INSERT INTO usertypes (name, createdate, updatedate)
VALUES
	('Admin', GETDATE(), GETDATE())
	,('Manager', GETDATE(), GETDATE())
	,('User', GETDATE(), GETDATE());

INSERT INTO users (firstName, lastName, email, departmentId, userTypeId, createdate, updatedate)
VALUES 
	('Curly', 'Stooge', 'curly@stooges.com', 1, 1, GETDATE(), GETDATE())
	,('Larry', 'Stooge', 'larry@stooges.com', 2, 2, GETDATE(), GETDATE())
	,('Moe', 'Stooge', 'moe@stooges.com', 3, 3, GETDATE(), GETDATE());

INSERT INTO dbo.users_roles ( userId, roleId )
VALUES
	( 1, 1 )
	,( 1, 2 )
	,( 1, 3 )
	,( 2, 1 )
	,( 2, 2 )
	,( 3, 1 )
	,( 3, 3 );
