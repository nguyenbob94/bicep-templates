-- Entry point of query
USE master
GO

-- Create yellowPages database if it doesn't exist. Comment out if not required
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'yellowPages')
BEGIN
  CREATE DATABASE yellowPages

END 
GO
-- Use database, change name of database to scoped
USE yellowPages
GO

-- Create people table
IF NOT EXISTS(SELECT * FROM sysobjects WHERE name='people')
BEGIN
  CREATE TABLE people (
  id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
  personname VARCHAR(100),
  dob DATE,
  gender VARCHAR(100),
  phnumber VARCHAR(100)
  )
END
GO

-- Create completed table (placeholder for logic app)
IF NOT EXISTS(SELECT * FROM sysobjects WHERE name='completed')
BEGIN
  CREATE TABLE completed (
  id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
  personname VARCHAR(100),
  dob DATE,
  gender VARCHAR(100),
  phnumber VARCHAR(100)
  )
END
GO




