SPOOL tables_from_scratch1_run1.txt

SET ECHO ON

/* Creating tables*/

DROP TABLE enrolment PURGE;

DROP TABLE student PURGE;

DROP TABLE unit PURGE;

CREATE TABLE unit (
    unit_code   CHAR(7) NOT NULL,
    unit_name   VARCHAR(50) NOT NULL
        CONSTRAINT uq_unit_name UNIQUE,
    CONSTRAINT pk_unit PRIMARY KEY ( unit_code )
);

CREATE TABLE student (
    stu_nbr     NUMBER(8) NOT NULL,
    stu_name    VARCHAR2(50) NOT NULL,
    stu_fname   VARCHAR2(50) NOT NULL,
    stu_dob     DATE NOT NULL,
    CONSTRAINT pk_student PRIMARY KEY ( stu_nbr ),
    CONSTRAINT ck_stu_nbr CHECK ( stu_nbr > 1000000 )
);

CREATE TABLE enrolment (
    stu_nbr          NUMBER(8) NOT NULL,
    unit_code        CHAR(7) NOT NULL,
    enrol_year       NUMBER(4) NOT NULL,
    enrol_semester   CHAR(4) NOT NULL,
    enrol_mark       NUMBER(3),
    enrol_grade      CHAR(2),
    CONSTRAINT pk_enrolment PRIMARY KEY ( stu_nbr,
                                          unit_code,
                                          enrol_year,
                                          enrol_semester ),
    CONSTRAINT enrol_sem_value CHECK ( enrol_semester IN (
        '1',
        '2',
        '3'
    ) ),
    CONSTRAINT fk_enrolment_student FOREIGN KEY ( stu_nbr )
        REFERENCES student ( stu_nbr ),
    CONSTRAINT fk_enrolment_unit FOREIGN KEY ( unit_code )
        REFERENCES unit ( unit_code )
);

SET ECHO OFF

SPOOL OFF