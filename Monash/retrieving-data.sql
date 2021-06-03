SPOOL week8.txt

SET ECHO ON 

/* Part A: Retrieving data from a single table*/
/* 1. List all student and their details*/

SELECT
    *
FROM
    uni.student;

/* 2. List all unit and their details*/

SELECT
    *
FROM
    uni.unit;

/* 3. List all students who have surname 'Smith'*/

SELECT
    *
FROM
    uni.student
WHERE
    studlname = 'Smith';

/* 4. List the student's details for those students who have surname starts with the letter "S". 
In the display, rename the columns studfname and studlname to firstname and lastname.*/

SELECT
    studid,
    studfname
    || ' '
    || studlname AS studname,
    studdob,
    studaddress,
    studphone,
    studemail
FROM
    uni.student
WHERE
    studlname LIKE 'S%';
    
/* 5. List the student's surname, firstname and address for those students who have surname starts with the letter "S" and firstname contains the letter "i".*/

SELECT
    studlname,
    studfname,
    studaddress
FROM
    uni.student
WHERE
    studlname LIKE 'S%'
    AND studfname LIKE '%i%';
    
/* 6. */

SELECT
    unitcode,
    semester
FROM
    uni.offering
WHERE
    TO_CHAR(ofyear, 'yyyy') = 2014;

/* 7*/

SELECT
    unitcode
FROM
    uni.offering
WHERE
    TO_CHAR(ofyear, 'yyyy') = 2014
    AND semester = 1;

/* 8*/

SELECT
    *
FROM
    uni.unit
WHERE
    unitcode LIKE 'FIT1%';

/* 9*/

SELECT
    *
FROM
    uni.offering
WHERE
    ( semester = 1
      AND TO_CHAR(ofyear, 'yyyy') = 2014 )
    OR ( semester = 3
         AND TO_CHAR(ofyear, 'yyyy') = 2013 );
         
/* 10 */

SELECT
    studid,
    mark,
    unitcode,
    semester
FROM
    uni.enrolment
WHERE
    grade IS NOT NULL
    AND grade <> 'N'
    AND TO_CHAR(ofyear, 'yyyy') = 2013
    AND semester = 1;

/* Part B: Retrieving data from multiple tables*/

/* 1. List the name of all students who have marks in the range of 60 to 70.*/

SELECT
    s.studfname
    || ' '
    || s.studlname AS studname,
    e.mark
FROM
    uni.enrolment   e
    JOIN uni.student     s
    ON e.studid = s.studid
WHERE
    e.mark BETWEEN 60 AND 70;

/* 2. List all the unit codes, semester and name of the chief examiner for all the units that are offered in 2014.*/

SELECT
    o.unitcode,
    o.semester,
    s.stafffname
    || ' '
    || s.stafflname AS "chief examiner"
FROM
    uni.offering   o
    JOIN uni.staff      s
    ON s.staffid = o.chiefexam;

/* 3. List the name (firstname and surname), unit names, the year and semester of enrolment of all units taken so far.*/

SELECT
    studfname
    || ' '
    || studlname AS studname,
    unitname,
    TO_CHAR(ofyear, 'yyyy') year_offering,
    semester
FROM
    uni.enrolment   e
    JOIN uni.student     s
    ON s.studid = e.studid
    JOIN uni.unit        u
    ON u.unitcode = e.unitcode;
    
/* 4*/

SELECT
    u.unitcode,
    u.unitname,
    TO_CHAR(o.ofyear, 'yyyy') year,
    o.semester
FROM
    uni.unit       u
    JOIN uni.offering   o
    ON o.unitcode = u.unitcode;

/* 5.*/

SELECT
    u.unitcode,
    u.unitname,
    c.cltype,
    c.clday,
    c.cltime
FROM
    uni.unit         u
    JOIN uni.offering     o
    ON o.unitcode = u.unitcode
    JOIN uni.schedclass   c
    ON c.unitcode = u.unitcode
    JOIN uni.staff        s
    ON c.staffid = s.staffid
WHERE
    s.stafffname = 'Albus'
    AND s.stafflname = 'Dumbledore'
    AND TO_CHAR(o.ofyear, 'yyyy') = 2013
ORDER BY
    u.unitcode;

/* 6*/

SELECT
    u.unitcode,
    u.unitname,
    o.semester,
    TO_CHAR(o.ofyear, 'yyyy') year,
    o.mark,
    o.grade
FROM
    uni.enrolment   o
    JOIN uni.student     s
    ON s.studid = o.studid
    JOIN uni.unit        u
    ON u.unitcode = o.unitcode
WHERE
    s.studfname = 'Mary'
    AND s.studlname = 'Smith';
    
/* 7 */

SELECT
    u.unitcode,
    u.unitname,
    p.has_prereq_of,
    up.unitname
FROM
    uni.unit     u
    JOIN uni.prereq   p
    ON p.unitcode = u.unitcode
    JOIN uni.unit     up
    ON up.unitcode = p.has_prereq_of;

/* 8*/

SELECT
    u.unitname,
    p.has_prereq_of,
    up.unitname prereq
FROM
    uni.unit     u
    JOIN uni.prereq   p
    ON p.unitcode = u.unitcode
    JOIN uni.unit     up
    ON up.unitcode = p.has_prereq_of
WHERE
    u.unitname = 'Advanced Data Management';

/* 9*/

SELECT
    s.studid,
    s.studfname,
    s.studlname
FROM
    uni.enrolment   o
    JOIN uni.student     s
    ON s.studid = o.studid
WHERE
    o.grade = 'N'
    AND TO_CHAR(ofyear, 'yyyy') = 2013;
    
/* 10*/

SELECT
    s.studid,
    s.studfname,
    s.studlname,
    o.unitcode,
    o.semester,
    TO_CHAR(o.ofyear, 'yyyy') year
FROM
    uni.enrolment   o
    JOIN uni.student     s
    ON s.studid = o.studid
WHERE
    o.mark IS NULL;
    

SET ECHO OFF

SPOOL OFF