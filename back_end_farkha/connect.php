<?php 
    include "function.php";

$dsn = DB_NAME ; 
$user = DB_USER;
$pass = DB_PASS ; 
$option = array(
    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES UTF8"
);
try {
    $con = new PDO($dsn , $user , $pass , $option ); 
    $con->setAttribute(PDO::ATTR_ERRMODE , PDO::ERRMODE_EXCEPTION) ;

    
     header("Access-Control-Allow-Origin: *");
     header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With, Access-Control-Allow-Origin");
     header("Access-Control-Allow-Methods: POST, OPTIONS , GET");

 checkAuthenticate();

}catch(PDOException $e){
  echo $e->getMessage() ;        
}
?>