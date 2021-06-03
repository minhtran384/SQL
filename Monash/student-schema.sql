DROP TABLE audit_trail CASCADE CONSTRAINTS;

DROP TABLE enrolment CASCADE CONSTRAINTS;

DROP TABLE student CASCADE CONSTRAINTS;

DROP TABLE unit CASCADE CONSTRAINTS;

CREATE TABLE audit_trail (
    audit_date_time   DATE,
    audit_user_name   VARCHAR2(30),
    stu_nbr           NUMBER(8),
    unit_code         CHAR(7)
);

COMMENT ON COLUMN audit_trail.audit_date_time IS
    'Date and time of action being audited';

COMMENT ON COLUMN audit_trail.audit_user_name IS
    'Login name of user who made change';

COMMENT ON COLUMN audit_trail.stu_nbr IS
    'Student Number';

COMMENT ON COLUMN audit_trail.unit_code IS
    'Unit code';

CREATE TABLE enrolment (
    stu_nbr          NUMBER(8) NOT NULL,
    unit_code        CHAR(7) NOT NULL,
    enrol_year       NUMBER(4) NOT NULL,
    enrol_semester   CHAR(1) NOT NULL,
    enrol_mark       NUMBER(3),
    enrol_grade      VARCHAR2(2)
);

ALTER TABLE enrolment
    ADD CONSTRAINT enrol_sem_value CHECK ( enrol_semester IN (
        '1',
        '2',
        '3'
    ) );

COMMENT ON COLUMN enrolment.stu_nbr IS
    'Student Number';

COMMENT ON COLUMN enrolment.unit_code IS
    'Unit Code ';

COMMENT ON COLUMN enrolment.enrol_year IS
    'Year of enrolment';

COMMENT ON COLUMN enrolment.enrol_semester IS
    'Semester of Enrolment';

COMMENT ON COLUMN enrolment.enrol_mark IS
    'Mark for this enrolment';

COMMENT ON COLUMN enrolment.enrol_grade IS
    'Grade for this enrolment';

ALTER TABLE enrolment
    ADD CONSTRAINT pk_enrolment PRIMARY KEY ( stu_nbr,
                                              unit_code,
                                              enrol_year,
                                              enrol_semester );

CREATE TABLE student (
    stu_nbr        NUMBER(8) NOT NULL,
    stu_lname      VARCHAR2(50) NOT NULL,
    stu_fname      VARCHAR2(50) NOT NULL,
    stu_dob        DATE NOT NULL,
    stu_ave_mark   NUMBER(5, 2)
);

ALTER TABLE student ADD CONSTRAINT ck_stu_nbr CHECK ( stu_nbr > 10000000 );

COMMENT ON COLUMN student.stu_nbr IS
    'Student Number';

COMMENT ON COLUMN student.stu_lname IS
    'Student Last (Family) Name';

COMMENT ON COLUMN student.stu_fname IS
    'Student First Name';

COMMENT ON COLUMN student.stu_dob IS
    'Student Data of Birth';

COMMENT ON COLUMN student.stu_ave_mark IS
    'Student Average Mark';

ALTER TABLE student ADD CONSTRAINT pk_student PRIMARY KEY ( stu_nbr );

CREATE TABLE unit (
    unit_code         CHAR(7) NOT NULL,
    unit_name         VARCHAR2(50) NOT NULL,
    unit_no_student   NUMBER(5) NOT NULL
);

COMMENT ON COLUMN unit.unit_code IS
    'Unit Code ';

COMMENT ON COLUMN unit.unit_name IS
    'Unit Name';

COMMENT ON COLUMN unit.unit_no_student IS
    'Total number of students who have enrolled in this unit';

ALTER TABLE unit ADD CONSTRAINT pk_subject PRIMARY KEY ( unit_code );

ALTER TABLE enrolment
    ADD CONSTRAINT student_enrolment FOREIGN KEY ( stu_nbr )
        REFERENCES student ( stu_nbr );

ALTER TABLE enrolment
    ADD CONSTRAINT unit_enrolment FOREIGN KEY ( unit_code )
        REFERENCES unit ( unit_code );
