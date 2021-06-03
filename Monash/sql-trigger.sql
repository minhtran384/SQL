create or replace trigger owner_upd_cas before
    update of owner_no ON owner
    for each row   
    begin 
        update vehicle 
        set onwer_no = :NEW.owner_no
        where owener_no = :OLD.owner_no
        DBMS_OUTPUT.PUT_LINE ('Corresponding owner number in VEHICLE table ' 
        || 'hass also been updated'); 
    end;
/    
    
-- test
select * from owner;
select * from vehicle;

update onwer
set owner_no = 2
where owner_no = 1;

select * from owner;
select * from vehicle;

rollback
-- end of harness test