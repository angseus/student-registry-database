/* #### Tables #### */

/* Departments */
CREATE TABlE Departments
  ( department_abbreviation     VARCHAR(10),
    department_name  VARCHAR(50),
    PRIMARY KEY (department_abbreviation),
    UNIQUE (department_name)
  );

/* Programmes */
CREATE TABLE Programmes
  ( programme_abbreviation  VARCHAR(10),
    programme_name  VARCHAR(50),
    PRIMARY KEY (programme_abbreviation),
    UNIQUE (programme_name)
  );
  
/* Branches */
CREATE TABLE Branches
  ( branch VARCHAR(50),
    programme_abbreviation VARCHAR(10),
    FOREIGN KEY (programme_abbreviation) REFERENCES Programmes(programme_abbreviation),
    PRIMARY KEY (branch, programme_abbreviation)
  );
 /* Students */
CREATE TABLE Students
  ( student_id INT CHECK (LENGTH(student_id) = 10) NOT NULL,
    student_name VARCHAR(50),
    branch VARCHAR(50),
    programme_abbreviation VARCHAR(10),
    PRIMARY KEY (student_id),
    FOREIGN KEY (branch, programme_abbreviation) REFERENCES Branches(branch, programme_abbreviation)
  );

/* Courses */
CREATE TABLE Courses
  ( code VARCHAR(6),
    course_name VARCHAR (50),
    credit INT,
    PRIMARY KEY (code)
  );

/* RestrictedCourses */
CREATE TABLE RestrictedCourses
  ( code VARCHAR(6),
    attendees INT,
    PRIMARY KEY (code),
    FOREIGN KEY (code) REFERENCES Courses(code)
  );

/* Classifications */ 
CREATE TABLE Classifications
  ( classification VARCHAR(50), 
    PRIMARY KEY (classification)
  );

/* isHosting */
CREATE TABLE isHosting
  ( department_abbreviation VARCHAR(10),
    programme_abbreviation VARCHAR(10),
    FOREIGN KEY(department_abbreviation) REFERENCES Departments(department_abbreviation),
    FOREIGN KEY(programme_abbreviation) REFERENCES Programmes(programme_abbreviation)
  );
  
/* attendsTo */
/* Obsolete? Isn't used anywhere. */
CREATE TABLE attendsTo
  ( student_id INT,
    programme_abbreviation VARCHAR(10),
    branch  VARCHAR(50),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (branch, programme_abbreviation) REFERENCES Branches(branch, programme_abbreviation)
  );

/* hasCompleted */
CREATE TABLE hasCompleted
  ( student_id INT,
    code VARCHAR(6),
    grade VARCHAR(1),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (code) REFERENCES Courses(code),
    CONSTRAINT GradeCheck CHECK (grade in ('3', '4', '5', 'U'))
  );
  
/* hasRegistered */
CREATE TABLE hasRegistered
  ( student_id INT,
    code VARCHAR(6),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (code) REFERENCES Courses(code)
  );
  
/* recommendedCourse */
CREATE TABLE recommendedCourse
  ( code VARCHAR(6),
    programme_abbreviation VARCHAR(10),
    branch  VARCHAR(50),
    FOREIGN KEY (code) REFERENCES Courses(code),
    FOREIGN KEY (branch, programme_abbreviation) REFERENCES Branches(branch, programme_abbreviation)
  );

/* branchMandatory */
CREATE TABLE branchMandatory
  ( code VARCHAR(6),
    programme_abbreviation VARCHAR(10),
    branch  VARCHAR(50),
    FOREIGN KEY (code) REFERENCES Courses(code),
    FOREIGN KEY (branch, programme_abbreviation) REFERENCES Branches(branch, programme_abbreviation)
  );

/* programmeMandatory */  
CREATE TABLE programmeMandatory
  ( code VARCHAR(6),
    programme_abbreviation VARCHAR(10),
    FOREIGN KEY (code) REFERENCES Courses(code),
    FOREIGN KEY (programme_abbreviation) REFERENCES Programmes(programme_abbreviation)
  );
  
/* belongsTo */
/* Does it work correctly? */
CREATE TABLE belongsTo
  ( branch VARCHAR(50),
    programme_abbreviation VARCHAR(10),
    FOREIGN KEY (branch, programme_abbreviation) REFERENCES Branches(branch, programme_abbreviation)
  );

