<?php

include "../connect.php";

$type =  filterRequset('type');

$stmt = $con->prepare("SELECT 
    types.type_id AS type_id,
    types.type_name AS type,
    MAX(CASE WHEN ranked_prices.rank = 1 THEN ranked_prices.price END) AS price,
    MAX(CASE WHEN ranked_prices.rank = 2 THEN ranked_prices.price END) AS lastPrice
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
    main.main_id = ?
GROUP BY 
    types.type_id;

");

$stmt->execute(array($type ));

$data = $stmt->fetchAll(PDO::FETCH_ASSOC);


$count = $stmt->rowCount();

if($count > 0 ){
    echo json_encode(array("status" => "success" , "data" => $data )) ;
}else{
    echo json_encode(array("status" => "fail" )) ;
}

?>