-- DROP SCHEMA lab1 CASCADE;
-- DROP TYPE IF EXISTS gradePossible CASCADE;

-- DROP Table Program;
CREATE TABLE Program(
    name TEXT NOT NULL PRIMARY KEY, 
    abbreviation TEXT NOT NULL 
);
-- DROP Table Department;
Create TABLE Department(
    name TEXT NOT NULL PRIMARY KEY, 
    abbreviation TEXT NOT NULL UNIQUE
);
-- DROP Table Hosts;
CREATE TABLE Hosts(
    department TEXT NOT NULL, 
    program TEXT NOT NULL,
    CONSTRAINT FK_HostsD FOREIGN KEY ( department ) REFERENCES Department( name ),
    CONSTRAINT FK_HostsP FOREIGN KEY ( program ) REFERENCES Program( name ),
    PRIMARY KEY(department, program)
);
-- DROP Table Student;
CREATE TABLE Student(
    ssn INT NOT NULL PRIMARY KEY, 
    name TEXT NOT NULL, 
    login TEXT NOT NULL UNIQUE, 
    program TEXT NOT NULL,
    CONSTRAINT FK_studentP FOREIGN KEY (program) REFERENCES Program(name),
    UNIQUE( ssn, program)
);
-- DROP Table Branch;
CREATE TABLE Branch(
    name TEXT NOT NULL, --PRIMARY KEY, 
    program TEXT NOT NULL,
    PRIMARY KEY( name, program),
    CONSTRAINT FK_BranchP FOREIGN KEY (program) REFERENCES Program(name) 
);
-- DROP Table BelongsTo;
CREATE TABLE BelongsTo(
    student INT PRIMARY KEY, 
    branch TEXT NOT NULL, 
    program TEXT NOT NULL,
    CONSTRAINT FK_BelongsToS FOREIGN KEY (student) REFERENCES student(ssn),
    CONSTRAINT FK_BelongsToSP FOREIGN KEY (student, program) REFERENCES student(ssn,program),
    CONSTRAINT FK_BelongsToBP FOREIGN KEY (branch, program) REFERENCES Branch(name,program)
);
-- DROP Table Course;
CREATE TABLE Course(
    code INT PRIMARY KEY, 
    name TEXT NOT NULL, 
    credits FLOAT NOT NULL CHECK ( credits > 0 ) , 
    department TEXT NOT NULL,
    CONSTRAINT FK_CourseD FOREIGN KEY (department) REFERENCES Department(name) 
);

-- DROP Table Prerequisite;
CREATE TABLE Prerequisite(
    course INT, 
    prerequisite INT,
    PRIMARY KEY( course, prerequisite), 
    CONSTRAINT FK_PrerequisiteCC FOREIGN KEY (course) REFERENCES Course(code),
    CONSTRAINT FK_PrerequisitePC FOREIGN KEY (prerequisite) REFERENCES Course(code)  
);

-- DROP Table Classification;
CREATE TABLE Classification(
    name TEXT PRIMARY KEY 
);

-- DROP Table Classified;
CREATE TABLE Classified(
    course INT, 
    classification TEXT,
    PRIMARY KEY( course, classification),
    CONSTRAINT FK_ClassifiedCourse 
        FOREIGN KEY (course) REFERENCES Course(code),
    CONSTRAINT FK_ClassifiedClassfication 
        FOREIGN KEY (classification) REFERENCES Classification(name)
);

-- DROP Table MandatoryProgram;
CREATE TABLE MandatoryProgram(
    course INT, 
    program TEXT,
    PRIMARY KEY( course, program),
    CONSTRAINT FK_MC 
        FOREIGN KEY (course) REFERENCES Course(code),
    CONSTRAINT FK_MP 
        FOREIGN KEY (program) REFERENCES program(name)
);

-- DROP Table MandatoryBranch;
CREATE TABLE MandatoryBranch(
    course INT, 
    branch TEXT, 
    program TEXT,
    PRIMARY KEY( course, branch, program),
    CONSTRAINT FK_MC 
        FOREIGN KEY (course) REFERENCES Course(code),
    CONSTRAINT FK_MBP 
        FOREIGN KEY (branch, program) 
            REFERENCES Branch(name, program)
);

-- DROP Table RecommendedBranch;
CREATE TABLE RecommendedBranch(
    course INT, 
    branch TEXT, 
    program TEXT,
    PRIMARY KEY( branch, Program, course),
    CONSTRAINT FK_RC 
        FOREIGN KEY (course) REFERENCES Course(code),
    CONSTRAINT FK_RBP 
        FOREIGN KEY (branch, program) 
            REFERENCES Branch(name, program)
);

