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
  VALUES('FFF111', '1234567890', 1);