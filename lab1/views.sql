-- View: StudentsFollowing(student, program, branch) For all students,
--     their SSN, the program and the branch (if any) they are following.
--     The branch column is the only column in any of the views that is allowed to be NULLABLE.
-- DROP VIEW lab1.StudentsFollowing;
CREATE VIEW lab1.StudentsFollowing AS
SELECT s.ssn as Student , s.program as program, branch
FROM lab1.student s full outer join  lab1.belongsto b on  s.ssn = b.student  
ORDER BY student ;
-- View: FinishedCourses(student, course, grade, credits) For all students,
--     all finished courses, along with their codes,
--     grades (grade 'U', '3', '4' or '5') and number of credits.
--     The type of the grade should be a character type, e.g. TEXT.
-- DROP VIEW lab1.FinishedCourses;
CREATE VIEW lab1.FinishedCourses AS
SELECT t.student AS Student, t.course AS course, t.grade AS grade, c.credits AS credits
FROM lab1.taken t, lab1.course c
WHERE t.course = c.code;

-- View: Registrations(student, course, status) All registered and waiting students for all courses,
--     along with their waiting status ('registered' or 'waiting').
-- DROP VIEW lab1.Registrations;
CREATE VIEW lab1.Registrations AS
(SELECT student AS Student, course AS course, 'registered' AS status
FROM lab1.registered)
UNION
(SELECT student AS Student, course AS course, 'waiting' AS status
FROM lab1.waitingList)
ORDER BY course, status, student ;
-- View: PassedCourses(student, course, credits) For all students,
--     all passed courses, i.e. courses finished with a grade other than 'U',
--     and the number of credits for those courses.
--     This view is intended as a helper view towards the PathToGraduation view (and for task 4),
--     and will not be directly used by your application.
-- DROP VIEW lab1.PassedCourses CASCADE;
CREATE VIEW lab1.PassedCourses AS
SELECT student, course, credits
FROM lab1.FinishedCourses f
WHERE grade > 'U';

-- View: UnreadMandatory(student, course) For all students,
--     the mandatory courses (branch and programme) they have not yet passed.
--     This view is intended as a helper view towards the PathToGraduation view,
--     and will not be directly used by your application.
-- DROP VIEW lab1.UnreadMandatory;
CREATE VIEW lab1.UnreadMandatory AS
(SELECT s.ssn AS Student, MP.course AS course
FROM lab1.MandatoryProgram MP INNER JOIN lab1.student s ON s.program = MP.program)
UNION
(SELECT s.ssn AS Student, MB.course AS course
FROM 
((lab1.MandatoryBranch MB INNER JOIN lab1.Belongsto b ON b.branch = MB.branch)
INNER JOIN lab1.student s on b.student = s.ssn and s.program = MB.program
))
EXCEPT ALL
( SELECT student AS Student, course AS course
FROM lab1.PassedCourses)
ORDER BY student, course;
-- View: PathToGraduation(student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, status)
--      For all students, their path to graduation, i.e. 
--      a view with columns for 
--      - ssn: the student's SSN. 
--      - totalCredits: the number of credits they have taken. 
--      - mandatoryLeft: the number of courses that are mandatory for a branch or a program they have yet to read. 
--      - mathCredits: the number of credits they have taken in courses that are classified as math courses. 
--      - researchCredits: the number of credits they have taken in courses that are classified as research courses.
--      - seminarsCourses: the number of seminar courses they have read. 
--      - status: whether or not they qualify for graduation. 
--        The SQL type of this field should be BOOLEAN (i.e. TRUE or FALSE).
-- DROP VIEW lab1.PathToGraduation;
CREATE VIEW lab1.PathToGraduation AS
SELECT COALESCE(stud1, ssn1) AS student, COALESCE(TotalCredits, '0') AS TotalCredits, COALESCE(MandatoryLeft, '0') AS MandatoryLeft,
 COALESCE(MathCredits, '0') AS MathCredits,  COALESCE(ResearchCredits, '0') AS ResearchCredits, COALESCE(SeminarCourses, '0') AS SeminarCourses, 
CASE WHEN MandatoryLeft IS NULL AND MathCredits >=20 AND ResearchCredits >=10 AND SeminarCourses >=1 THEN TRUE
ELSE FALSE END AS status 
FROM
(SELECT student AS ssn, SUM(credits) AS TotalCredits2 FROM lab1.PassedCourses pc INNER JOIN lab1.RecommendedBranch rb ON 
 rb.course = pc.course GROUP BY student) t9
FULL OUTER JOIN
((SELECT student AS ssn1, SUM(credits) AS TotalCredits FROM lab1.PassedCourses GROUP BY student) t0
FULL OUTER JOIN
((SELECT COALESCE(Stud1, stud2) AS stud1,MandatoryLeft,MathCredits FROM
(SELECT student AS Stud1,COUNT(course) AS MandatoryLeft FROM lab1.UnreadMandatory GROUP BY student) t1
FULL OUTER JOIN
(SELECT pc.student AS Stud2,SUM(credits) AS MathCredits FROM lab1.PassedCourses pc, lab1.Classified c WHERE
 pc.course = c.course AND classification = 'Mathematical Course' GROUP BY student) t2
 ON t1.Stud1 = t2.Stud2) t5
FULL OUTER JOIN
(SELECT COALESCE(Stud3, stud4) AS stud3,ResearchCredits,SeminarCourses FROM
(SELECT pc.student AS Stud3,SUM(credits) AS ResearchCredits FROM lab1.PassedCourses pc, lab1.Classified c WHERE
 pc.course = c.course AND classification = 'Research Course' GROUP BY student) t3
FULL OUTER JOIN
(SELECT pc.student AS Stud4,COUNT(credits) AS SeminarCourses FROM lab1.PassedCourses pc, lab1.Classified c WHERE
 pc.course = c.course AND classification = 'Seminar Course' GROUP BY student) t4
ON t3.Stud3 = t4.Stud4) t6
ON t5.Stud1 = t6.Stud3) t7
ON t0.ssn1 = t7.Stud1) t8
ON t9.ssn = t8.ssn1
ORDER by ssn;

