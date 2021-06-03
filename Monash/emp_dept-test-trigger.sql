SET ECHO ON
SET SERVEROUTPUT ON

--- Insert EMPLOYEE ---

SELECT
    *
FROM
    department;

SELECT
    *
FROM
    employee;

INSERT INTO employee VALUES (
	2,
	'Emp 2',
	2000,
	SYSDATE,
	1
);

SELECT
    *
FROM
    department;

SELECT
    *
FROM
    employee;
    
---- Move EMPLOYEE-------

UPDATE employee
SET
	dept_no = 2
WHERE
	emp_no = 2;

SELECT
    *
FROM
    department;

SELECT
    *
FROM
    employee;

--- Delete EMPLOYEE ---

DELETE FROM employee
WHERE
	emp_no = 2;

SELECT
    *
FROM
    department;

SELECT
    *
FROM
    employee;