-- DROP Table Registered;
CREATE TABLE Registered(
    student INT, 
    course INT,
    PRIMARY KEY( student, course),
    CONSTRAINT FK_RS 
        FOREIGN KEY (student) REFERENCES student(ssn),
    CONSTRAINT FK_BelongsToSPRC 
        FOREIGN KEY (course) REFERENCES Course(code)
);

-- DROP Table Taken;
CREATE TYPE gradePossible AS ENUM('U','3','4','5');

CREATE TABLE Taken(
    student INT, 
    course INT, 
    grade gradePossible NOT NULL,
    PRIMARY KEY(student,course),
    CONSTRAINT FK_TS 
        FOREIGN KEY (student) REFERENCES Student(ssn),
    CONSTRAINT FK_TC 
        FOREIGN KEY (course) REFERENCES Course(code)
);

-- DROP Table LimitedCourse;
CREATE TABLE LimitedCourse(
    code INT  PRIMARY KEY, 
    seats INT NOT NULL check (seats > 0),
    CONSTRAINT FK_LC 
        FOREIGN KEY (code) REFERENCES Course(code)
);

-- DROP Table WaitingList;
CREATE TABLE WaitingList(
    student INT NOT NULL, 
    course INT NOT NULL, 
    position INT NOT NULL CHECK( position > 0 ),
    CONSTRAINT FK_WS 
        FOREIGN KEY (student) REFERENCES Student(ssn),
    CONSTRAINT FK_WC 
        FOREIGN KEY (course) REFERENCES LimitedCourse(code),
    PRIMARY KEY (student, course),
    UNIQUE (position, course)
);

-- View: StudentsFollowing(student, program, branch) For all students,
--     their SSN, the program and the branch (if any) they are following.
--     The branch column is the only column in any of the views that is allowed to be NULLABLE.
-- DROP VIEW StudentsFollowing;
CREATE VIEW StudentsFollowing AS
SELECT s.ssn as Student , s.program as program, branch
FROM student s full outer join  belongsto b on  s.ssn = b.student  
ORDER BY student ;
-- View: FinishedCourses(student, course, grade, credits) For all students,
--     all finished courses, along with their codes,
--     grades (grade 'U', '3', '4' or '5') and number of credits.
--     The type of the grade should be a character type, e.g. TEXT.
-- DROP VIEW FinishedCourses;
CREATE VIEW FinishedCourses AS
SELECT t.student AS Student, t.course AS course, t.grade AS grade, c.credits AS credits
FROM taken t, course c
WHERE t.course = c.code;

-- View: Registrations(student, course, status) All registered and waiting students for all courses,
--     along with their waiting status ('registered' or 'waiting').
-- DROP VIEW Registrations;
CREATE VIEW Registrations AS
(SELECT student AS Student, course AS course, 'registered' AS status
FROM registered)
UNION
(SELECT student AS Student, course AS course, 'waiting' AS status
FROM waitingList)
ORDER BY course, status, student ;
-- View: PassedCourses(student, course, credits) For all students,
--     all passed courses, i.e. courses finished with a grade other than 'U',
--     and the number of credits for those courses.
--     This view is intended as a helper view towards the PathToGraduation view (and for task 4),
--     and will not be directly used by your application.
-- DROP VIEW PassedCourses CASCADE;
CREATE VIEW PassedCourses AS
SELECT student, course, credits
FROM FinishedCourses f
WHERE grade > 'U';

-- View: UnreadMandatory(student, course) For all students,
--     the mandatory courses (branch and programme) they have not yet passed.
--     This view is intended as a helper view towards the PathToGraduation view,
--     and will not be directly used by your application.
-- DROP VIEW UnreadMandatory;
CREATE VIEW UnreadMandatory AS
(SELECT s.ssn AS Student, MP.course AS course
FROM MandatoryProgram MP INNER JOIN student s ON s.program = MP.program)
UNION
(SELECT s.ssn AS Student, MB.course AS course
FROM 
((MandatoryBranch MB INNER JOIN Belongsto b ON b.branch = MB.branch)
INNER JOIN student s on b.student = s.ssn and s.program = MB.program
))
EXCEPT ALL
( SELECT student AS Student, course AS course
FROM PassedCourses)
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
-- DROP VIEW PathToGraduation;
CREATE VIEW PathToGraduation AS
SELECT COALESCE(stud1, ssn1) AS student, COALESCE(TotalCredits, '0') AS TotalCredits, COALESCE(MandatoryLeft, '0') AS MandatoryLeft,
 COALESCE(MathCredits, '0') AS MathCredits,  COALESCE(ResearchCredits, '0') AS ResearchCredits, COALESCE(SeminarCourses, '0') AS SeminarCourses, 
