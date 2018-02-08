-- SELECT name from employee
-- and salary > ANY( SELECT salary from employee where department = 5 );
-----------------------------------------------------
-- SELECT MAX(salary), department FROM employee
-- GROUP BY department
-- ORDER BY department;
-----------------------------------------------------
SELECT * FROM employee
WHERE name LIKE '%joy%' ;