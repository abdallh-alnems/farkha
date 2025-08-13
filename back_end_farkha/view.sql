SELECT
    -- النوع 1
    (SELECT higher_general_prices 
     FROM general_prices 
     WHERE general_prices_type = 1 
     ORDER BY general_prices_date DESC 
     LIMIT 0,1) AS farkh_abid_higher_today,

    (SELECT lower_general_prices 
     FROM general_prices 
     WHERE general_prices_type = 1 
     ORDER BY general_prices_date DESC 
     LIMIT 0,1) AS farkh_abid_lower_today,

    (SELECT higher_general_prices 
     FROM general_prices 
     WHERE general_prices_type = 1 
     ORDER BY general_prices_date DESC 
     LIMIT 1,1) AS farkh_abid_higher_yesterday,

    (SELECT lower_general_prices 
     FROM general_prices 
     WHERE general_prices_type = 1 
     ORDER BY general_prices_date DESC 
     LIMIT 1,1) AS farkh_abid_lower_yesterday,

    -- النوع 7
    (SELECT higher_general_prices 
     FROM general_prices 
     WHERE general_prices_type = 7 
     ORDER BY general_prices_date DESC 
     LIMIT 0,1) AS frakh_abdi_haya_higher_today,

    (SELECT lower_general_prices 
     FROM general_prices 
     WHERE general_prices_type = 7 
     ORDER BY general_prices_date DESC 
     LIMIT 0,1) AS frakh_abdi_haya_lower_today,

    (SELECT higher_general_prices 
     FROM general_prices 
     WHERE general_prices_type = 7 
     ORDER BY general_prices_date DESC 
     LIMIT 1,1) AS frakh_abdi_haya_higher_yesterday,

    (SELECT lower_general_prices 
     FROM general_prices 
     WHERE general_prices_type = 7 
     ORDER BY general_prices_date DESC 
     LIMIT 1,1) AS frakh_abdi_haya_lower_yesterday;









SELECT
    today.higher_general_prices  AS higher_today,
    today.lower_general_prices   AS lower_today,
    yesterday.higher_general_prices AS higher_yesterday,
    yesterday.lower_general_prices  AS lower_yesterday,
    t.type_name
FROM
    (
        SELECT gp.*
        FROM general_prices gp
        WHERE gp.general_prices_date = (
            SELECT MAX(gp2.general_prices_date)
            FROM general_prices gp2
            WHERE gp2.general_prices_type = gp.general_prices_type
        )
    ) AS today
JOIN
    (
        SELECT gp.*
        FROM general_prices gp
        WHERE gp.general_prices_date = (
            SELECT gp2.general_prices_date
            FROM general_prices gp2
            WHERE gp2.general_prices_type = gp.general_prices_type
            ORDER BY gp2.general_prices_date DESC
            LIMIT 1 OFFSET 1
        )
    ) AS yesterday
ON today.general_prices_type = yesterday.general_prices_type
JOIN types AS t
ON today.general_prices_type = t.type_id
ORDER BY t.type_name;