CASE WHEN MandatoryLeft IS NULL AND MathCredits >=20 AND ResearchCredits >=10 AND SeminarCourses >=1 THEN TRUE
ELSE FALSE END AS status 
FROM
(SELECT student AS ssn, SUM(credits) AS TotalCredits2 FROM PassedCourses pc INNER JOIN RecommendedBranch rb ON 
 rb.course = pc.course GROUP BY student) t9
FULL OUTER JOIN
((SELECT student AS ssn1, SUM(credits) AS TotalCredits FROM PassedCourses GROUP BY student) t0
FULL OUTER JOIN
((SELECT COALESCE(Stud1, stud2) AS stud1,MandatoryLeft,MathCredits FROM
(SELECT student AS Stud1,COUNT(course) AS MandatoryLeft FROM UnreadMandatory GROUP BY student) t1
FULL OUTER JOIN
(SELECT pc.student AS Stud2,SUM(credits) AS MathCredits FROM PassedCourses pc, Classified c WHERE
 pc.course = c.course AND classification = 'Mathematical Course' GROUP BY student) t2
 ON t1.Stud1 = t2.Stud2) t5
FULL OUTER JOIN
(SELECT COALESCE(Stud3, stud4) AS stud3,ResearchCredits,SeminarCourses FROM
(SELECT pc.student AS Stud3,SUM(credits) AS ResearchCredits FROM PassedCourses pc, Classified c WHERE
 pc.course = c.course AND classification = 'Research Course' GROUP BY student) t3
FULL OUTER JOIN
(SELECT pc.student AS Stud4,COUNT(credits) AS SeminarCourses FROM PassedCourses pc, Classified c WHERE
 pc.course = c.course AND classification = 'Seminar Course' GROUP BY student) t4
ON t3.Stud3 = t4.Stud4) t6
ON t5.Stud1 = t6.Stud3) t7
ON t0.ssn1 = t7.Stud1) t8
ON t9.ssn = t8.ssn1
ORDER by ssn;

--View: CourseQueuePositions(course,student,place)
--For all students who are in the queue for a course,
-- the course code, the student's identification number, 
-- and the student's current place in the queue 
--(the student who is first in a queue will have place "1" in that queue, etc.). 
-- DROP VIEW CourseQueuePositions;
CREATE VIEW CourseQueuePositions AS SELECT student, course, position AS place FROM waitingList;

-- TRUNCATE Program CASCADE;
-- TRUNCATE Department CASCADE;
-- TRUNCATE Hosts CASCADE;
-- TRUNCATE Student CASCADE;
-- TRUNCATE Branch CASCADE;
-- TRUNCATE BelongsTo CASCADE;
-- TRUNCATE Course CASCADE;
-- TRUNCATE Prerequisite CASCADE;
-- TRUNCATE Classification CASCADE;
-- TRUNCATE Classified CASCADE;
-- TRUNCATE MandatoryProgram CASCADE;
-- TRUNCATE MandatoryBranch CASCADE;
-- TRUNCATE RecommendedBranch CASCADE;
-- TRUNCATE Registered CASCADE;
-- TRUNCATE Taken CASCADE;
-- TRUNCATE LimitedCourse CASCADE;
-- TRUNCATE WaitingList CASCADE;
--pb with not null constraint
--INSERT INTO Program VALUES ();
--ok
INSERT INTO Program VALUES ('Computer Science and Engineering program','CSEP');
--pb with unique constraint on name
--INSERT INTO Program VALUES ('Computer Science and Engineering program','CSEP');
--ok, abbreviation not unique
INSERT INTO Program VALUES ('Computer Science and Environment program','CSEP');
--ok
INSERT INTO Program VALUES ('Industrial Engineering and Management program','IEMP');

--pb with abbreviation type
--INSERT INTO Department VALUES ('Computer Science',4);
--ok
INSERT INTO Department VALUES ('Computer Science','CS');
--pb with abbreviation unique
--INSERT INTO Department VALUES ('Chemistry Science','CS');
--ok
INSERT INTO Department VALUES ('Chemistry Science','CS2');
--ok
INSERT INTO Department VALUES ('Industrial Engineering','IE');