/* isGiven */
CREATE TABLE isGiven
  ( code  VARCHAR(6),
    department_abbreviation VARCHAR(10),
    FOREIGN KEY (code) REFERENCES Courses(code),
    FOREIGN KEY (department_abbreviation) REFERENCES Departments(department_abbreviation)
  );

/* hasClassifications */
CREATE TABLE hasClassifications
  ( code  VARCHAR(6),
    classification VARCHAR(50),
    FOREIGN KEY (code) REFERENCES Courses(code),
    FOREIGN KEY (classification) REFERENCES Classifications(classification)
  );

/* prerequisites */ 
CREATE TABLE prerequisites
  ( code1 VARCHAR(6),
    code2 VARCHAR(6),
    FOREIGN KEY (code1) REFERENCES Courses(code),
    FOREIGN KEY (code2) REFERENCES Courses(code)
  );

/* isWaiting */
CREATE TABLE isWaiting
  ( code  VARCHAR(6),
    student_id  INT,
    placeInQueue INT,
    FOREIGN KEY (code) REFERENCES Courses(code),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    CONSTRAINT isWaitingUnique UNIQUE (code, placeInQueue)
  );
  
/* #### Views #### */

CREATE VIEW CourseView AS 
  SELECT * FROM Courses;

/* StudentsFollowing */
CREATE VIEW StudentsFollowing AS 
  SELECT student_id, student_name, branch, programme_abbreviation 
  FROM Students;

/* Finished Courses */
CREATE VIEW FinishedCourses AS
  SELECT hC.student_id, hC.code, hC.grade, Courses.credit
  FROM hasCompleted hC
  INNER JOIN Courses ON hC.code = Courses.code;

/* Registrations */ 
CREATE VIEW Registrations AS
  SELECT student_id, code, 'Registered' AS status
  FROM hasRegistered
  UNION
  SELECT student_id, code, 'Waiting' AS status
  FROM isWaiting;

/* PassedCourses */
CREATE VIEW PassedCourses AS
  SELECT hC.student_id, hC.code, hC.grade, Courses.credit
  FROM hasCompleted hC  
  INNER JOIN Courses ON hC.code = Courses.code
  WHERE (hC.grade != 'U');

/* UnreadMandatory */
CREATE VIEW UnreadMandatory AS
  SELECT s.student_id, bM.code
  FROM Students s
  INNER JOIN branchMandatory bM ON s.programme_abbreviation = bM.programme_abbreviation AND s.branch = bM.branch
  UNION 
  SELECT s.student_id, pM.code
  FROM Students s
  INNER JOIN programmeMandatory pM ON s.programme_abbreviation = pM.programme_abbreviation
  MINUS
  SELECT student_id, code
  FROM hasCompleted hC
  WHERE hC.grade != 'U';

/* PathToGraduation */
CREATE VIEW pathToGraduationHelper AS
  SELECT s.student_id, pC.code, pC.credit FROM StudentsFollowing s
  INNER JOIN PassedCourses pC ON s.student_id = pC.student_id
  INNER JOIN branchMandatory bM ON s.programme_abbreviation = bM.programme_abbreviation
    AND s.branch = bM.branch AND pC.code = bM.code;

