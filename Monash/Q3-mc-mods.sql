
/* (i)*/
ALTER TABLE booking ADD booking_status CHAR(1);

COMMENT ON COLUMN booking.booking_status IS
    'Booking status';

ALTER TABLE booking
    ADD CONSTRAINT chk_bk_st CHECK ( booking_status IN (
        'C',
        'D',
        'F',
        'P'
    ) );

ALTER TABLE booking MODIFY
    booking_status DEFAULT 'F';

UPDATE booking
SET
    booking_status =
        CASE
            WHEN booking_to < SYSDATE                      THEN
                'C'
            WHEN booking_from > SYSDATE                    THEN
                'F'
            WHEN SYSDATE BETWEEN booking_from AND booking_to THEN
                'P'
        END;

COMMIT;

/* (ii)*/

ALTER TABLE guest ADD completed_bookings NUMBER(3);

COMMENT ON COLUMN guest.completed_bookings IS
    'Number of completed booking for a guest';

UPDATE guest g
SET
    completed_bookings = (
        SELECT
            COUNT(DISTINCT b.booking_id)
        FROM
            booking b
        WHERE
            b.booking_status = 'C'
            AND g.guest_no = b.guest_no
        GROUP BY
            b.guest_no
    );

COMMIT;

/* (iii)*/

/* Create table manager role */

DROP TABLE manager_assignment PURGE;

DROP TABLE manager_role PURGE;

CREATE TABLE manager_role (
    role_code   CHAR(2) NOT NULL,
    role_name   VARCHAR(30) NOT NULL,
    CONSTRAINT mng_role_pk PRIMARY KEY ( role_code ),
    CONSTRAINT role_unq UNIQUE ( role_name )
);

COMMENT ON COLUMN manager_role.role_code IS
    'Manager role code';

COMMENT ON COLUMN manager_role.role_name IS
    'Manager role name';

/* Add data into manager role table*/

INSERT INTO manager_role VALUES (
    'BM',
    'Booking Manager'
);

INSERT INTO manager_role VALUES (
    'CM',
    'Cleaning Manager'
);

INSERT INTO manager_role VALUES (
    'MM',
    'Maintainance Manager'
);

COMMIT;

/* Create composite table manager assignment*/

CREATE TABLE manager_assignment
    AS
        SELECT
            resort_id,
            manager_id,
            CAST(NULL AS CHAR(2)) role_code,
            resort_livein_manager
        FROM
            resort;

ALTER TABLE manager_assignment ADD CONSTRAINT assignment_pk PRIMARY KEY ( resort_id,manager_id);

ALTER TABLE manager_assignment MODIFY
    resort_livein_manager DEFAULT 'N';

ALTER TABLE manager_assignment
    ADD CONSTRAINT resort_assignment FOREIGN KEY ( resort_id )
        REFERENCES resort ( resort_id )
            ON DELETE CASCADE;

ALTER TABLE manager_assignment
    ADD CONSTRAINT man_assignment FOREIGN KEY ( manager_id )
        REFERENCES manager ( manager_id )
            ON DELETE CASCADE;

ALTER TABLE manager_assignment
    ADD CONSTRAINT man_role FOREIGN KEY ( role_code )
        REFERENCES manager_role ( role_code )
            ON DELETE CASCADE;

COMMENT ON COLUMN manager_assignment.resort_id IS
    'Resort ID';

COMMENT ON COLUMN manager_assignment.manager_id IS
    'Manager ID';

COMMENT ON COLUMN manager_assignment.role_code IS
    'Manager role code';

COMMENT ON COLUMN manager_assignment.resort_livein_manager IS
    'Does manager live in resort';

/* Add data into table manager_assignment*/

UPDATE manager_assignment
SET
    role_code =
        CASE
            WHEN resort_id = (
                SELECT
                    resort_id
                FROM
                    resort   r
                    LEFT JOIN town     t
                    ON t.town_id = r.town_id
                WHERE
                    r.resort_name = 'Byron Bay Exclusive Resort'
                    AND t.town_lat = - 28.6474
                    AND t.town_long = 153.6020
            ) THEN
                'BM'
            ELSE
                NULL
        END;

INSERT INTO manager_assignment columns (
    resort_id,
    manager_id,
    role_code
) VALUES (
    (
        SELECT
            resort_id
        FROM
            resort   r
            LEFT JOIN town     t
            ON t.town_id = r.town_id
        WHERE
            r.resort_name = 'Byron Bay Exclusive Resort'
            AND t.town_lat = - 28.6474
            AND t.town_long = 153.6020
    ),
    (
        SELECT
            manager_id
        FROM
            manager
        WHERE
            manager_name = 'Garrott Gooch'
            AND manager_phone = 6002318099
    ),
    'CM'
);

INSERT INTO manager_assignment columns (
    resort_id,
    manager_id,
    role_code
) VALUES (
    (
        SELECT
            resort_id
        FROM
            resort   r
            LEFT JOIN town     t
            ON t.town_id = r.town_id
        WHERE
            r.resort_name = 'Byron Bay Exclusive Resort'
            AND t.town_lat = - 28.6474
            AND t.town_long = 153.6020
    ),
    (
        SELECT
            manager_id
        FROM
            manager
        WHERE
            manager_name = 'Fonsie Tillard'
            AND manager_phone = 9636535741
    ),
    'MM'
);

COMMIT;

/* Drop manager related columns in table resort*/

ALTER TABLE resort DROP ( manager_id,resort_livein_manager );

/*
test new tables
select r.resort_id, r.resort_name, m.manager_name, mr.role_name, a.resort_livein_manager 
from resort r
join manager_assignment a on a.resort_id = r.resort_id
join manager m on m.manager_id = a.manager_id
left join manager_role mr on mr.role_code = a.role_code;
*/
