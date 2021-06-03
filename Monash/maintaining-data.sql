SET ECHO ON

SPOOL delete_output.txt

/* Question 1*/

SELECT
    *
FROM
    enrolment;

DELETE enrolment
WHERE
    stu_nbr = 11111114;

/* Question 2 (delete for restrict)*/

SELECT
    *
FROM
    student;

SELECT
    *
FROM
    enrolment;

DELETE enrolment
WHERE
    stu_nbr = 11111113;

DELETE student
WHERE
    stu_nbr = 11111113;

COMMIT;

/* Question 3 */

ALTER TABLE enrolment DROP CONSTRAINT fk_enrolment_student;

ALTER TABLE enrolment
    ADD CONSTRAINT fk_enrolment_student FOREIGN KEY ( stu_nbr )
        REFERENCES student ( stu_nbr )
            ON DELETE CASCADE;

SELECT
    *
FROM
    student;

SELECT
    *
FROM
    enrolment;

DELETE student
WHERE
    stu_nbr = 11111113;

COMMIT;

/* update */
/*1*/

SELECT
    *
FROM
    unit;

UPDATE unit
SET
    unit_name = 'place holder unit'
WHERE
    unit_code = 'FIT9999';

COMMIT;

/*2*/

SELECT
    *
FROM
    enrolment;

UPDATE enrolment
SET
    enrol_mark = 75,
    enrol_grade = 'D'
WHERE
    stu_nbr = 11111113
    AND unit_code = 'FIT5132'
    AND enrol_year = 2014
    AND enrol_semester = 2;

COMMIT;
/*3*/

SELECT
    stu_nbr,
    unit_code,
    enrol_year,
    enrol_semester,
    enrol_mark,
    CASE
        WHEN enrol_mark BETWEEN 45 AND 54 THEN
            'P1'
        WHEN enrol_mark BETWEEN 55 AND 64 THEN
            'P2'
        WHEN enrol_mark BETWEEN 65 AND 74 THEN
            'C'
        WHEN enrol_mark BETWEEN 75 AND 84 THEN
            'D'
        WHEN enrol_mark BETWEEN 85 AND 100 THEN
            'HD'
    END enrol_new_grade
FROM
    enrolment;

UPDATE enrolment
SET
    enrol_grade = (
        CASE
            WHEN enrol_mark BETWEEN 45 AND 54 THEN
                'P1'
            WHEN enrol_mark BETWEEN 55 AND 64 THEN
                'P2'
            WHEN enrol_mark BETWEEN 65 AND 74 THEN
                'C'
            WHEN enrol_mark BETWEEN 75 AND 84 THEN
                'D'
            WHEN enrol_mark BETWEEN 85 AND 100 THEN
                'HD'
        END
    )
WHERE
    enrol_mark >= 45;
commit;


SET ECHO OFF