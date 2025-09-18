<?php


include "config.php";


function filterRequset($key) {
    return isset($_POST[$key]) ? $_POST[$key] : (isset($_GET[$key]) ? $_GET[$key] : null);
}


function checkAuthenticate(){
   if (isset($_SERVER['PHP_AUTH_USER'])  && isset($_SERVER['PHP_AUTH_PW'])) {

       if ($_SERVER['PHP_AUTH_USER'] != PHP_USER ||  $_SERVER['PHP_AUTH_PW'] != PHP_PASS ){
           header('WWW-Authenticate: Basic realm="My Realm"');
           header('HTTP/1.0 401 Unauthorized');
           echo 'Page Not Found';
           exit;
       }
   } else {
       exit;
   }
}
?>