CREATE VIEW PathToGraduation AS
  WITH
  Credits AS (
    SELECT pC.student_id, SUM(pC.credit) AS Credits
    FROM PassedCourses pC
    INNER JOIN Courses ON pC.code = Courses.code
    GROUP BY student_id
  ),
  Credits_Branch AS (
    SELECT pGH.student_id, SUM(pGH.credit) AS Credits_Branch
    FROM pathToGraduationHelper pGH
    GROUP BY student_id
  ),
  Mandatory AS (
    SELECT uM.student_id, COUNT(uM.code) AS Mandatory
    FROM UnreadMandatory uM
    GROUP BY student_id
  ),
  Seminars AS (
    SELECT pC.student_id, COUNT(pC.code) AS Seminars 
    FROM PassedCourses pC
    INNER JOIN hasClassifications hC ON pC.code = hC.code AND hC.classification = 'Seminar'
    INNER JOIN Courses ON pC.code = Courses.code
    GROUP BY student_id
  ),
  Credits_Math AS (
    SELECT pC.student_id, SUM(pC.credit) AS Credits_Math
    FROM PassedCourses pC
    INNER JOIN hasClassifications hC ON pC.code = hC.code AND hC.classification = 'Math'
    GROUP BY student_id
  ),
  Credits_Research AS (
    SELECT pC.student_id, SUM(pC.credit) AS Credits_Research
    FROM PassedCourses pC
    INNER JOIN hasClassifications hC ON pC.code = hC.code AND hC.classification = 'Research'
    GROUP BY student_id
  )

  SELECT stud.student_id AS Student,
    NVL(Credits, '0') AS Credits,
    NVL(Credits_Branch, '0') AS Credits_Branch,
    NVL(Mandatory, '0') AS Mandatory,
    NVL(Seminars, '0') AS Seminars,
    NVL(Credits_Math, '0') AS Credits_Math,
    NVL(Credits_Research, '0') AS Credits_Research,
    (CASE WHEN
      Credits_Math >= 20 
      AND Credits_Research >= 10 
      AND Seminars >= 1 
      AND Mandatory IS NULL
      THEN 'Done'
      ELSE 'Not done' 
    END)
      AS Status 
    
  FROM Students stud
  LEFT JOIN Credits ON stud.student_id = Credits.student_id
  LEFT JOIN Credits_Branch ON stud.student_id = Credits_Branch.student_id
  LEFT JOIN Mandatory ON stud.student_id = Mandatory.student_id
  LEFT JOIN Seminars ON stud.student_id = Seminars.student_id
  LEFT JOIN Credits_Math ON stud.student_id = Credits_Math.student_id
  LEFT JOIN Credits_Research ON stud.student_id = Credits_Research.student_id;

/* #### Inserts #### */

/* Department */
INSERT INTO Departments(department_abbreviation, department_name)
  VALUES ('SSY', 'SignalerSystem');

INSERT INTO Departments(department_abbreviation, department_name)
  VALUES('IT', 'Informationsteknik');

INSERT INTO Departments(department_abbreviation, department_name)
  VALUES('CSE', 'Datainstitutionen');

/* Programme */
INSERT INTO Programmes(programme_abbreviation, programme_name)
  VALUES('IT', 'IT-programmet');

INSERT INTO Programmes(programme_abbreviation, programme_name)
  VALUES('M', 'Maskin-programmet');

INSERT INTO Programmes(programme_abbreviation, programme_name)
  VALUES('D', 'D-programmet');

INSERT INTO Programmes(programme_abbreviation, programme_name)
  VALUES('A', 'A-programmet');

/* Branch */
INSERT INTO Branches(branch, programme_abbreviation)
  VALUES('CSN', 'D');

INSERT INTO Branches(branch, programme_abbreviation)
  VALUES('CSALL', 'D');

INSERT INTO Branches(branch, programme_abbreviation)
  VALUES('CSALL', 'IT');

INSERT INTO Branches(branch, programme_abbreviation)
  VALUES('MPSOF', 'IT');

INSERT INTO Branches(branch, programme_abbreviation)
  VALUES('MPSOF', 'D');

INSERT INTO Branches(branch, programme_abbreviation)
  VALUES('RLHK', 'A');

INSERT INTO Branches(branch, programme_abbreviation)
  VALUES('Production', 'M');

/* Student */
INSERT INTO Students(student_id, student_name, branch, programme_abbreviation)
  VALUES(9303240890, 'Johan Angséus', 'CSN', 'D');

INSERT INTO Students(student_id, student_name, branch, programme_abbreviation)
  VALUES(9303240891, 'Johan Persson', 'CSALL', 'IT');

INSERT INTO Students(student_id, student_name, branch, programme_abbreviation)
  VALUES(9405334444, 'Jimmy Hedström', 'CSALL', 'D');

INSERT INTO Students(student_id, student_name, branch, programme_abbreviation)
  VALUES(9405223344, 'Anna Jansson', 'RLHK', 'A');

INSERT INTO Students(student_id, student_name, branch, programme_abbreviation)
  VALUES(9102224455, 'Borat Jansson', 'CSN', 'D');

INSERT INTO Students(student_id, student_name, branch, programme_abbreviation)
  VALUES(9102224454, 'Jenny Jansson', 'CSN', 'D');

INSERT INTO Students(student_id, student_name, branch, programme_abbreviation)
  VALUES(9102224433, 'Herman Nilsson', 'CSN', 'D');

INSERT INTO Students(student_id, student_name, branch, programme_abbreviation)
  VALUES(1234567890, 'Klara Klar', 'CSN', 'D');

