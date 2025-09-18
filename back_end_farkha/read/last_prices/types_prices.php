<?php

include "../../connect.php";

$type =  filterRequset('type');

$stmt = $con->prepare("SELECT 
    gp_today.higher_general_prices AS last_higher_price,
    gp_today.lower_general_prices AS last_lower_price,
    gp_yesterday.higher_general_prices AS yesterday_higher_price,
    gp_yesterday.lower_general_prices AS yesterday_lower_price,
    t.type_name
FROM types t
LEFT JOIN general_prices gp_today 
    ON gp_today.general_prices_type = t.type_id
    AND gp_today.general_prices_date = (
        SELECT MAX(gp1.general_prices_date) 
        FROM general_prices gp1 
        WHERE gp1.general_prices_type = t.type_id
    )
LEFT JOIN general_prices gp_yesterday 
    ON gp_yesterday.general_prices_type = t.type_id
    AND gp_yesterday.general_prices_date = (
        SELECT MAX(gp2.general_prices_date) 
        FROM general_prices gp2 
        WHERE gp2.general_prices_type = t.type_id 
          AND gp2.general_prices_date < (
              SELECT MAX(gp3.general_prices_date) 
              FROM general_prices gp3 
              WHERE gp3.general_prices_type = t.type_id
          )
    )
WHERE t.type_main = ?
 ;


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