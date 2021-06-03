-- Q1. Update cascade on unit_code in unit with msg re changes via dbms_output

create or replace trigger unit_upd_cascade 
after update of unit_code on unit 
for each row 
begin
  update ENROLMENT
     set UNIT_CODE = :new.UNIT_CODE
     where UNIT_CODE = :old.UNIT_CODE;
     
  dbms_output.put_line ('Related unit codes in ENROLMENT have been updated');
end;
/

-- Test Harness
set serveroutput on
set echo on
-- Prior state
select * from unit;
select * from enrolment;

-- Test trigger 

update unit set unit_code = 'FIT9999' where unit_code = 'FIT5057';

-- Post state
select * from unit;
select * from enrolment;

-- Undo changes
rollback;
set echo off;

-- Q2. Unit Count Maintenance

-- Maintain unit count when an enrolment is added or deleted. Delete also triggers an
-- audit log insert. Note here we have chose not to show DBMS_OUTPUT

create or replace trigger change_enrolment 
after insert or delete on enrolment 
for each row 

begin
  if inserting then
    update unit
       set unit_current_stu_count = unit_current_stu_count + 1
       where unit_code = :new.unit_code;
  end if;
  
  if deleting then
    update unit
       set unit_current_stu_count = unit_current_stu_count - 1
       where unit_code = :old.unit_code; 
  
    insert into audit_log values (audit_seq.nextval, sysdate, user, 
                     :old.stu_no, :old.unit_code);
  
  end if;
  
end;
/

-- Test Harness
set echo on
-- Prior state
-- Test student but could use one of the current rows
insert into STUDENT 
      values ('99999999','Test','Test',to_date('01-JAN-90','DD-MON-RR'),null);
select * from unit where unit_code='FIT9132';

-- Test trigger
insert into ENROLMENT values ('99999999','FIT9132',2,2015,null,null);

-- post state
select * from unit where unit_code='FIT9132';
-- Test trigger
delete from ENROLMENT where stu_no= '99999999' 
      and unit_code = 'FIT9132'and enrol_semester = 2 and enrol_year = 2015;

-- post state
select * from unit where unit_code='FIT9132';
select * from audit_log;

-- although not stricly required, closes transaction
rollback;
set echo off

-- NOTE the value of the audit_no does not rollback, sequences once called via
--      nextval must advance to the next available value, no rollback is possible

-- For the interest of students who might wonder ......
-- A row-level trigger can’t read or write the table it’s fired from, a statement-level 
-- trigger can so one way of managing maintenance of the student average would be a 
-- statement level trigger although highly inefficient. Other approaches are possible
-- but beyond our current level of study

create or replace 
trigger maintain_student_average 
after update of enrol_mark on enrolment 

begin
  
  update STUDENT
    set STU_AVG_MARK = 
        (select AVG(ENROL_MARK) from ENROLMENT where STU_NO = student.STU_NO);
    
end;
/

-- Test Harness
set echo on
-- Test trigger
insert into STUDENT 
      values ('99999999','Test','Test',to_date('01-JAN-90','DD-MON-RR'),null);
insert into ENROLMENT values ('99999999','FIT5057',2,2015,null,null);
insert into ENROLMENT values ('99999999','FIT9132',2,2015,null,null);

update ENROLMENT set enrol_mark = 60, enrol_grade = 'C'
    where stu_no= '99999999' and unit_code = 'FIT5057'
      and enrol_semester = 2 and enrol_year = 2015;
       
update ENROLMENT set enrol_mark = 80, enrol_grade = 'HD'
      where stu_no= '99999999' and unit_code = 'FIT9132'
       and enrol_semester = 2 and enrol_year = 2015;

-- Post state
select * from student where stu_no= '99999999';

rollback;
set echo off


-- Q3. Calculate_grade trigger

create or replace 
trigger calculate_grade
BEFORE INSERT OR UPDATE OF enrol_mark ON enrolment
FOR EACH ROW
declare
	final_grade enrolment.enrol_grade%type;

BEGIN
  IF :new.enrol_mark >= 80 THEN
	  final_grade := 'HD';
  ELSIF
    :new.enrol_mark >= 70 AND :new.enrol_mark < 80 THEN
	  final_grade := 'D';
  ELSIF
    :new.enrol_mark >= 60 AND :new.enrol_mark < 70 THEN
	  final_grade := 'C';
  ELSIF
    :new.enrol_mark >= 50 AND :new.enrol_mark < 60 THEN
	  final_grade := 'P';
  ELSIF
    :new.enrol_mark < 50 THEN
	  final_grade := 'N';
  END IF;
  -- Note here we are changing the :new value not directly writing to the table
  -- via say an update which would cause a mutating table error
  :new.enrol_grade := final_grade;
  
end;
/

-- Test Harness
set echo on

insert into STUDENT 
      values ('99999999','Test','Test',to_date('01-JAN-90','DD-MON-RR'),null);
insert into ENROLMENT values ('99999999','FIT9132',2,2015,null,null);

-- Test Trigger
-- Test Update
update ENROLMENT set enrol_mark = 80
      where stu_no= '99999999' and unit_code = 'FIT9132'
       and enrol_semester = 2 and enrol_year = 2015;
select * from enrolment where stu_no= '99999999';

update ENROLMENT set enrol_mark = 70
      where stu_no= '99999999' and unit_code = 'FIT9132'
       and enrol_semester = 2 and enrol_year = 2015;
select * from enrolment where stu_no= '99999999';

update ENROLMENT set enrol_mark = 60
      where stu_no= '99999999' and unit_code = 'FIT9132'
       and enrol_semester = 2 and enrol_year = 2015;
select * from enrolment where stu_no= '99999999';

update ENROLMENT set enrol_mark = 50
      where stu_no= '99999999' and unit_code = 'FIT9132'
       and enrol_semester = 2 and enrol_year = 2015;
select * from enrolment where stu_no= '99999999';

update ENROLMENT set enrol_mark = 40
      where stu_no= '99999999' and unit_code = 'FIT9132'
       and enrol_semester = 2 and enrol_year = 2015;
select * from enrolment where stu_no= '99999999';
rollback;

-- Test Insert
insert into STUDENT 
      values ('99999999','Test','Test',to_date('01-JAN-90','DD-MON-RR'),null);
insert into ENROLMENT (stu_no, unit_code, enrol_semester, enrol_year, enrol_mark ) 
    values ('99999999','FIT9132',2,2015,67);
select * from enrolment where stu_no= '99999999';
rollback;

set echo off

-- Q4 Stop insert if unit code does not state with FIT as a demonstration
--    of raising an error

CREATE OR REPLACE TRIGGER check_unit_code BEFORE
    INSERT ON unit
    FOR EACH ROW
BEGIN
    IF :new.unit_code NOT LIKE 'FIT%' THEN
        raise_application_error(-20000, 'Unit code must begin with FIT');
    END IF;
END;
/

-- Test Harness
-- Test Trigger
insert into unit values ('ABC0001','Test Insert',6);

-- although not stricly required, closes transaction
rollback;

-- Alternative and better DBMS enforcement
ALTER TABLE unit 
    ADD CONSTRAINT chk_unit_code CHECK ( unit_code LIKE 'FIT%' );
    
