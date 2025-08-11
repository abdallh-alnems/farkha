CREATE OR REPLACE VIEW  last_prices AS
SELECT p.price AS latest_price, ( SELECT p2.price FROM prices p2 WHERE p2.price_type = p.price_type 
ORDER BY p2.date_price DESC LIMIT 1 OFFSET 1 ) AS second_latest_price, t.type_name AS type_name, t.type_id 
FROM prices p JOIN types t ON p.price_type = t.type_id
WHERE p.date_price = ( SELECT MAX(p2.date_price) FROM prices p2 WHERE p2.price_type = p.price_type ) 
ORDER BY t.type_id;



