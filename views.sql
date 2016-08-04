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

