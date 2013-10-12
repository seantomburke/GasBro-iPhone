<?php

include_once "Venmo.class.php";

echo $_GET['access_token'];
$venmo = Venmo($_GET['access_token']);
$venmo->get('https://api.venmo.com/me?access_token='.$_GET['access_toke']);
?>

<html>
<head>
<title>GasBro
</title>
</head>
<script type="text/javascript">

function(){

var wind = window.open('http://m.gasbro.com/?access_token=<?php echo $_GET["access_token"];?>');

self.close();
}
</script>

</html>