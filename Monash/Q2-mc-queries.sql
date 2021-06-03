/* (i)*/
SELECT
    resort_name,
    resort_street_address
    || ' '
    || town_name
    || ' '
    || resort_pcode AS "RESORT ADDRESS",
    m.manager_name,
    m.manager_phone
FROM
    resort    r
    JOIN manager   m
    ON m.manager_id = r.manager_id
    JOIN town      t
    ON t.town_id = r.town_id
WHERE
    resort_livein_manager = 'Y'
    AND resort_star_rating IS NULL
ORDER BY
    r.resort_pcode DESC,
    r.resort_name;

/* (ii)*/

SELECT
    r.resort_id,
    r.resort_name,
    r.resort_street_address,
    t.town_name,
    t.town_state,
    r.resort_pcode,
    TO_CHAR(SUM(b.booking_charge), '$99990.99') AS total_booking_charges
FROM
    booking   b
    JOIN resort    r
    ON r.resort_id = b.resort_id
    JOIN town      t
    ON t.town_id = r.town_id
GROUP BY
    r.resort_id,
    r.resort_name,
    r.resort_street_address,
    t.town_name,
    t.town_state,
    r.resort_pcode
HAVING
    SUM(b.booking_charge) > (
        SELECT
            AVG(total_charge)
        FROM
            (
                SELECT
                    resort_id,
                    SUM(booking_charge) total_charge
                FROM
                    booking
                GROUP BY
                    resort_id
            )
    )
ORDER BY
    r.resort_id;

/* (iii)*/

SELECT
    r.review_id,
    r.guest_no,
    g.guest_name,
    r.resort_id,
    re.resort_name,
    r.review_comment,
    r.review_date date_reviewed
FROM
    review   r
    JOIN guest    g
    ON g.guest_no = r.guest_no
    JOIN resort   re
    ON re.resort_id = r.resort_id
    LEFT JOIN (
        SELECT
            b.guest_no,
            b.resort_id,
            MIN(b.booking_to) first_booking
        FROM
            booking b
        GROUP BY
            b.guest_no,
            b.resort_id
    ) b
    ON b.guest_no = r.guest_no
       AND b.resort_id = r.resort_id
WHERE
    r.review_date < b.first_booking
    OR b.first_booking IS NULL
ORDER BY
    r.review_date;


/* (iv)*/

SELECT
    a.resort_id,
    a.resort_name,
    'Has '
    || a.no_cabin
    || ' cabins in total with '
    || a.no_cabin_2br
    || ' having more than 2 bedrooms' AS accomodation_available
FROM
    (
        SELECT
            r.resort_id,
            r.resort_name,
            COUNT(DISTINCT c.cabin_no) no_cabin,
            COUNT(DISTINCT
                CASE
                    WHEN c.cabin_bedrooms > 2 THEN
                        c.cabin_no
                    ELSE
                        NULL
                END
            ) no_cabin_2br
        FROM
            resort   r
            JOIN cabin    c
            ON c.resort_id = r.resort_id
        GROUP BY
            r.resort_id,
            r.resort_name
    ) a
WHERE
    a.no_cabin_2br > 0
ORDER BY
    resort_name;

/* (v)*/

SELECT
    b.resort_id,
    r.resort_name,
    CASE
        WHEN r.resort_livein_manager = 'Y' THEN
            'Yes'
        WHEN r.resort_livein_manager = 'N' THEN
            'No'
    END AS live_in_manager,
    CASE
        WHEN r.resort_star_rating IS NULL THEN
            'No Ratings'
        ELSE
            TO_CHAR(r.resort_star_rating, '0.0')
    END AS star_rating,
    m.manager_name,
    m.manager_phone,
    COUNT(DISTINCT b.booking_id) AS number_of_bookings
FROM
    booking   b
    JOIN resort    r
    ON r.resort_id = b.resort_id
    JOIN manager   m
    ON m.manager_id = r.manager_id
GROUP BY
    b.resort_id,
    r.resort_name,
    CASE
            WHEN r.resort_livein_manager = 'Y' THEN
                'Yes'
            WHEN r.resort_livein_manager = 'N' THEN
                'No'
        END,
    CASE
            WHEN r.resort_star_rating IS NULL THEN
                'No Ratings'
            ELSE
                TO_CHAR(r.resort_star_rating, '0.0')
        END,
    m.manager_name,
    m.manager_phone
HAVING
    COUNT(DISTINCT b.booking_id) = (
        SELECT
            MAX(COUNT(b.booking_id))
        FROM
            booking b
        GROUP BY
            b.resort_id
    )
ORDER BY
    b.resort_id;
    


/* (vi)*/

SELECT
    r.resort_id,
    r.resort_name,
    b.poi_name,
    b.poi_street_address,
    b.poi_town,
    b.poi_state,
    CASE
        WHEN b.poi_opening_time IS NULL THEN
            'Not Applicable'
        ELSE
            b.poi_opening_time
    END poi_opening_time,
    round(geodistance(b.town_lat, b.town_long, t.town_lat, t.town_long), 1) separation_in_kms
FROM
    resort   r
    JOIN town     t
    ON t.town_id = r.town_id
    JOIN (
        SELECT
            p.poi_name,
            p.poi_street_address,
            t.town_name    poi_town,
            t.town_state   poi_state,
            TO_CHAR(p.poi_open_time, 'HH:MM AM') poi_opening_time,
            t.town_lat,
            t.town_long
        FROM
            point_of_interest   p
            LEFT JOIN town                t
            ON t.town_id = p.town_id
    ) b
    ON geodistance(b.town_lat, b.town_long, t.town_lat, t.town_long) <= 100
ORDER BY
    r.resort_name,
    separation_in_kms;