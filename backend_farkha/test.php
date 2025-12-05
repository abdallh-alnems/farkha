       <?php

       $notAuth = "" ; 

       require_once __DIR__ . '/core/connect.php'; 
       include "notification/fcm_sender.php";
       
       // Require authentication
       checkAuthenticate();
       
       sendFCM(""  , "How Are You" , "users" , "" , "") ; 

       echo "Send"  ;

       ?>