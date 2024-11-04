<?php

include "connect.php";

$price =  filterRequset('price');
$id_type = filterRequset('id_type');

$stmt = $con->prepare("INSERT INTO `prices` (`price`, `price_type`)
VALUES (?, ?);");

$stmt->execute(array($price  , $id_type ));

$data = $stmt->fetchAll(PDO::FETCH_ASSOC);


$count = $stmt->rowCount();

if($count > 0 ){
    echo json_encode(array("status" => "success"  )) ;
}else{
    echo json_encode(array("status" => "fail" )) ;
}

?>