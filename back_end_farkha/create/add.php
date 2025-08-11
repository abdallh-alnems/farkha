 <?php

 include "../connect.php";

$price =  filterRequset('price');
$typeId = filterRequset('type_id');

$stmt = $con->prepare("INSERT INTO `prices` (`price`, `price_type`)
VALUES (?, ?);");

$stmt->execute(array($price  , $typeId ));

$data = $stmt->fetchAll(PDO::FETCH_ASSOC);


$count = $stmt->rowCount();

if($count > 0 ){
    echo json_encode(array("status" => "success"  )) ;
}else{
    echo json_encode(array("status" => "fail" )) ;
}

?>          