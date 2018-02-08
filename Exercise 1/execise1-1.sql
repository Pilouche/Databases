CREATE TABLE departments(
    department_id int NOT NULL,
    department_name char(50) NOT NULL,
    CONSTRAINT departments_pk PRIMARY KEY (department_id)
);

CREATE TABLE employees(
    employee_number int NOT NULL,
    employee_name TEXT PRIMARY KEY, 
    department int, 
    FOREIGN KEY (department) REFERENCES departments(department_id),
    salary int NOT NULL  
);