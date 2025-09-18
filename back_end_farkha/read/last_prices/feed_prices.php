<?php

include "../../connect.php";

$type =  filterRequset('type');

        $stmt = $con->prepare("SELECT 
            fp_today.feed_prices AS last_price,
            fp_yesterday.feed_prices AS yesterday_price,
            t.type_name
        FROM types t
        LEFT JOIN feed_prices fp_today 
            ON fp_today.feed_prices_type = t.type_id
            AND fp_today.feed_prices_date = (
                SELECT MAX(fp1.feed_prices_date) 
                FROM feed_prices fp1 
                WHERE fp1.feed_prices_type = t.type_id
            )
        LEFT JOIN feed_prices fp_yesterday 
            ON fp_yesterday.feed_prices_type = t.type_id
            AND fp_yesterday.feed_prices_date = (
                SELECT MAX(fp2.feed_prices_date) 
                FROM feed_prices fp2 
                WHERE fp2.feed_prices_type = t.type_id 
                AND fp2.feed_prices_date < (
                    SELECT MAX(fp3.feed_prices_date) 
                    FROM feed_prices fp3 
                    WHERE fp3.feed_prices_type = t.type_id
                )
            )
        WHERE t.type_main = ?;



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