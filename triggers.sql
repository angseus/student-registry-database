/* CourseQueuePostitions */ 
CREATE OR REPLACE VIEW CourseQueuePositions AS
   SELECT *
   FROM isWaiting;

CREATE OR REPLACE TRIGGER CourseRegistration
INSTEAD OF INSERT ON Registrations
REFERENCING NEW AS new
FOR EACH ROW
DECLARE
maxNum INT;
currentNum INT;
limited INT;
completed INT;
prerequisites INT;
prerequisitesCompleted INT;
registeredForCourse INT;
isWaitingForCourse INT;
currentWaiting INT; 

BEGIN
   /* SELECT and COUNT all rows from PassedCourses
      where the student_id and coure code is the same
      as the inserted one. 
      Return: 1 if we completed the course earlier
      and 0 if we haven't completed it. 
   */ 
   SELECT COUNT (*) INTO completed FROM 
   PassedCourses pC WHERE
   pC.student_id = :new.student_id AND code = :new.code;

   /* SELECT and COUNT all rows from prerequisites 
      where the course code we are trying to register 
      to is the same as code1 (which is the course
      which require code2 to be completed first) 
      Return: The number of prerequisites for a
      given course.
   */
   SELECT COUNT (*) INTO prerequisites FROM 
   prerequisites pRQ WHERE
   prQ.code1 = :new.code;

   /* SELECT and COUNT all rows from prerequisites
      and join them with PassedCourses to see if
      we completed all prerequisites. 
      Return: The number of prerequisites we completed.
   */
   SELECT COUNT (*) INTO prerequisitesCompleted FROM
   prerequisites pRQ 
   INNER JOIN PassedCourses pC ON pRQ.code2 = pC.code AND pRQ.code1 = :new.code;

   /* SELECT and COUNT all registrations from
      hasRegistered and check if the student 
      is already registered for the course or not.
      Return: 1 if we are registered, 0 if not.
   */
   SELECT COUNT (*) INTO registeredForCourse FROM 
   hasRegistered hR WHERE 
   hR.student_id = :new.student_id AND hR.code = :new.code;

   /* SELECT and COUNT from the waitingqueue
      for a specific course. If we are in the
      waiting queue we should not be allowed
      to be put in it again
   */
   SELECT COUNT (*) INTO isWaitingForCourse FROM 
   isWaiting iW WHERE 
   iW.student_id = :new.student_id AND iW.code = :new.code;

   /* SELECT and COUNT all courses from RestrictedCourses 
      where the new code is the same as the code in 
      RestrictedCourses.
      Return: 1 if the course is limited, 0 if not.
   */
   SELECT COUNT (*) INTO limited FROM RestrictedCourses rC WHERE rC.code = :new.code;

   /* Check if we have passed the course earlier,
      that we completed all prerequisites and check
      if we already are registered for the course.
    */

   IF prerequisites = prerequisitesCompleted
      AND registeredForCourse = 0
      AND isWaitingForCourse = 0
      AND completed = 0 
   THEN 
      /* If the course is limited try to join it, otherwise join the queue */
      IF limited > 0 THEN 
         SELECT attendees INTO maxNum FROM RestrictedCourses rC WHERE rC.code = :new.code;
         SELECT COUNT (*) INTO currentNum
         FROM Registrations rG
         WHERE rG.code = :new.code AND rG.status = 'Registered';
         SELECT COUNT (*) INTO currentWaiting
         FROM Registrations rG
         WHERE rG.code = :new.code AND rG.status = 'Waiting';

         IF currentNum < maxNum THEN -- The course is not full yet. We have a place
            INSERT INTO hasRegistered(student_id, code)
               VALUES(:new.student_id, :new.code);
         ELSE -- The course is full. We start to wait for someone to unregister
            INSERT INTO isWaiting(code, student_id, placeInQueue)
               VALUES(:new.code, :new.student_id, (currentWaiting+1));
         END IF;
      ELSE --normal course
         INSERT INTO hasRegistered(student_id, code)
            VALUES(:new.student_id, :new.code);
      END IF;
   ELSE 
      RAISE_APPLICATION_ERROR
         (-20004, 'The student is already registered, not completed all prerequisites, 
            already completed the course of is already registered or waiting for it.');
   END IF;
END CourseRegistration;

/

CREATE OR REPLACE TRIGGER CourseUnregistration
INSTEAD OF DELETE ON Registrations
REFERENCING OLD AS old
FOR EACH ROW
DECLARE
firstStuInQueue Students.student_id%TYPE; -- Set type automatically after the type in database
waitingNum INT;
maxNum INT;
currentNum INT;
registeredOrWaiting INT;
isWaitingForCourse INT;
limited INT;
delStudent Students.student_id%TYPE;

BEGIN
   SELECT COUNT (*) INTO registeredOrWaiting FROM 
   Registrations rG WHERE 
   rG.student_id = :old.student_id AND rG.code = :old.code;

   IF registeredOrWaiting > 0 THEN -- Check if we are registered already or not
      SELECT COUNT (*) INTO limited FROM RestrictedCourses rC WHERE rC.code = :old.code;
      IF limited > 0 THEN -- Check if the course is limited / restricted
         SELECT attendees INTO maxNum FROM RestrictedCourses rC WHERE rC.code = :old.code;
         
         SELECT COUNT (*) INTO isWaitingForCourse FROM Registrations rG WHERE 
            rG.student_id = :old.student_id AND rG.code = :old.code AND status = 'Waiting';

         IF isWaitingForCourse > 0 THEN -- If we are waiting for the course, delete us from the queue
            SELECT placeInQueue INTO delStudent FROM isWaiting WHERE student_id = :old.student_id
               AND code = :old.code;
            DELETE FROM isWaiting iW
            WHERE iW.student_id = :old.student_id AND iW.code = :old.code;
            UPDATE isWaiting SET placeInQueue = placeInQueue - 1
            WHERE placeInQueue > delStudent AND code = :old.code;
         ELSE 
            DELETE FROM hasRegistered hR -- We are registered, remove us from Registrations
            WHERE hR.student_id = :old.student_id AND hR.code = :old.code;

            SELECT COUNT (*) INTO currentNum -- Check how many there are registered after we deleted ourselves
            FROM Registrations rG
            WHERE rG.code = :old.code AND status = 'Registered';

            SELECT COUNT (*) INTO waitingNum FROM isWaiting iW WHERE iW.code = :old.code;
            IF waitingNum > 0 AND currentNum < maxNum THEN -- Check if students are queueing and if there are spots left
               --SELECT student_id INTO firstStuInQueue
               --FROM CourseQueuePostitions cQP WHERE cQP.place = 1;   -- Fetch id of the first student in queue
               -- Sorting students by dateregistered. Tested and working
               SELECT student_id INTO firstStuInQueue FROM isWaiting WHERE placeInQueue = 1 AND code = :old.code; -- First in queue

               INSERT INTO hasRegistered(student_id, code) -- Insert the new student as Registered
                  VALUES(firstStuInQueue, :old.code);
               DELETE FROM isWaiting iW -- Delete the new student from waiting queue
               WHERE iW.student_id = firstStuInQueue AND iW.code = :old.code; -- Delete the newly registered student from isWaiting

               UPDATE isWaiting -- Update the queue
               SET placeInQueue = placeInQueue - 1
               WHERE placeInQueue > 1 AND code = :old.code;
            END IF;
         END IF;
      ELSE
         DELETE FROM hasRegistered hR -- Not limited, just delete the registration
         WHERE hR.student_id = :old.student_id AND hR.code = :old.code;
      END IF;
   ELSE RAISE_APPLICATION_ERROR(-20004, 'Not registered for that course'); -- Raise an error if we aren't registered. Obsolete
   END IF;
END CourseUnregistration;