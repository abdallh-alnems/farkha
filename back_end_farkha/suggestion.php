<?php

include "connect.php";

$suggestion =  filterRequset('suggestion');

$stmt = $con->prepare("INSERT INTO `suggestion` (`suggestion_text`)
VALUES (?);");

$stmt->execute(array($suggestion));

$data = $stmt->fetchAll(PDO::FETCH_ASSOC);


$count = $stmt->rowCount();

if($count > 0 ){
    echo json_encode(array("status" => "success"  )) ;
}else{
    echo json_encode(array("status" => "fail" )) ;
}

?>