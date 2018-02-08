-- DROP SCHEMA lab1 CASCADE;
-- DROP TYPE IF EXISTS gradePossible CASCADE;
CREATE SCHEMA lab1 ;

-- DROP Table lab1.Program;
CREATE TABLE lab1.Program(
    name TEXT NOT NULL PRIMARY KEY, 
    abbreviation TEXT NOT NULL 
);
-- DROP Table lab1.Department;
Create TABLE lab1.Department(
    name TEXT NOT NULL PRIMARY KEY, 
    abbreviation TEXT NOT NULL UNIQUE
);
-- DROP Table lab1.Hosts;
CREATE TABLE lab1.Hosts(
    department TEXT NOT NULL, 
    program TEXT NOT NULL,
    CONSTRAINT FK_HostsD FOREIGN KEY ( department ) REFERENCES lab1.Department( name ),
    CONSTRAINT FK_HostsP FOREIGN KEY ( program ) REFERENCES lab1.Program( name ),
    PRIMARY KEY(department, program)
);
-- DROP Table lab1.Student;
CREATE TABLE lab1.Student(
    ssn INT NOT NULL PRIMARY KEY, 
    name TEXT NOT NULL, 
    login TEXT NOT NULL UNIQUE, 
    program TEXT NOT NULL,
    CONSTRAINT FK_studentP FOREIGN KEY (program) REFERENCES lab1.Program(name),
    UNIQUE( ssn, program)
);
-- DROP Table lab1.Branch;
CREATE TABLE lab1.Branch(
    name TEXT NOT NULL, --PRIMARY KEY, 
    program TEXT NOT NULL,
    PRIMARY KEY( name, program),
    CONSTRAINT FK_BranchP FOREIGN KEY (program) REFERENCES lab1.Program(name) 
);
-- DROP Table lab1.BelongsTo;
CREATE TABLE lab1.BelongsTo(
    student INT PRIMARY KEY, 
    branch TEXT NOT NULL, 
    program TEXT NOT NULL,
    CONSTRAINT FK_BelongsToS FOREIGN KEY (student) REFERENCES lab1.student(ssn),
    CONSTRAINT FK_BelongsToSP FOREIGN KEY (student, program) REFERENCES lab1.student(ssn,program),
    CONSTRAINT FK_BelongsToBP FOREIGN KEY (branch, program) REFERENCES lab1.Branch(name,program)
);
-- DROP Table lab1.Course;
CREATE TABLE lab1.Course(
    code INT PRIMARY KEY, 
    name TEXT NOT NULL, 
    credits FLOAT NOT NULL CHECK ( credits > 0 ) , 
    department TEXT NOT NULL,
    CONSTRAINT FK_CourseD FOREIGN KEY (department) REFERENCES lab1.Department(name) 
);

-- DROP Table lab1.Prerequisite;
CREATE TABLE lab1.Prerequisite(
    course INT, 
    prerequisite INT,
    PRIMARY KEY( course, prerequisite), 
    CONSTRAINT FK_PrerequisiteCC FOREIGN KEY (course) REFERENCES lab1.Course(code),
    CONSTRAINT FK_PrerequisitePC FOREIGN KEY (prerequisite) REFERENCES lab1.Course(code)  
);

-- DROP Table lab1.Classification;
CREATE TABLE lab1.Classification(
    name TEXT PRIMARY KEY 
);

-- DROP Table lab1.Classified;
CREATE TABLE lab1.Classified(
    course INT, 
    classification TEXT,
    PRIMARY KEY( course, classification),
    CONSTRAINT FK_ClassifiedCourse 
        FOREIGN KEY (course) REFERENCES lab1.Course(code),
    CONSTRAINT FK_ClassifiedClassfication 
        FOREIGN KEY (classification) REFERENCES lab1.Classification(name)
);

-- DROP Table lab1.MandatoryProgram;
CREATE TABLE lab1.MandatoryProgram(
    course INT, 
    program TEXT,
    PRIMARY KEY( course, program),
    CONSTRAINT FK_MC 
        FOREIGN KEY (course) REFERENCES lab1.Course(code),
    CONSTRAINT FK_MP 
        FOREIGN KEY (program) REFERENCES lab1.program(name)
);

-- DROP Table lab1.MandatoryBranch;
CREATE TABLE lab1.MandatoryBranch(
    course INT, 
    branch TEXT, 
    program TEXT,
    PRIMARY KEY( course, branch, program),
    CONSTRAINT FK_MC 
        FOREIGN KEY (course) REFERENCES lab1.Course(code),
    CONSTRAINT FK_MBP 
        FOREIGN KEY (branch, program) 
            REFERENCES lab1.Branch(name, program)
);

-- DROP Table lab1.RecommendedBranch;
CREATE TABLE lab1.RecommendedBranch(
    course INT, 
    branch TEXT, 
    program TEXT,
    PRIMARY KEY( branch, Program, course),
    CONSTRAINT FK_RC 
        FOREIGN KEY (course) REFERENCES lab1.Course(code),
    CONSTRAINT FK_RBP 
        FOREIGN KEY (branch, program) 
            REFERENCES lab1.Branch(name, program)
);

-- DROP Table lab1.Registered;
CREATE TABLE lab1.Registered(
    student INT, 
    course INT,
    PRIMARY KEY( student, course),
    CONSTRAINT FK_RS 
        FOREIGN KEY (student) REFERENCES lab1.student(ssn),
    CONSTRAINT FK_BelongsToSPRC 
        FOREIGN KEY (course) REFERENCES lab1.Course(code)
);

-- DROP Table lab1.Taken;
CREATE TYPE gradePossible AS ENUM('U','3','4','5');

CREATE TABLE lab1.Taken(
    student INT, 
    course INT, 
    grade gradePossible NOT NULL,
    PRIMARY KEY(student,course),
    CONSTRAINT FK_TS 
        FOREIGN KEY (student) REFERENCES lab1.Student(ssn),
    CONSTRAINT FK_TC 
        FOREIGN KEY (course) REFERENCES lab1.Course(code)
);

-- DROP Table lab1.LimitedCourse;
CREATE TABLE lab1.LimitedCourse(
    code INT  PRIMARY KEY, 
    seats INT NOT NULL check ( seats > 0),
    CONSTRAINT FK_LC 
        FOREIGN KEY (code) REFERENCES lab1.Course(code)
);

-- DROP Table lab1.WaitingList;
CREATE TABLE lab1.WaitingList(
    student INT NOT NULL, 
    course INT NOT NULL, 
    position INT NOT NULL CHECK( position > 0 ),
    CONSTRAINT FK_WS 
        FOREIGN KEY (student) REFERENCES lab1.Student(ssn),
    CONSTRAINT FK_WC 
        FOREIGN KEY (course) REFERENCES lab1.LimitedCourse(code),
    PRIMARY KEY (student, course),
    UNIQUE (position, course)
);