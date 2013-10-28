<?php
session_start();
error_reporting(1);
ini_set('display_errors', 'On');
$_SESSION['id'] = $_GET['id'];

include 'Venmo.class.php';
$venmo = new Venmo();

header("Location: ".$venmo->auth_link);

?>