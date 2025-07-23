CREATE OR REPLACE VIEW  last_prices AS
SELECT p.price AS latest_price, ( SELECT p2.price FROM prices p2 WHERE p2.price_type = p.price_type 
ORDER BY p2.date_price DESC LIMIT 1 OFFSET 1 ) AS second_latest_price, t.type_name AS type_name, t.type_id 
FROM prices p JOIN types t ON p.price_type = t.type_id
WHERE p.date_price = ( SELECT MAX(p2.date_price) FROM prices p2 WHERE p2.price_type = p.price_type ) 
ORDER BY t.type_id;


SELECT 
    main.main_name AS نوع_الدواجن,
    types.type_name AS نوع_فرعي,
    MAX(CASE WHEN ranked_prices.rank = 1 THEN ranked_prices.price END) AS السعر_الحالي,
    MAX(CASE WHEN ranked_prices.rank = 2 THEN ranked_prices.price END) AS السعر_القديم
FROM 
    main
JOIN 
    types ON main.main_id = types.main_type
JOIN 
    (
        SELECT 
            price_type, 
            price, 
            ROW_NUMBER() OVER (PARTITION BY price_type ORDER BY date_price DESC) AS rank
        FROM 
            prices
    ) AS ranked_prices ON types.type_id = ranked_prices.price_type
WHERE 
    main.main_id = 1
GROUP BY 
    types.type_id;