--ok
INSERT INTO Hosts VALUES('Computer Science','Computer Science and Engineering program');
--pb, program doesn't exist
--INSERT INTO Hosts VALUES('Computer Science','Computer Science and Mechanics program');
--ok
INSERT INTO Hosts VALUES('Computer Science','Computer Science and Environment program');
--ok
INSERT INTO Hosts VALUES('Industrial Engineering','Industrial Engineering and Management program');
--pb already existing
--INSERT INTO Hosts VALUES('Industrial Engineering','Industrial Engineering and Management program');

--all ok
INSERT INTO Student VALUES('100','James Cook','jcook','Computer Science and Engineering program');
INSERT INTO Student VALUES('101','Tim Cook','tcook','Computer Science and Engineering program');
INSERT INTO Student VALUES('102','Sarah Parker','sparker','Computer Science and Engineering program');
INSERT INTO Student VALUES('103','Ada Shelby','ashelby','Computer Science and Engineering program');
INSERT INTO Student VALUES('104','Vin Jones','vjones','Computer Science and Engineering program');
INSERT INTO Student VALUES('105','Jonas Diesel','jdiesel','Computer Science and Engineering program');
INSERT INTO Student VALUES('200','Julia Pitt','jpitt','Computer Science and Environment program');
INSERT INTO Student VALUES('201','Brad Roberts','broberts','Computer Science and Environment program');
INSERT INTO Student VALUES('300','Rita Martin','rmartin','Industrial Engineering and Management program');
INSERT INTO Student VALUES('301','Ben James','bjames','Industrial Engineering and Management program');

--all ok
INSERT INTO Branch VALUES('Computer Languages','Computer Science and Engineering program');
INSERT INTO Branch VALUES('Algorithms','Computer Science and Engineering program');
INSERT INTO Branch VALUES('Software Engineering','Computer Science and Engineering program');
INSERT INTO Branch VALUES('Computer Languages','Computer Science and Environment program');
INSERT INTO Branch VALUES('Datas for Environment','Computer Science and Environment program');
INSERT INTO Branch VALUES('Industrial Processes','Industrial Engineering and Management program');
INSERT INTO Branch VALUES('Management','Industrial Engineering and Management program');

--pb branch algorithms not in this program
--INSERT INTO BelongsTo VALUES(201,'Algorithms','Computer Science and Environment program');
--pb student not in this program
-- INSERT INTO BelongsTo VALUES(201,'Computer Languages','Computer Science and Engineering program');
--ok
-- INSERT INTO BelongsTo VALUES(201,'Datas for Environment','Computer Science and Environment program');
--pb already registered in one branch
INSERT INTO BelongsTo VALUES(201,'Computer Languages','Computer Science and Environment program');
--all ok
INSERT INTO BelongsTo VALUES(100,'Computer Languages','Computer Science and Engineering program');
INSERT INTO BelongsTo VALUES(101,'Computer Languages','Computer Science and Engineering program');
INSERT INTO BelongsTo VALUES(102,'Algorithms','Computer Science and Engineering program');
INSERT INTO BelongsTo VALUES(103,'Software Engineering','Computer Science and Engineering program');
INSERT INTO BelongsTo VALUES(104,'Software Engineering','Computer Science and Engineering program');
INSERT INTO BelongsTo VALUES(105,'Software Engineering','Computer Science and Engineering program');


--pb credits < 0
--INSERT INTO Course VALUES(1,'Introduction to Algorithms',-1,'Computer Science');
--all ok
INSERT INTO Course VALUES(01,'Introduction to Algorithms',10,'Computer Science');
INSERT INTO Course VALUES(02,'Databases',10,'Computer Science');
INSERT INTO Course VALUES(03,'Software Development',10,'Computer Science');
INSERT INTO Course VALUES(04,'Introduction to Java',10,'Computer Science');
INSERT INTO Course VALUES(05,'Java Advanced Course',10,'Computer Science');
INSERT INTO Course VALUES(06,'Algorithms Advanced Course',10,'Computer Science');
INSERT INTO Course VALUES(07,'Energy and Computers',10,'Computer Science');
INSERT INTO Course VALUES(08,'UML',10,'Computer Science');
INSERT INTO Course VALUES(11,'Industrial Project',10,'Industrial Engineering');
INSERT INTO Course VALUES(12,'Management and Business',10,'Industrial Engineering');
INSERT INTO Course VALUES(13,'Lines of Production',10,'Industrial Engineering');
INSERT INTO Course VALUES(14,'Automation',10,'Industrial Engineering');

--all ok
INSERT INTO Prerequisite VALUES (06,01);
INSERT INTO Prerequisite VALUES (05,04);

--all ok
INSERT INTO Classification VALUES ('Mathematical Course');
INSERT INTO Classification VALUES ('Research Course');
INSERT INTO Classification VALUES ('Seminar Course');

