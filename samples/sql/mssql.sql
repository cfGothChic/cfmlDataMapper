USE [usermanager]
GO

/****** Object:  Table [dbo].[departments]    Script Date: 8/24/2014 12:14:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[departments](
	[departmentId] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[createdate] [datetime] NOT NULL,
	[updatedate] [datetime] NOT NULL,
 CONSTRAINT [PK_departments] PRIMARY KEY CLUSTERED 
(
	[departmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[departments] ADD  CONSTRAINT [DF_departments_createdate]  DEFAULT (getdate()) FOR [createdate]
GO

/****** Object:  Table [dbo].[roles]    Script Date: 8/24/2014 6:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[roles](
	[roleId] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[createdate] [datetime] NOT NULL,
	[updatedate] [datetime] NOT NULL,
 CONSTRAINT [PK_roles] PRIMARY KEY CLUSTERED 
(
	[roleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[roles] ADD  CONSTRAINT [DF_roles_createdate]  DEFAULT (getdate()) FOR [createdate]
GO

/****** Object:  Table [dbo].[usertypes]    Script Date: 8/24/2014 6:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[usertypes](
	[userTypeId] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[createdate] [datetime] NOT NULL,
	[updatedate] [datetime] NOT NULL,
 CONSTRAINT [PK_usertypes] PRIMARY KEY CLUSTERED 
(
	[userTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[usertypes] ADD  CONSTRAINT [DF_usertypes_createdate]  DEFAULT (getdate()) FOR [createdate]
GO

/****** Object:  Table [dbo].[users]    Script Date: 8/24/2014 6:54:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[users](
	[userId] [int] IDENTITY(1,1) NOT NULL,
	[firstName] [nvarchar](50) NOT NULL,
	[lastName] [nvarchar](50) NOT NULL,
	[email] [nvarchar](50) NULL,
	[departmentId] [int] NOT NULL,
	[userTypeId] [int] NOT NULL,
	[createdate] [datetime] NOT NULL,
	[updatedate] [datetime] NOT NULL,
 CONSTRAINT [PK_users] PRIMARY KEY CLUSTERED 
(
	[userId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[users] ADD  CONSTRAINT [DF_users_createdate]  DEFAULT (getdate()) FOR [createdate]
GO

ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [FK_users_departments] FOREIGN KEY([departmentId])
REFERENCES [dbo].[departments] ([departmentId])
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [FK_users_departments]
GO

ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [FK_users_usertypes] FOREIGN KEY([userTypeId])
REFERENCES [dbo].[usertypes] ([userTypeId])
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [FK_users_usertypes]
GO

/****** Object:  Table [dbo].[users_roles]    Script Date: 12/10/2017 1:51:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[users_roles](
	[userId] [int] NOT NULL,
	[roleId] [int] NOT NULL,
 CONSTRAINT [PK_users_roles] PRIMARY KEY CLUSTERED 
(
	[userId] ASC,
	[roleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[users_roles]  WITH CHECK ADD  CONSTRAINT [FK_users_roles_roles] FOREIGN KEY([roleId])
REFERENCES [dbo].[roles] ([roleId])
GO
ALTER TABLE [dbo].[users_roles] CHECK CONSTRAINT [FK_users_roles_roles]
GO

ALTER TABLE [dbo].[users_roles]  WITH CHECK ADD  CONSTRAINT [FK_users_roles_users] FOREIGN KEY([userId])
REFERENCES [dbo].[users] ([userId])
GO
ALTER TABLE [dbo].[users_roles] CHECK CONSTRAINT [FK_users_roles_users]
GO

-- populate tables
INSERT INTO departments (name, createdate, updatedate) VALUES ('Accounting', GETDATE(), GETDATE());
INSERT INTO departments (name, createdate, updatedate) VALUES ('Development', GETDATE(), GETDATE());
INSERT INTO departments (name, createdate, updatedate) VALUES ('Sales', GETDATE(), GETDATE());
INSERT INTO departments (name, createdate, updatedate) VALUES ('Support', GETDATE(), GETDATE());

INSERT INTO roles (name, createdate, updatedate) VALUES ('Editor', GETDATE(), GETDATE());
INSERT INTO roles (name, createdate, updatedate) VALUES ('Reviewer', GETDATE(), GETDATE());
INSERT INTO roles (name, createdate, updatedate) VALUES ('Manager', GETDATE(), GETDATE());

INSERT INTO usertypes (name, createdate, updatedate) VALUES ('Admin', GETDATE(), GETDATE());
INSERT INTO usertypes (name, createdate, updatedate) VALUES ('Manager', GETDATE(), GETDATE());
INSERT INTO usertypes (name, createdate, updatedate) VALUES ('User', GETDATE(), GETDATE());

INSERT INTO users (firstName, lastName, email, departmentId, userTypeId, createdate, updatedate)
VALUES ('Curly', 'Stooge', 'curly@stooges.com', 1, 1, GETDATE(), GETDATE());

INSERT INTO users (firstName, lastName, email, departmentId, userTypeId, createdate, updatedate)
VALUES ('Larry', 'Stooge', 'larry@stooges.com', 2, 2, GETDATE(), GETDATE());

INSERT INTO users (firstName, lastName, email, departmentId, userTypeId, createdate, updatedate)
VALUES ('Moe', 'Stooge', 'moe@stooges.com', 3, 3, GETDATE(), GETDATE());

INSERT INTO dbo.users_roles ( userId, roleId )
VALUES
	( 1, 1 )
	,( 1, 2 )
	,( 1, 3 )
	,( 2, 1 )
	,( 2, 2 )
	,( 3, 1 )
	,( 3, 3 );