INSERT INTO Students(student_id, student_name, branch, programme_abbreviation)
  VALUES(1111222244, 'Jimmy Götte', 'CSN', 'D');

/* Course */ 
INSERT INTO Courses(code, course_name, credit)
  VALUES('TDA357', 'Databases', 7.5);

INSERT INTO Courses(code, course_name, credit)
  VALUES('DAT290', 'Projektkurs', 4.5);

INSERT INTO Courses(code, course_name, credit)
  VALUES('MCA222', 'Maskiner och varuhantering', 7.5);

INSERT INTO Courses(code, course_name, credit)
  VALUES('TIF850', 'Fysik', 7.5);

INSERT INTO Courses(code, course_name, credit)
  VALUES('EDM250', 'Inledande matematik', 3);

INSERT INTO Courses(code, course_name, credit)
  VALUES('TDA222', 'Paralell programmering', 7.5);

INSERT INTO Courses(code, course_name, credit)
  VALUES('MKV123', 'Trattkunskap', 2.5);

INSERT INTO Courses(code, course_name, credit)
  VALUES('KEK253', 'Kellera', 7.5);

INSERT INTO Courses(code, course_name, credit)
  VALUES('TDE123', 'Tjenixen', 7.5);

INSERT INTO Courses(code, course_name, credit)
  VALUES('MAT122', 'Matematik för alla', 20);
  
INSERT INTO Courses(code, course_name, credit)
  VALUES('KLA111', 'Klara kan inte vinna', 10);

INSERT INTO Courses(code, course_name, credit)
  VALUES('FFF111', 'Full kurs 101', 7);

INSERT INTO Courses(code, course_name, credit)
  VALUES('FFF222', 'Full kurs 102', 7);

/* RestrictedCourse */
INSERT INTO RestrictedCourses(code, attendees)
  VALUES('TDA357', 10);

INSERT INTO RestrictedCourses(code, attendees)
  VALUES('FFF111', 2);
  
INSERT INTO RestrictedCourses(code, attendees)
  VALUES('FFF222', 2);

/* Classification */
INSERT INTO Classifications(classification)
  VALUES('Math');
  
INSERT INTO Classifications(classification)
  VALUES('Research');
  
INSERT INTO Classifications(classification)
  VALUES('Seminar');

/* isHosting */ 
INSERT INTO isHosting(department_abbreviation, programme_abbreviation)
  VALUES('CSE', 'D');

INSERT INTO isHosting(department_abbreviation, programme_abbreviation)
  VALUES('IT', 'IT');

INSERT INTO isHosting(department_abbreviation, programme_abbreviation)
  VALUES('SSY', 'M');

INSERT INTO isHosting(department_abbreviation, programme_abbreviation)
  VALUES('CSE', 'A');

/* attendsTo */
INSERT INTO attendsTo(student_id, programme_abbreviation, branch)
  VALUES(9303240890, 'D', 'CSN');

INSERT INTO attendsTo(student_id, programme_abbreviation, branch)
  VALUES(9303240891, 'IT', 'CSALL');

INSERT INTO attendsTo(student_id, programme_abbreviation, branch)
  VALUES(9405334444, 'A', 'RLHK');

INSERT INTO attendsTo(student_id, programme_abbreviation, branch)
  VALUES(9405223344, 'M', 'Production');

INSERT INTO attendsTo(student_id, programme_abbreviation, branch)
  VALUES(9102224433, 'D', 'CSN');

/* hasCompleted */
INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(9303240890, 'TDA357', 'U');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(9303240891, 'EDM250', '3');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(9303240890, 'DAT290', '4');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(9405334444, 'TIF850', '4');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(9405223344, 'MKV123', '5');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(9102224455, 'TDA222', '5');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(9102224454, 'TDA222', '4');

/* Student who completed all courses */ 
INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(1234567890, 'TDA357', '5');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(1234567890, 'DAT290', '5');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(1234567890, 'MCA222', '5');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(1234567890, 'TIF850', '5');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(1234567890, 'EDM250', '5');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(1234567890, 'TDA222', '5');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(1234567890, 'MKV123', '5');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(1234567890, 'KEK253', '5');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(1234567890, 'TDE123', '5');

INSERT INTO hasCompleted(student_id, code, grade)
  VALUES(1234567890, 'MAT122', '5');


/* hasRegistered */
INSERT INTO hasRegistered(student_id, code)
  VALUES(9303240890, 'EDM250');

