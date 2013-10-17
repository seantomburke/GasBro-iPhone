<?php

include "Venmo.class.php";
echo "Venmo:".$_GET['access_token'];
$venmo = new Venmo($_GET['access_token']);
?>

<html>
<head>
<title>GasBro
</title>
</head>

</html>