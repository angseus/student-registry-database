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
  
