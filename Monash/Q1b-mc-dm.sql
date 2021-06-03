/* (i)*/

DROP SEQUENCE resort_seq;

CREATE SEQUENCE resort_seq START WITH 100 INCREMENT BY 1;

/* (ii)*/

INSERT INTO resort VALUES (
    resort_seq.NEXTVAL,
    'Awesome Resort',
    '50 Awesome Road',
    '4830',
    NULL,
    'N',
    (
        SELECT
            town_id
        FROM
            town
        WHERE
            town_lat = - 20.7256
            AND town_long = 139.4927
    ),
    (
        SELECT
            manager_id
        FROM
            manager
        WHERE
            manager_name = 'Garrott Gooch'
            AND manager_phone = '6002318099'
    )
);

COMMIT;

INSERT INTO cabin VALUES (
    '1',
    resort_seq.CURRVAL,
    3,
    6,
    'Free wi-fi, kitchen with 400 ltr 
refrigerator, stove, microwave, pots, pans, silverware, toaster, eletric kettle, 
TV and utensils'
);

INSERT INTO cabin VALUES (
    '2',
    resort_seq.CURRVAL,
    2,
    4,
    'Free wi-fi, kitchen with 289 ltr 
refrigerator, stove, pots, pans, silverware, toaster, electric kettle, TV and
utensils'
);

COMMIT;

/* (iii)*/

UPDATE resort
SET
    manager_id = (
        SELECT
            manager_id
        FROM
            manager
        WHERE
            manager_name = 'Fonsie Tillard'
            AND manager_phone = '9636535741'
    )
WHERE
    resort_name = 'Awesome Resort'
    AND town_id = (
        SELECT
            town_id
        FROM
            town
        WHERE
            town_lat = - 20.7256
            AND town_long = 139.4927
    );
      
/* (iv)*/

DELETE FROM cabin
WHERE
    resort_id = (
        SELECT
            resort_id
        FROM
            resort
        WHERE
            resort_name = 'Awesome Resort'
            AND town_id = (
                SELECT
                    town_id
                FROM
                    town
                WHERE
                    town_lat = - 20.7256
                    AND town_long = 139.4927
            )
    );

DELETE FROM resort
WHERE
    resort_name = 'Awesome Resort'
    AND town_id = ( SELECT
    town_id
FROM
    town
WHERE
    town_lat = - 20.7256
    AND town_long = 139.4927);
    
COMMIT;



