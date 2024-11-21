<?php

include "../connect.php";

$stmt = $con->prepare("SELECT `prices`.`price` FROM `prices` 
WHERE `prices`.`price_type` IN (1, 3, 8, 9, 10) 
AND `prices`.`date_price` = ( SELECT MAX(`p2`.`date_price`) FROM `prices` AS `p2` 
WHERE `p2`.`price_type` = `prices`.`price_type` ) 
ORDER BY `prices`.`price_type`;");

$stmt->execute(array());

$data = $stmt->fetchAll(PDO::FETCH_ASSOC);


$count = $stmt->rowCount();

if($count > 0 ){
    echo json_encode(array("status" => "success" , "data" => $data )) ;
}else{
    echo json_encode(array("status" => "fail" )) ;
}

?>
