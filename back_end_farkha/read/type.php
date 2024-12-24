<?php

include "../connect.php";

$mainType =  filterRequset('mainId');

$stmt = $con->prepare("SELECT * FROM `types` WHERE `types`.`main_type` = ?");

$stmt->execute(array($mainType ));

$data = $stmt->fetchAll(PDO::FETCH_ASSOC);


$count = $stmt->rowCount();

if($count > 0 ){
    echo json_encode(array("status" => "success" , "data" => $data )) ;
}else{
    echo json_encode(array("status" => "fail" )) ;
}

?>          