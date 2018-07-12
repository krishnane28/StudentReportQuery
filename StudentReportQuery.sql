USE [CStoreProStudent]
GO

/****** Object:  StoredProcedure [dbo].[rptGetStudentReportCardByMajor]    Script Date: 06-07-2018 10:34:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[rptGetStudentReportCardByMajor]
	@InMajorID	INT
AS
BEGIN
	-- #Result table contains student details
	CREATE TABLE #Result
	(
		studentid INT,
		studentName NVARCHAR(50),
		majorID INT,
		majorName NVARCHAR(50),
		courseID INT,
		courseName NVARCHAR(50),
		courseGrade INT,
		coursePeriod NVARCHAR(50)
	);

	--To get the details of the student course grades by major
	WITH studentMajor(studentid, studentName, majorID, majorName)
	AS
	(
		SELECT studentid, studentName, majorID, majorName
		FROM dbo.tblStudent
		INNER JOIN dbo.tblMajors
		ON dbo.tblStudent.major = dbo.tblMajors.majorID WHERE majorID = @InMajorID
	),
	studentCourseGrades
	AS
	(
		SELECT studentMajor.studentid, studentMajor.studentName, studentMajor.majorID, studentMajor.majorName, 
			   courseID, courseGrade
		FROM studentMajor
		INNER JOIN dbo.tblCourseGrade
		ON studentMajor.studentid = dbo.tblCourseGrade.studentID
	)
	INSERT INTO #Result
	SELECT studentCourseGrades.studentid, studentCourseGrades.studentName, studentCourseGrades.majorID, 
           studentCourseGrades.majorName, studentCourseGrades.courseID, 
	       courseName, studentCourseGrades.courseGrade, CONCAT(courseSemester, ' ', courseYear) AS coursePeriod
	FROM studentCourseGrades
	INNER JOIN dbo.tblCourses
	ON studentCourseGrades.courseID = dbo.tblCourses.courseID
	ORDER BY studentCourseGrades.studentName, courseName;

	-- Final Report Table
	CREATE TABLE #tblReport
	(
		[Student Name] NVARCHAR(50),
		Major NVARCHAR(50),
		Course NVARCHAR(50),
		CourseID INT,
		[Fall 2014] NVARCHAR(3) DEFAULT '',
		[Spring 2014] NVARCHAR(3) DEFAULT '',
		[Fall 2015] NVARCHAR(3) DEFAULT '',
		[Spring 2015] NVARCHAR(3) DEFAULT '',
		[Fall 2016] NVARCHAR(3) DEFAULT '',
		[Spring 2016] NVARCHAR(3) DEFAULT '',
		[Fall 2017] NVARCHAR(3) DEFAULT '',
		[Spring 2017] NVARCHAR(3) DEFAULT '',
		[Fall 2018] NVARCHAR(3) DEFAULT '',
		[Spring 2018] NVARCHAR(3) DEFAULT '',
	);

	-- Transfer data from #Result table to #tblReport table
	INSERT INTO #tblReport ([Student Name], Major, Course, CourseID)
    SELECT studentName, majorName, courseName, courseID
    FROM #Result;

	-- Copy the grades from #Result table to #tblReport table to the corresponding semester and year
	UPDATE #tblReport
	SET 
		[Fall 2014] = CASE WHEN coursePeriod = 'Fall 2014' THEN CAST(courseGrade AS NVARCHAR(3)) ELSE '' END,
		[Spring 2014] = CASE WHEN coursePeriod = 'Spring 2014' THEN CAST(courseGrade AS NVARCHAR(3)) ELSE '' END, 
		[Fall 2015] = CASE WHEN coursePeriod = 'Fall 2015' THEN CAST(courseGrade AS NVARCHAR(3)) ELSE '' END,
		[Spring 2015] = CASE WHEN coursePeriod = 'Spring 2015' THEN CAST(courseGrade AS NVARCHAR(3)) ELSE '' END,
		[Fall 2016] = CASE WHEN coursePeriod = 'Fall 2016' THEN CAST(courseGrade AS NVARCHAR(3)) ELSE '' END,
		[Spring 2016] = CASE WHEN coursePeriod = 'Spring 2016' THEN CAST(courseGrade AS NVARCHAR(3)) ELSE '' END,
		[Fall 2017] = CASE WHEN coursePeriod = 'Fall 2017' THEN CAST(courseGrade AS NVARCHAR(3)) ELSE '' END,
		[Spring 2017] = CASE WHEN coursePeriod = 'Spring 2017' THEN CAST(courseGrade AS NVARCHAR(3)) ELSE '' END,
		[Fall 2018] = CASE WHEN coursePeriod = 'Fall 2018' THEN CAST(courseGrade AS NVARCHAR(3)) ELSE '' END,
		[Spring 2018] = CASE WHEN coursePeriod = 'Spring 2018' THEN CAST(courseGrade AS NVARCHAR(3)) ELSE '' END
	FROM (SELECT studentName, courseID, courseGrade, coursePeriod
		  FROM #Result
		 )[Res]
		 WHERE #tblReport.[Student Name] = [Res].studentName AND 
	           #tblReport.CourseID = [Res].courseID;

	SELECT [Student Name], Major, Course, [Fall 2014], [Spring 2014], [Fall 2015], [Spring 2015],
	       [Fall 2016], [Spring 2016], [Fall 2017], [Spring 2017], [Fall 2018], [Spring 2018]
	FROM #tblReport ORDER BY [Student Name], Course;
END

GO


