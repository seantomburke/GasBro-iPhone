<?php
error_reporting(1);
ini_set('display_errors', 'On');

include "Venmo.class.php";
$venmo = new Venmo($_GET['access_token']);

if($_GET['access_token'] == null)
{
    $message['error'] = "must provide access_token";
    echo json_encode($message);  
    die();
}

if($_GET['data'] == "friends")
{
    echo $venmo->friends($_GET['term'],$_GET['limit'],$_GET['after'], $_GET['access_token']);
}

//{"data": {"username": "hawaiianchimp", "first_name": "Sean", "last_name": "Burke", "display_name": "Sean Burke", "about": "No Short Bio", "email": null, "phone": null, "profile_picture_url": "https://venmopics.appspot.com/u/v1/f/4ff78e43-aabd-4014-b175-7fb08cb0b91d", "balance": 26.00, "id": 382467, "date_joined": "2013-07-14T10:22:04"}}
?>