--all ok
INSERT INTO Classified VALUES(01,'Mathematical Course');
INSERT INTO Classified VALUES(02,'Seminar Course');
INSERT INTO Classified VALUES(03,'Seminar Course');
INSERT INTO Classified VALUES(04,'Research Course');
INSERT INTO Classified VALUES(05,'Research Course');
INSERT INTO Classified VALUES(06,'Mathematical Course');
INSERT INTO Classified VALUES(07,'Mathematical Course');
INSERT INTO Classified VALUES(08,'Seminar Course');
INSERT INTO Classified VALUES(11,'Research Course');
INSERT INTO Classified VALUES(12,'Seminar Course');
INSERT INTO Classified VALUES(13,'Mathematical Course');
INSERT INTO Classified VALUES(14,'Mathematical Course');

--all ok
INSERT INTO MandatoryProgram VALUES (01,'Computer Science and Engineering program');
INSERT INTO MandatoryProgram VALUES (02,'Computer Science and Engineering program');
INSERT INTO MandatoryProgram VALUES (01,'Computer Science and Environment program');
INSERT INTO MandatoryProgram VALUES (07,'Computer Science and Environment program');
INSERT INTO MandatoryProgram VALUES (11,'Industrial Engineering and Management program');

--all ok
INSERT INTO MandatoryBranch VALUES (06,'Algorithms','Computer Science and Engineering program');
INSERT INTO MandatoryBranch VALUES (05,'Computer Languages','Computer Science and Engineering program');
INSERT INTO MandatoryBranch VALUES (03,'Software Engineering','Computer Science and Engineering program');
INSERT INTO MandatoryBranch VALUES (02,'Datas for Environment','Computer Science and Environment program');
INSERT INTO MandatoryBranch VALUES (13,'Industrial Processes','Industrial Engineering and Management program');
INSERT INTO MandatoryBranch VALUES (12,'Management','Industrial Engineering and Management program');

--all ok
INSERT INTO RecommendedBranch VALUES (03,'Algorithms','Computer Science and Engineering program');
INSERT INTO RecommendedBranch VALUES (03,'Computer Languages','Computer Science and Engineering program');
INSERT INTO RecommendedBranch VALUES (08,'Software Engineering','Computer Science and Engineering program');
INSERT INTO RecommendedBranch VALUES (03,'Datas for Environment','Computer Science and Environment program');
INSERT INTO RecommendedBranch VALUES (14,'Industrial Processes','Industrial Engineering and Management program');
INSERT INTO RecommendedBranch VALUES (14,'Management','Industrial Engineering and Management program');

--pb did not take the prerequired course
INSERT INTO Registered VALUES (102,06);
--all ok, 102 fulfils all the courses for graduation
INSERT INTO Registered VALUES (102,01);
INSERT INTO Registered VALUES (102,02);
INSERT INTO Registered VALUES (102,04);
INSERT INTO Registered VALUES (101,01);
INSERT INTO Registered VALUES (101,02);
INSERT INTO Registered VALUES (100,02);
INSERT INTO Registered VALUES (101,04);
INSERT INTO Registered VALUES (105,02);
INSERT INTO Registered VALUES (103,04);
INSERT INTO Registered VALUES (104,02);
INSERT INTO Registered VALUES (105,04);
INSERT INTO Registered VALUES (104,01);
INSERT INTO Registered VALUES (100,03);
INSERT INTO Registered VALUES (101,03);
INSERT INTO Registered VALUES (102,03);

--pb not in enum
--INSERT INTO Taken VALUES (102,01,'X');
--all ok
INSERT INTO Taken VALUES (102,01,'3');
INSERT INTO Taken VALUES (102,02,'5');
INSERT INTO Taken VALUES (102,04,'3');
INSERT INTO Taken VALUES (102,06,'4');
INSERT INTO Taken VALUES (102,03,'5');
--pb nb of seats <= 0
--INSERT INTO LimitedCourse VALUES (01,-1);
--all ok
INSERT INTO LimitedCourse VALUES (01,3);
INSERT INTO LimitedCourse VALUES (03,3);

--pb position < 0
--INSERT INTO WaitingList VALUES (105,03,-1);
--all ok
INSERT INTO WaitingList VALUES (103,03,1);
INSERT INTO WaitingList VALUES (104,03,2);
INSERT INTO WaitingList VALUES (105,03,3);
INSERT INTO WaitingList VALUES (100,01,1);
INSERT INTO WaitingList VALUES (103,01,2);
INSERT INTO WaitingList VALUES (105,01,3);