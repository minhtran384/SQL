SET ECHO ON

SPOOL week12.txttxt

--(i)

SELECT
    TO_CHAR(ofyear, 'yyyy') year,
    semester,
    st.staffid,
    stafffname,
    stafflname,
    COUNT(classno) numberclass,
    CASE
        WHEN COUNT(classno) > 2 THEN
            'Overload'
        WHEN COUNT(classno) = 2 THEN
            'Correct Load'
        ELSE
            'Underload'
    END AS load
FROM
    uni.staff        st
    JOIN uni.schedclass   sc
    ON st.staffid = sc.staffid
GROUP BY
    ofyear,
    semester,
    st.staffid,
    stafffname,
    stafflname
ORDER BY
    st.staffid;
    
;

--(ii)

select u.unitcode, count(distinct p.has_prereq_of) no_of_prereq
from uni.unit u
left join uni.prereq p on p.unitcode = u.unitcode
group by u.unitcode
order by u.unitcode;

--(iii)

-- OUTER JOIN
select u.unitcode, u.unitname
from uni.unit u
left join uni.prereq p on p.unitcode = u.unitcode 
where p.unitcode is null
order by u.unitcode;

-- SUBQUERY
select u.unitcode, u.unitname from uni.unit u
where unitcode NOT
in

( SELECT DISTINCT
    unitcode
FROM
    uni.prereq
);

/*MINUS - SET OPERATOR*/

SELECT
    unitcode,
    unitname
FROM
    uni.unit
MINUS
SELECT
    u.unitcode,
    unitname
FROM
    uni.unit     u
    JOIN uni.prereq   p
    ON u.unitcode = p.unitcode;

/*(iv)*/

SELECT
    o.unitcode,
    TO_CHAR(o.ofyear, 'yyyy') year,
    o.semester,
    nvl(round(AVG(e.mark), 2), 0) average
FROM
    uni.offering    o
    LEFT JOIN uni.enrolment   e
    ON e.unitcode = o.unitcode
       AND o.semester = e.semester
           AND TO_CHAR(o.ofyear, 'yyyy') = TO_CHAR(e.ofyear, 'yyyy')
GROUP BY
    o.unitcode,
    o.semester,
    TO_CHAR(o.ofyear, 'yyyy')
ORDER BY
    nvl(AVG(e.mark), 0);

