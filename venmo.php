<?php 
session_start();
require_once("Venmo.class.php");


$venmo = Venmo($_GET['access_token']);

$venmo->me();



?>