INSERT INTO hasRegistered(student_id, code)
  VALUES(9405334444, 'TDA357');

INSERT INTO hasRegistered(student_id, code)
  VALUES(9405223344, 'EDM250');
  
INSERT INTO hasRegistered(student_id, code)
  VALUES(1234567890, 'KLA111');

INSERT INTO hasRegistered(student_id, code)
  VALUES(9405223344, 'FFF111');

INSERT INTO hasRegistered(student_id, code)
  VALUES(9405334444, 'FFF111');
  
INSERT INTO hasRegistered(student_id, code)
  VALUES(9405223344, 'FFF222');
  
INSERT INTO hasRegistered(student_id, code)
  VALUES(1234567890, 'FFF222');

INSERT INTO hasRegistered(student_id, code)
  VALUES(1111222244, 'FFF222');

INSERT INTO hasRegistered(student_id, code)
  VALUES(9405334444, 'FFF222');

/* recommendedCourse */
INSERT INTO recommendedCourse(code, programme_abbreviation, branch)
  VALUES('TDA357', 'D', 'CSN');

INSERT INTO recommendedCourse(code, programme_abbreviation, branch)
  VALUES('TIF850', 'IT', 'CSALL');

INSERT INTO recommendedCourse(code, programme_abbreviation, branch)
  VALUES('MKV123', 'M', 'Production');

INSERT INTO recommendedCourse(code, programme_abbreviation, branch)
  VALUES('EDM250', 'A', 'RLHK');

/* branchMandatory */
INSERT INTO branchMandatory(code, programme_abbreviation,branch)
  VALUES('TDA357', 'D', 'CSN');

INSERT INTO branchMandatory(code, programme_abbreviation,branch)
  VALUES('TDA222', 'D', 'CSN');

/* programmeMandatory */
INSERT INTO programmeMandatory(code, programme_abbreviation)
  VALUES('MCA222', 'M');

INSERT INTO programmeMandatory(code, programme_abbreviation)
  VALUES('TDE123', 'D');

/* belongsTo */
INSERT INTO belongsTo(branch, programme_abbreviation)
  VALUES('CSN', 'D');

INSERT INTO belongsTo(branch, programme_abbreviation)
  VALUES('CSALL', 'D');

INSERT INTO belongsTo(branch, programme_abbreviation)
  VALUES('CSALL', 'IT');

INSERT INTO belongsTo(branch, programme_abbreviation)
  VALUES('MPSOF', 'D');

INSERT INTO belongsTo(branch, programme_abbreviation)
  VALUES('MPSOF', 'IT');

INSERT INTO belongsTo(branch, programme_abbreviation)
  VALUES('RLHK', 'A');

INSERT INTO belongsTo(branch, programme_abbreviation)
  VALUES('Production', 'M');

/* isGiven */
INSERT INTO isGiven(code, department_abbreviation)
  VALUES('TDA357', 'CSE');

INSERT INTO isGiven(code, department_abbreviation)
  VALUES('DAT290', 'CSE');

INSERT INTO isGiven(code, department_abbreviation)
  VALUES('TDA222', 'IT');

INSERT INTO isGiven(code, department_abbreviation)
  VALUES('TIF850', 'SSY');

/* hasClassifications */
INSERT INTO hasClassifications(code, classification)
  VALUES('TIF850', 'Math');

INSERT INTO hasClassifications(code, classification)
  VALUES('TDA222', 'Seminar');

INSERT INTO hasClassifications(code, classification)
  VALUES('DAT290', 'Research');

INSERT INTO hasClassifications(code, classification)
  VALUES('MAT122', 'Math');

INSERT INTO hasClassifications(code, classification)
  VALUES('TDA357', 'Research');

/* prerequisites */
INSERT INTO prerequisites(code1, code2)
  VALUES('TDA357', 'DAT290');

INSERT INTO prerequisites(code1, code2)
  VALUES('MKV123', 'TDA222');

/* isWaiting */
INSERT INTO isWaiting(code, student_id, placeInQueue)
  VALUES('TDA357', '9102224455', 1);

INSERT INTO isWaiting(code, student_id, placeInQueue)
  VALUES('TDA357', '9102224433', 2);

INSERT INTO isWaiting(code, student_id, placeInQueue)
  VALUES('FFF111', '1234567890', 1);/* CourseQueuePostitions */ 
CREATE OR REPLACE VIEW CourseQueuePositions AS
   SELECT *
   FROM isWaiting;

