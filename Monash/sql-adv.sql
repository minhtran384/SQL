/* 1. Find the number of schedules classes assigned to each staff member in each 
      year and semester. If the number of classes is 2 then this should be labelled 
      as a correct load, more than 2 as an overload and less than 2 as an underload */
SELECT
    to_char(ofyear, 'yyyy') AS year,
    semester,
    s.staffid,
    stafffname,
    stafflname,
    COUNT(*) AS numberclasses,
    CASE
        WHEN COUNT(*) > 2 THEN
            'Overload'
        WHEN COUNT(*) = 2 THEN
            'Correct load'
        ELSE
            'Underload'
    END AS load
FROM
    uni.schedclass   c
    JOIN uni.staff        s ON s.staffid = c.staffid
GROUP BY
    ofyear,
    semester,
    s.staffid,
    stafffname,
    stafflname
ORDER BY
    ofyear,
    semester,
    s.staffid;

/* 2. Find the total number of prerequisite units for each unit. Include in 
      the list the unitcode of units that do not have prerequisite.   
      Hint: use an outer join.*/

SELECT
    u.unitcode,
    COUNT(has_prereq_of) AS no_of_prereq
FROM
    uni.unit     u
    LEFT OUTER JOIN uni.prereq   p ON u.unitcode = p.unitcode
GROUP BY
    u.unitcode
ORDER BY
    unitcode;

/* 3. Display unitcode and unitname for units that do not have prerequisite. */

/* Using outer join */

SELECT
    u.unitcode,
    u.unitname
FROM
    uni.unit     u
    LEFT OUTER JOIN uni.prereq   p ON u.unitcode = p.unitcode
GROUP BY
    u.unitcode,
    unitname
HAVING
    COUNT(has_prereq_of) = 0
ORDER BY
    unitcode;

/* Using set operator MINUS */

SELECT
    u.unitcode,
    unitname
FROM
    uni.unit u
MINUS
SELECT
    u.unitcode,
    unitname
FROM
    uni.unit     u
    JOIN uni.prereq   p ON u.unitcode = p.unitcode
ORDER BY
    unitcode;

/* Using subquery */

SELECT
    unitcode,
    unitname
FROM
    uni.unit
WHERE
    unitcode NOT IN (
        SELECT
            unitcode
        FROM
            uni.prereq
    )
ORDER BY
    unitcode;

/* 4. List the unit code and the average mark for each offering. 
      Round the average to the nearest 2 decimal. If the average result is 
      null, display the average as 0. */

SELECT
    unitcode,
    to_char(ofyear, 'YYYY') AS year,
    semester,
    to_char(nvl(round(AVG(mark), 2), 0), '990.99') AS average
FROM
    uni.enrolment
GROUP BY
    unitcode,
    ofyear,
    semester
ORDER BY
    average;

-- Or taking the statement "for each offering" to include even offerings without
-- any enrolments (note added column CountEnrolled to show number enrolled)

SELECT
    unitcode,
    to_char(ofyear, 'YYYY') AS year,
    semester,
    to_char(nvl(round(AVG(mark), 2), 0), '990.99') AS average,
    count(studid) as CountEnrolled
FROM
    uni.offering
    LEFT outer JOIN uni.enrolment using (ofyear, semester, unitcode)
GROUP BY
    unitcode,
    ofyear,
    semester
ORDER BY
    average;
    