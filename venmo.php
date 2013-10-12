<?php 
session_start();
require_once("Venmo.class.php");

$venmo = Venmo($_GET['access_token']);

$venmo->me();

?>
<html>
<script type="text/javascript">
function(){

var wind = window.open('http://m.gasbro.com?access_token=<?php echo $_GET["access_token"];?>');
}
self.close();
</script>

</html>