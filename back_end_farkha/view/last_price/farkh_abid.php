<?php

include "../../connect.php";


$stmt = $con->prepare("SELECT `prices`.`price` FROM `prices` WHERE `prices`.`price_type` = 1 ORDER BY `prices`.`date_price` DESC LIMIT 2;");

$stmt->execute(array());

$data = $stmt->fetchAll(PDO::FETCH_ASSOC);


$count = $stmt->rowCount();

if($count > 0 ){
    echo json_encode(array("status" => "success" , "data" => $data )) ;
}else{
    echo json_encode(array("status" => "fail" )) ;
}

?>
