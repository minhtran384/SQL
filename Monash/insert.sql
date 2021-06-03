set echo on;

insert into student values (11111111,'Bloggs','Fred',to_date('01-Jan-1996','dd-Mon-yyyy'),NULL);
insert into student values (11111112,'Nice','Nick',to_date('10-Oct-2000','dd-Mon-yyyy'),NULL);
insert into student values (11111113,'Wheat','Wendy',to_date('05-May-1996','dd-Mon-yyyy'),NULL);
insert into student values (11111114,'Sheen','Cindy',to_date('25-Dec-2002','dd-Mon-yyyy'),NULL);
   
insert into unit values ('FIT1001','Computer Systems',0);
insert into unit values ('FIT1002','Computer Programming',0);
insert into unit values ('FIT1004','Database',0); 


insert into enrolment values (11111111,'FIT1001',2018,'1',78,'D');
insert into enrolment values (11111111,'FIT1002',2019,'1',null,null);
insert into enrolment values (11111111,'FIT1004',2018,'1',null,null);
insert into enrolment values (11111112,'FIT1001',2018,'1',35,'N');
insert into enrolment values (11111112,'FIT1001',2019,'1',null,null);
insert into enrolment values (11111113,'FIT1001',2018,'2',65,'C');
insert into enrolment values (11111113,'FIT1004',2019,'1',null,null);
insert into enrolment values (11111114,'FIT1004',2019,'1',null,null); 

update student set stu_ave_mark = (select avg(enrol_mark) from enrolment group by stu_nbr having stu_nbr=11111111) where stu_nbr = 11111111 ;
update student set stu_ave_mark = (select avg(enrol_mark) from enrolment group by stu_nbr having stu_nbr=11111112) where stu_nbr = 11111112 ;
update student set stu_ave_mark = (select avg(enrol_mark) from enrolment group by stu_nbr having stu_nbr=11111113) where stu_nbr = 11111113 ;
update student set stu_ave_mark = (select avg(enrol_mark) from enrolment group by stu_nbr having stu_nbr=11111114) where stu_nbr = 11111114 ;

-- total number of students is counted across multiple offerings

update unit set unit_no_student = (select count(stu_nbr) from enrolment group by unit_code having unit_code='FIT1001') where unit_code='FIT1001';
update unit set unit_no_student = (select count(stu_nbr) from enrolment group by unit_code having unit_code='FIT1002') where unit_code='FIT1002';
update unit set unit_no_student = (select count(stu_nbr) from enrolment group by unit_code having unit_code='FIT1004') where unit_code='FIT1004';

commit;

select * from unit;
select * from student;

set echo off;
