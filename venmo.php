<?php

echo $_GET['access_token'];

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