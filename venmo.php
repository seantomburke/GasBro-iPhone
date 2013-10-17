<?php

include "Venmo.class.php";
echo "Venmo:".$_GET['access_token'];
$venmo = new Venmo($_GET['access_token']);
echo "<br>id:".$venmo->me->id;
echo "<br>username:".$venmo->me->username;
echo "<br>display_name:".$venmo->me->display_name;

echo json_encode($venmo->friends());

//{"data": {"username": "hawaiianchimp", "first_name": "Sean", "last_name": "Burke", "display_name": "Sean Burke", "about": "No Short Bio", "email": null, "phone": null, "profile_picture_url": "https://venmopics.appspot.com/u/v1/f/4ff78e43-aabd-4014-b175-7fb08cb0b91d", "balance": 26.00, "id": 382467, "date_joined": "2013-07-14T10:22:04"}}
?>

<html>
<head>
<title>GasBro
</title>
</head>

</html>