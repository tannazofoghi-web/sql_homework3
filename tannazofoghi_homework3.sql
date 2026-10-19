/*
    Homework 3 - Cross-database tables and UNION in SQL Server
    Creates DB1 and DB2, adds Student/Teacher/Course tables and sample data,
    demonstrates UNION across corresponding tables, and creates a combined
    student view in DB1.

    Notes:
    - Run this script in SQL Server Management Studio (or sqlcmd) with
      permission to create databases.
    - The script is safe to rerun: existing databases and tables are retained,
      sample rows are inserted only when their IDs are absent, and the view is
      recreated.
*/

USE master;
GO

IF DB_ID(N'DB1') IS NULL
    EXEC(N'CREATE DATABASE DB1;');
GO

IF DB_ID(N'DB2') IS NULL
    EXEC(N'CREATE DATABASE DB2;');
GO

/* Create the tables in DB1. */
USE DB1;
GO

IF OBJECT_ID(N'dbo.Student', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Student
    (
        StudentID INT NOT NULL CONSTRAINT PK_Student PRIMARY KEY,
        FirstName NVARCHAR(50) NOT NULL,
        LastName  NVARCHAR(50) NOT NULL,
        Age       TINYINT NOT NULL,
        Major     NVARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.Teacher', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Teacher
    (
        TeacherID  INT NOT NULL CONSTRAINT PK_Teacher PRIMARY KEY,
        FirstName  NVARCHAR(50) NOT NULL,
        LastName   NVARCHAR(50) NOT NULL,
        Department NVARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.Course', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Course
    (
        CourseID   INT NOT NULL CONSTRAINT PK_Course PRIMARY KEY,
        CourseName NVARCHAR(100) NOT NULL,
        Credits    TINYINT NOT NULL,
        TeacherID  INT NOT NULL
    );
END;
GO

/* Sample data for DB1 (insert only missing IDs). */
IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE StudentID = 1)
    INSERT INTO dbo.Student (StudentID, FirstName, LastName, Age, Major)
    VALUES (1, N'Ava', N'Brown', 20, N'Computer Science');
IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE StudentID = 2)
    INSERT INTO dbo.Student (StudentID, FirstName, LastName, Age, Major)
    VALUES (2, N'Liam', N'Wilson', 22, N'Mathematics');

IF NOT EXISTS (SELECT 1 FROM dbo.Teacher WHERE TeacherID = 1)
    INSERT INTO dbo.Teacher (TeacherID, FirstName, LastName, Department)
    VALUES (1, N'Grace', N'Lee', N'Computer Science');
IF NOT EXISTS (SELECT 1 FROM dbo.Teacher WHERE TeacherID = 2)
    INSERT INTO dbo.Teacher (TeacherID, FirstName, LastName, Department)
    VALUES (2, N'Noah', N'Martin', N'Mathematics');

IF NOT EXISTS (SELECT 1 FROM dbo.Course WHERE CourseID = 101)
    INSERT INTO dbo.Course (CourseID, CourseName, Credits, TeacherID)
    VALUES (101, N'Database Systems', 3, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Course WHERE CourseID = 102)
    INSERT INTO dbo.Course (CourseID, CourseName, Credits, TeacherID)
    VALUES (102, N'Linear Algebra', 4, 2);
GO

/* Create the same tables in DB2. */
USE DB2;
GO

IF OBJECT_ID(N'dbo.Student', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Student
    (
        StudentID INT NOT NULL CONSTRAINT PK_Student PRIMARY KEY,
        FirstName NVARCHAR(50) NOT NULL,
        LastName  NVARCHAR(50) NOT NULL,
        Age       TINYINT NOT NULL,
        Major     NVARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.Teacher', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Teacher
    (
        TeacherID  INT NOT NULL CONSTRAINT PK_Teacher PRIMARY KEY,
        FirstName  NVARCHAR(50) NOT NULL,
        LastName   NVARCHAR(50) NOT NULL,
        Department NVARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.Course', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Course
    (
        CourseID   INT NOT NULL CONSTRAINT PK_Course PRIMARY KEY,
        CourseName NVARCHAR(100) NOT NULL,
        Credits    TINYINT NOT NULL,
        TeacherID  INT NOT NULL
    );
END;
GO

/* Sample data for DB2 (IDs may overlap; the source database is shown below). */
IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE StudentID = 1)
    INSERT INTO dbo.Student (StudentID, FirstName, LastName, Age, Major)
    VALUES (1, N'Emma', N'Davis', 21, N'Physics');
IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE StudentID = 2)
    INSERT INTO dbo.Student (StudentID, FirstName, LastName, Age, Major)
    VALUES (2, N'Oliver', N'Clark', 23, N'Biology');

IF NOT EXISTS (SELECT 1 FROM dbo.Teacher WHERE TeacherID = 1)
    INSERT INTO dbo.Teacher (TeacherID, FirstName, LastName, Department)
    VALUES (1, N'Mia', N'Garcia', N'Physics');
IF NOT EXISTS (SELECT 1 FROM dbo.Teacher WHERE TeacherID = 2)
    INSERT INTO dbo.Teacher (TeacherID, FirstName, LastName, Department)
    VALUES (2, N'Ethan', N'Adams', N'Biology');

IF NOT EXISTS (SELECT 1 FROM dbo.Course WHERE CourseID = 101)
    INSERT INTO dbo.Course (CourseID, CourseName, Credits, TeacherID)
    VALUES (101, N'Classical Mechanics', 3, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Course WHERE CourseID = 102)
    INSERT INTO dbo.Course (CourseID, CourseName, Credits, TeacherID)
    VALUES (102, N'Cell Biology', 4, 2);
GO

/*
    A view in DB1 combining student rows from both databases.
    Cross-database names use the three-part form: database.schema.object.
*/
USE DB1;
GO

IF OBJECT_ID(N'dbo.vw_AllStudents', N'V') IS NOT NULL
    DROP VIEW dbo.vw_AllStudents;
GO

CREATE VIEW dbo.vw_AllStudents
AS
    SELECT N'DB1' AS SourceDatabase,
           StudentID, FirstName, LastName, Age, Major
    FROM DB1.dbo.Student
    UNION
    SELECT N'DB2' AS SourceDatabase,
           StudentID, FirstName, LastName, Age, Major
    FROM DB2.dbo.Student;
GO

/* Demonstrate UNION for all three corresponding tables. */
SELECT N'DB1' AS SourceDatabase, StudentID, FirstName, LastName, Age, Major
FROM DB1.dbo.Student
UNION
SELECT N'DB2' AS SourceDatabase, StudentID, FirstName, LastName, Age, Major
FROM DB2.dbo.Student;
GO

SELECT N'DB1' AS SourceDatabase, TeacherID, FirstName, LastName, Department
FROM DB1.dbo.Teacher
UNION
SELECT N'DB2' AS SourceDatabase, TeacherID, FirstName, LastName, Department
FROM DB2.dbo.Teacher;
GO

SELECT N'DB1' AS SourceDatabase, CourseID, CourseName, Credits, TeacherID
FROM DB1.dbo.Course
UNION
SELECT N'DB2' AS SourceDatabase, CourseID, CourseName, Credits, TeacherID
FROM DB2.dbo.Course;
GO

/* Query the combined student view. */
SELECT SourceDatabase, StudentID, FirstName, LastName, Age, Major
FROM dbo.vw_AllStudents
ORDER BY SourceDatabase, StudentID;
GO
