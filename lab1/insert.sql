-- TRUNCATE lab1.Program CASCADE;
-- TRUNCATE lab1.Department CASCADE;
-- TRUNCATE lab1.Hosts CASCADE;
-- TRUNCATE lab1.Student CASCADE;
-- TRUNCATE lab1.Branch CASCADE;
-- TRUNCATE lab1.BelongsTo CASCADE;
-- TRUNCATE lab1.Course CASCADE;
-- TRUNCATE lab1.Prerequisite CASCADE;
-- TRUNCATE lab1.Classification CASCADE;
-- TRUNCATE lab1.Classified CASCADE;
-- TRUNCATE lab1.MandatoryProgram CASCADE;
-- TRUNCATE lab1.MandatoryBranch CASCADE;
-- TRUNCATE lab1.RecommendedBranch CASCADE;
-- TRUNCATE lab1.Registered CASCADE;
-- TRUNCATE lab1.Taken CASCADE;
-- TRUNCATE lab1.LimitedCourse CASCADE;
-- TRUNCATE lab1.WaitingList CASCADE;
--pb with not null constraint
--INSERT INTO lab1.Program VALUES ();
--ok
INSERT INTO lab1.Program VALUES ('Computer Science and Engineering program','CSEP');
--pb with unique constraint on name
--INSERT INTO lab1.Program VALUES ('Computer Science and Engineering program','CSEP');
--ok, abbreviation not unique
INSERT INTO lab1.Program VALUES ('Computer Science and Environment program','CSEP');
--ok
INSERT INTO lab1.Program VALUES ('Industrial Engineering and Management program','IEMP');

--pb with abbreviation type
--INSERT INTO lab1.Department VALUES ('Computer Science',4);
--ok
INSERT INTO lab1.Department VALUES ('Computer Science','CS');
--pb with abbreviation unique
--INSERT INTO lab1.Department VALUES ('Chemistry Science','CS');
--ok
INSERT INTO lab1.Department VALUES ('Chemistry Science','CS2');
--ok
INSERT INTO lab1.Department VALUES ('Industrial Engineering','IE');

--ok
INSERT INTO lab1.Hosts VALUES('Computer Science','Computer Science and Engineering program');
--pb, program doesn't exist
--INSERT INTO lab1.Hosts VALUES('Computer Science','Computer Science and Mechanics program');
--ok
INSERT INTO lab1.Hosts VALUES('Computer Science','Computer Science and Environment program');
--ok
INSERT INTO lab1.Hosts VALUES('Industrial Engineering','Industrial Engineering and Management program');
--pb already existing
--INSERT INTO lab1.Hosts VALUES('Industrial Engineering','Industrial Engineering and Management program');

--all ok
INSERT INTO lab1.Student VALUES('100','James Cook','jcook','Computer Science and Engineering program');
INSERT INTO lab1.Student VALUES('101','Tim Cook','tcook','Computer Science and Engineering program');
INSERT INTO lab1.Student VALUES('102','Sarah Parker','sparker','Computer Science and Engineering program');
INSERT INTO lab1.Student VALUES('103','Ada Shelby','ashelby','Computer Science and Engineering program');
INSERT INTO lab1.Student VALUES('104','Vin Jones','vjones','Computer Science and Engineering program');
INSERT INTO lab1.Student VALUES('105','Jonas Diesel','jdiesel','Computer Science and Engineering program');
INSERT INTO lab1.Student VALUES('200','Julia Pitt','jpitt','Computer Science and Environment program');
INSERT INTO lab1.Student VALUES('201','Brad Roberts','broberts','Computer Science and Environment program');
INSERT INTO lab1.Student VALUES('300','Rita Martin','rmartin','Industrial Engineering and Management program');
INSERT INTO lab1.Student VALUES('301','Ben James','bjames','Industrial Engineering and Management program');

--all ok
INSERT INTO lab1.Branch VALUES('Computer Languages','Computer Science and Engineering program');
INSERT INTO lab1.Branch VALUES('Algorithms','Computer Science and Engineering program');
INSERT INTO lab1.Branch VALUES('Software Engineering','Computer Science and Engineering program');
INSERT INTO lab1.Branch VALUES('Computer Languages','Computer Science and Environment program');
INSERT INTO lab1.Branch VALUES('Datas for Environment','Computer Science and Environment program');
INSERT INTO lab1.Branch VALUES('Industrial Processes','Industrial Engineering and Management program');
INSERT INTO lab1.Branch VALUES('Management','Industrial Engineering and Management program');

