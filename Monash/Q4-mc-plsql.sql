/* (i)*/
create or replace trigger maintain_comp_booking
after insert or delete or update of booking_status on booking 
begin 
    update guest g
    set completed_bookings = (select count(distinct b.booking_id) 
    from booking b where upper(b.booking_status) = 'C' and g.guest_no = b.guest_no 
    group by b.guest_no);
end;
/

--Test harness
--Prior state
select guest_no, guest_name, completed_bookings from guest where guest_no = 8;
--Test trigger for insert
insert into booking values (111,TO_DATE('01-Oct-2019','dd-Mon-yyyy'),TO_DATE('10-Oct-2019','dd-Mon-yyyy'),7,2,2400,8,1,1,'F');
--Post insert state
select guest_no, guest_name, completed_bookings from guest where guest_no = 8;
--Test trigger for update
update booking set booking_status = 'C' where booking_id = 111;
--Post update state
select guest_no, guest_name, completed_bookings from guest where guest_no = 8;
--Test trigger for delete
delete from booking where booking_id = 111;
--Post delete state
select guest_no, guest_name, completed_bookings from guest where guest_no = 8;
--Undo changes
rollback;


/* (ii)*/

create or replace trigger prevent_false_review
before insert on review
for each row
declare compl_bk number(3);
begin     
    select count(distinct booking_id) into compl_bk 
    from guest g left join booking b on b.guest_no = g.guest_no    
    where g.guest_no = :new.guest_no and resort_id = :new.resort_id
    and b.booking_status = 'C';
       
    if compl_bk = 0
        then raise_application_error(-20000, ' Guest must completed their stay at the resort first! ');
    end if;
end;
/

--Test harness
--Prior state
select * from review where guest_no = 4;
--Test trigger for insert (no booking)
select * from booking where guest_no = 4 and resort_id = 7;
insert into review values (77,'There is no bed in the room, this resort sucks!',sysdate,1,4,7);
--Post state
select * from review where guest_no = 4;
--Test trigger for insert (has not complete stay)
insert into booking values (111,sysdate-5,sysdate+5,3,2,2400,4,1,7,'P');
select * from booking where guest_no = 4 and resort_id = 7;
insert into review values (77,'There is no bed in the room, this resort sucks!',sysdate,1,4,7);
--Post state
select * from review where guest_no = 4 and resort_id = 7;
--Undo changes
rollback;

/* (iii)*/

create or replace trigger valid_booking_date 
before insert on booking 
for each row 
declare test_var number(2);

begin 
    select sum(case when :new.booking_from < booking_from  and :new.booking_to > booking_from then 1
                    when :new.booking_from not between b.booking_from and b.booking_to
                    and :new.booking_to   not between b.booking_from and b.booking_to
                    then 0 else 1 end)  
    into test_var from booking b 
    where b.resort_id = :new.resort_id 
    and b.cabin_no = :new.cabin_no
    and b.booking_status in ('C','F','P'); 
    
    if :new.booking_from > :new.booking_to 
        then raise_application_error(-20000, ' Booking to must be after booking from! ');
    elsif test_var > 0
        then raise_application_error(-20000, ' Booking overlapses with another! ');
    end if;    
end;
/

--Test harness --
--Prior state
select * from booking where resort_id = 1 and cabin_no = 1;
insert into booking values (102,to_date('25-05-2019','dd-mm-yyyy'),to_date('15-06-2019','dd-mm-yyyy'),3,2,2400,9,1,1,'D');
--Test trigger for insert
insert into booking values (101,to_date('05-04-2019','dd-mm-yyyy'),to_date('15-04-2019','dd-mm-yyyy'),3,2,2400,9,1,1,'F');
insert into booking values (101,to_date('25-03-2019','dd-mm-yyyy'),to_date('05-04-2019','dd-mm-yyyy'),3,2,2400,9,1,1,'F');
insert into booking values (101,to_date('25-03-2019','dd-mm-yyyy'),to_date('15-04-2019','dd-mm-yyyy'),3,2,2400,9,1,1,'F');
insert into booking values (101,to_date('28-05-2019','dd-mm-yyyy'),to_date('12-06-2019','dd-mm-yyyy'),3,2,2400,9,1,1,'F');
insert into booking values (101,'25-Apr-2019','15-Apr-2019',3,2,2400,9,1,1,'F');
--Post state
select * from booking where resort_id = 1 and booking_id = 1;
--Undo changes
rollback;

