<?php

function get($url)
{
	$ch = curl_init(); 
	$headers = array('Content-type: plaintext,');  
	curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);  
	curl_setopt($ch, CURLOPT_URL, $url);  
	curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	$api_response = curl_exec($ch);
	return $api_response;
}

//$api_key = 'rfej9napna';
$api_key = 'wf55k72cc3';

$longitude = $_GET['longitude'];
$latitude = $_GET['latitude']; 
$distance = ($_GET['distance']) ? $_GET['distance']:'2';
$gas_index = ($_GET['gas_type']) ? ($_GET['gas_type']):'0';
$sort_by = ($_GET['sort_by']) ? $_GET['sort_by']:'distance';

$gas_type = array('reg','mid','pre','diesel');

$url = 'http://api.mygasfeed.com/stations/radius/'.$latitude.'/'.$longitude.'/'.$distance.'/'.$gas_type[$gas_index].'/'.$sort_by.'/'.$api_key.'.json';

echo get($url);

?>