--pb branch algorithms not in this program
--INSERT INTO lab1.BelongsTo VALUES(201,'Algorithms','Computer Science and Environment program');
--pb student not in this program
-- INSERT INTO lab1.BelongsTo VALUES(201,'Computer Languages','Computer Science and Engineering program');
--ok
-- INSERT INTO lab1.BelongsTo VALUES(201,'Datas for Environment','Computer Science and Environment program');
--pb already registered in one branch
INSERT INTO lab1.BelongsTo VALUES(201,'Computer Languages','Computer Science and Environment program');
--all ok
INSERT INTO lab1.BelongsTo VALUES(100,'Computer Languages','Computer Science and Engineering program');
INSERT INTO lab1.BelongsTo VALUES(101,'Computer Languages','Computer Science and Engineering program');
INSERT INTO lab1.BelongsTo VALUES(102,'Algorithms','Computer Science and Engineering program');
INSERT INTO lab1.BelongsTo VALUES(103,'Software Engineering','Computer Science and Engineering program');
INSERT INTO lab1.BelongsTo VALUES(104,'Software Engineering','Computer Science and Engineering program');
INSERT INTO lab1.BelongsTo VALUES(105,'Software Engineering','Computer Science and Engineering program');


--pb credits < 0
--INSERT INTO lab1.Course VALUES(1,'Introduction to Algorithms',-1,'Computer Science');
--all ok
INSERT INTO lab1.Course VALUES(01,'Introduction to Algorithms',10,'Computer Science');
INSERT INTO lab1.Course VALUES(02,'Databases',10,'Computer Science');
INSERT INTO lab1.Course VALUES(03,'Software Development',10,'Computer Science');
INSERT INTO lab1.Course VALUES(04,'Introduction to Java',10,'Computer Science');
INSERT INTO lab1.Course VALUES(05,'Java Advanced Course',10,'Computer Science');
INSERT INTO lab1.Course VALUES(06,'Algorithms Advanced Course',10,'Computer Science');
INSERT INTO lab1.Course VALUES(07,'Energy and Computers',10,'Computer Science');
INSERT INTO lab1.Course VALUES(08,'UML',10,'Computer Science');
INSERT INTO lab1.Course VALUES(11,'Industrial Project',10,'Industrial Engineering');
INSERT INTO lab1.Course VALUES(12,'Management and Business',10,'Industrial Engineering');
INSERT INTO lab1.Course VALUES(13,'Lines of Production',10,'Industrial Engineering');
INSERT INTO lab1.Course VALUES(14,'Automation',10,'Industrial Engineering');

--all ok
INSERT INTO lab1.Prerequisite VALUES (06,01);
INSERT INTO lab1.Prerequisite VALUES (05,04);

--all ok
INSERT INTO lab1.Classification VALUES ('Mathematical Course');
INSERT INTO lab1.Classification VALUES ('Research Course');
INSERT INTO lab1.Classification VALUES ('Seminar Course');

--all ok
INSERT INTO lab1.Classified VALUES(01,'Mathematical Course');
INSERT INTO lab1.Classified VALUES(02,'Seminar Course');
INSERT INTO lab1.Classified VALUES(03,'Seminar Course');
INSERT INTO lab1.Classified VALUES(04,'Research Course');
INSERT INTO lab1.Classified VALUES(05,'Research Course');
INSERT INTO lab1.Classified VALUES(06,'Mathematical Course');
INSERT INTO lab1.Classified VALUES(07,'Mathematical Course');
INSERT INTO lab1.Classified VALUES(08,'Seminar Course');
INSERT INTO lab1.Classified VALUES(11,'Research Course');
INSERT INTO lab1.Classified VALUES(12,'Seminar Course');
INSERT INTO lab1.Classified VALUES(13,'Mathematical Course');
INSERT INTO lab1.Classified VALUES(14,'Mathematical Course');

--all ok
INSERT INTO lab1.MandatoryProgram VALUES (01,'Computer Science and Engineering program');
INSERT INTO lab1.MandatoryProgram VALUES (02,'Computer Science and Engineering program');
INSERT INTO lab1.MandatoryProgram VALUES (01,'Computer Science and Environment program');
INSERT INTO lab1.MandatoryProgram VALUES (07,'Computer Science and Environment program');
INSERT INTO lab1.MandatoryProgram VALUES (11,'Industrial Engineering and Management program');

