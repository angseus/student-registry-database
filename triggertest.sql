/*
#############################
# Tests for triggers insert #
#############################
*/

/* Fetch current state of Registrations and the queue */
SELECT * FROM Registrations;
SELECT * FROM CourseQueuePositions;

/* Register student 9405334444 to KLA111 (Unrestricte course) */
INSERT INTO Registrations(student_id, code)
	VALUES(9405334444, 'KLA111');

SELECT * FROM Registrations; -- Student registered
SELECT * FROM CourseQueuePositions; -- Student not in queue

/* Register student 1234567890 to a registered course where he/she is queued */
INSERT INTO Registrations(student_id, code)
	VALUES (1234567890, 'FFF111');

SELECT * FROM Registrations; -- Student registered as 'Waiting'
SELECT * FROM CourseQueuePositions; -- Student in queue with a time and place

/* Register student 1111222244 for a course with prerequisites that are not met */
INSERT INTO Registrations(student_id, code)
	VALUES(1111222244, 'TDA357');

SELECT * FROM Registrations; -- Unchanged
SELECT * FROM CourseQueuePositions; -- Unchanged

/* Register student 9405334444 for KLA111 again (already registered)  */
INSERT INTO Registrations(student_id, code)
	VALUES(9405334444, 'KLA111');

SELECT * FROM Registrations; -- Unchanged
SELECT * FROM CourseQueuePositions; -- Unchanged

/* Register student 9303240891 for EDM250 which he already completed */
INSERT INTO Registrations(student_id, code)
	VALUES(9303240891 ,'EDM250');

SELECT * FROM Registrations; -- Unchanged
SELECT * FROM CourseQueuePositions; -- Unchanged

/*
#############################
# Tests for triggers delete #
#############################
*/

/* Fetch current state of Registrations and the queue */
SELECT * FROM Registrations;
SELECT * FROM CourseQueuePositions;

/* Student 1234567890 is put in the waiting queue for FFF111 
INSERT INTO Registrations(student_id, code)
	VALUES(1234567890, 'FFF111');

SELECT * FROM Registrations; -- New registration as waiting
SELECT * FROM CourseQueuePositions; -- New entry */

/* Student 9405223344 is unregistered from FFF111, 1234567890 should be Registered */
DELETE FROM Registrations
	WHERE student_id = 9405223344 AND code = 'FFF111';

SELECT * FROM Registrations; -- One unregister, and 1234567890 status changed to Registered
SELECT * FROM CourseQueuePositions; -- One removed 

/* Register student 9405223344 again as waiting. Then remove him/her from queue */
INSERT INTO Registrations(student_id, code)
	VALUES(9405223344, 'FFF111');

SELECT * FROM Registrations; -- One more as waiting
SELECT * FROM CourseQueuePositions; -- One more entry

DELETE FROM Registrations
	WHERE student_id = 9405223344 AND code = 'FFF111';

SELECT * FROM Registrations; -- One entry removed
SELECT * FROM CourseQueuePositions; -- One entry removed