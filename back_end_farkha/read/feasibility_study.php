<?php

include "../connect.php";

$stmt = $con->prepare("SELECT 
    t.type_name,
    ROUND((gp.higher_general_prices + gp.lower_general_prices) / 2, 0) AS price
FROM general_prices gp
INNER JOIN (
    SELECT general_prices_type, MAX(general_prices_date) AS max_date
    FROM general_prices
    WHERE general_prices_type IN (1, 18)
    GROUP BY general_prices_type
) latest 
    ON gp.general_prices_type = latest.general_prices_type
   AND gp.general_prices_date = latest.max_date
JOIN types t 
    ON t.type_id = gp.general_prices_type

UNION ALL

SELECT 
    t.type_name,
    fp.feed_prices AS price
FROM feed_prices fp
INNER JOIN (
    SELECT feed_prices_type, MAX(feed_prices_date) AS max_date
    FROM feed_prices
    WHERE feed_prices_type IN (50, 51, 52)
    GROUP BY feed_prices_type
) latest 
    ON fp.feed_prices_type = latest.feed_prices_type
   AND fp.feed_prices_date = latest.max_date
JOIN types t 
    ON t.type_id = fp.feed_prices_type;
");

$stmt->execute(array());

$data = $stmt->fetchAll(PDO::FETCH_ASSOC);


$count = $stmt->rowCount();

if($count > 0 ){
    echo json_encode(array("status" => "success" , "data" => $data )) ;
}else{
    echo json_encode(array("status" => "fail" )) ;
}

?>