--all ok
INSERT INTO lab1.MandatoryBranch VALUES (06,'Algorithms','Computer Science and Engineering program');
INSERT INTO lab1.MandatoryBranch VALUES (05,'Computer Languages','Computer Science and Engineering program');
INSERT INTO lab1.MandatoryBranch VALUES (03,'Software Engineering','Computer Science and Engineering program');
INSERT INTO lab1.MandatoryBranch VALUES (02,'Datas for Environment','Computer Science and Environment program');
INSERT INTO lab1.MandatoryBranch VALUES (13,'Industrial Processes','Industrial Engineering and Management program');
INSERT INTO lab1.MandatoryBranch VALUES (12,'Management','Industrial Engineering and Management program');

--all ok
INSERT INTO lab1.RecommendedBranch VALUES (03,'Algorithms','Computer Science and Engineering program');
INSERT INTO lab1.RecommendedBranch VALUES (03,'Computer Languages','Computer Science and Engineering program');
INSERT INTO lab1.RecommendedBranch VALUES (08,'Software Engineering','Computer Science and Engineering program');
INSERT INTO lab1.RecommendedBranch VALUES (03,'Datas for Environment','Computer Science and Environment program');
INSERT INTO lab1.RecommendedBranch VALUES (14,'Industrial Processes','Industrial Engineering and Management program');
INSERT INTO lab1.RecommendedBranch VALUES (14,'Management','Industrial Engineering and Management program');

--pb did not take the prerequired course
INSERT INTO lab1.Registered VALUES (102,06);
--all ok, 102 fulfils all the courses for graduation
INSERT INTO lab1.Registered VALUES (102,01);
INSERT INTO lab1.Registered VALUES (102,02);
INSERT INTO lab1.Registered VALUES (102,04);
--INSERT INTO lab1.Registered VALUES (102,06);
INSERT INTO lab1.Registered VALUES (101,01);
INSERT INTO lab1.Registered VALUES (101,02);
INSERT INTO lab1.Registered VALUES (100,02);
INSERT INTO lab1.Registered VALUES (101,04);
INSERT INTO lab1.Registered VALUES (105,02);
INSERT INTO lab1.Registered VALUES (103,04);
INSERT INTO lab1.Registered VALUES (104,02);
INSERT INTO lab1.Registered VALUES (105,04);
--pb number of places limited
INSERT INTO lab1.Registered VALUES (104,01);
INSERT INTO lab1.Registered VALUES (105,01);
INSERT INTO lab1.Registered VALUES (100,01);
INSERT INTO lab1.Registered VALUES (103,01);
INSERT INTO lab1.Registered VALUES (100,03);
INSERT INTO lab1.Registered VALUES (101,03);
INSERT INTO lab1.Registered VALUES (102,03);
INSERT INTO lab1.Registered VALUES (103,03);
INSERT INTO lab1.Registered VALUES (104,03);
INSERT INTO lab1.Registered VALUES (105,03);

--pb not in enum
--INSERT INTO lab1.Taken VALUES (102,01,'X');
--all ok
INSERT INTO lab1.Taken VALUES (102,01,'3');
INSERT INTO lab1.Taken VALUES (102,02,'5');
INSERT INTO lab1.Taken VALUES (102,04,'3');
INSERT INTO lab1.Taken VALUES (102,06,'4');
INSERT INTO lab1.Taken VALUES (102,03,'5');
--pb nb of seats <= 0
--INSERT INTO lab1.LimitedCourse VALUES (01,-1);
--all ok
INSERT INTO lab1.LimitedCourse VALUES (01,3);
INSERT INTO lab1.LimitedCourse VALUES (03,3);

--pb position < 0
--INSERT INTO lab1.WaitingList VALUES (105,03,-1);
--all ok
INSERT INTO lab1.WaitingList VALUES (103,03,1);
INSERT INTO lab1.WaitingList VALUES (104,03,2);
INSERT INTO lab1.WaitingList VALUES (105,03,3);
INSERT INTO lab1.WaitingList VALUES (100,01,1);
INSERT INTO lab1.WaitingList VALUES (103,01,2);
INSERT INTO lab1.WaitingList VALUES (105,01,3);