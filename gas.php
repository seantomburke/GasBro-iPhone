<?php

error_reporting(1);

function get($lat,$long,$dist,$type,$sort,$key)
{
    $url = 'http://api.mygasfeed.com/stations/radius/'.$lat.'/'.$long.'/'.$dist.'/'.$type.'/'.$sort.'/'.$key.'.json';

	$ch = curl_init(); 
	$headers = array('Content-type: plaintext,');  
	curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);  
	curl_setopt($ch, CURLOPT_URL, $url);  
	curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	$api_response = curl_exec($ch);
	
    $json = json_decode($api_response);
    
    if($json){
        //echo '<br>stations:'.count($json->stations);
            if(count($json->stations) < 1)
            {
                if($dist < 20)
                {
                    $dist *= 3;
                    //echo '<br>distance:'.$dist;
                    return get($lat,$long,$dist,$type,$sort,$key);
                }
                else
                {
                    $message = "No Gas Stations Within 20 miles";
                    return json_encode($message);
                }
            }
            else
            {
                //echo '<br>returning $json';
                return json_encode($json);
            }
    }
}

//$api_key = 'rfej9napna';
$api_key = 'wf55k72cc3';

$longitude = $_GET['longitude'];
$latitude = $_GET['latitude']; 
$distance = ($_GET['distance']) ? $_GET['distance']:'2';
$gas_index = ($_GET['gas_type']) ? ($_GET['gas_type']):'0';
$sort_by = ($_GET['sort_by']) ? $_GET['sort_by']:'distance';
$gas_type = array('reg','mid','pre','diesel');

if(!$longitude){
    $message[0] = "No Longitude";
}
if(!$latitude){
    $message[1] = "No Latitude";
    echo json_encode($message);
}


echo get($latitude,$longitude,$distance,$gas_type[$gas_index],$sort_by,$api_key);
//include_once('analytics.php');
?>


