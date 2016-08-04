/* 	
Run this SQL file in order to clear the database to be able to perform all
create commands again.  
*/ 

/* Drop all tables */
DROP TABLE isWaiting;
DROP TABLE prerequisites;
DROP TABLE hasClassifications;
DROP TABLE isGiven;
DROP TABLE belongsTo;
DROP TABLE programmeMandatory;
DROP TABLE branchMandatory;
DROP TABLE recommendedCourse;
DROP TABLE hasRegistered;
DROP TABLE hasCompleted;
DROP TABLE attendsTo;
DROP TABLE RestrictedCourses;
DROP TABLE Courses;
DROP TABLE Classifications;
DROP TABLE isHosting;
DROP TABLE Students;
DROP TABLE Branches;
DROP TABLE Programmes;
DROP TABLE Departments;

/* Drop all views */ 
DROP VIEW StudentsFollowing;
DROP VIEW FinishedCourses;
DROP VIEW Registrations;
DROP VIEW PassedCourses;
DROP VIEW UnreadMandatory;
DROP VIEW pathToGraduationHelper;
DROP VIEW PathToGraduation;
DROP VIEW CourseQueuePositions;
DROP VIEW CourseView;