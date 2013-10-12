<?php 
session_start();

/**
 * Venmo OAuth API
 *
 * This is a simple PHP plaintext OAuth 1.0 API for Venmo
 * 
 * @author Sean Thomas Burke <http://www.seantburke.com/>
 * @date 2013-10-11 
 * October 10, 2013
 */

class Venmo {

	private static $CLIENT_ID = '1447'; //id of Venmo app
	private static $SCOPE = 'ACCESS_FRIENDS,ACCESS_PROFILE,MAKE_PAYMENTS'; // = ACCESS_FRIENDS,ACCESS_PROFILE,MAKE_PAYMENTS

	private $access_token;

	/**
	 * Venmo() 
	 * creates the object and decides based on the $_SESSION whether to request() or processCallBack()
	 *
	 * @author 	Sean Thomas Burke <http://www.seantburke.com/>
	 */
	public function __construct($access_token){
		$this->access_token = $access_token;
	}

	public function request()
	{
		//request URl
		$url = 'https://api.venmo.com/oauth/authorize'
		// initiate a cURL; if you don't know what curl is, look it up at http://curl.haxx.se/
		$ch = curl_init(); 
		//Venmo uses plaintext OAuth 1.0; make the header for this request
		$headers = array('Authorization: OAuth oauth_version="1.0", oauth_signature_method="PLAINTEXT", oauth_consumer_key="'.self::$APP_KEY.'", oauth_signature="'.self::$APP_SECRET.'&"');  
		// set cURL options and execute
		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);  
		curl_setopt($ch, CURLOPT_URL, $url.'?client_id='.self::CLIENT_ID.'&scope='.self::SCOPE);  
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);  
		$request_token_response = curl_exec($ch);
	}

	public function me()
	{
		$this->get("/me");
	}

	/**
	 * get($url)
	 *
	 * Using the REST api, make a call to a REST URL, and it will return the array
	 * Step 3: Make an API call
	 *
	 * @link 	https://www.venmo.com/developers/reference/api	
	 * @author 	Sean Thomas Burke <http://www.seantburke.com>
	 *
	 * @param 	$url	REST URL		
	 * @return 	array	decoded from JSON response
	 */
	function get($path)
	{	
		$question_mark = (strstr($path, '?')) ? '&':'?';

		$url = "https://api.venmo.com".$path.$question_mark."access_token=".$this->access_token;
		$ch = curl_init(); 
		$headers = array('Authorization: OAuth oauth_version="2.0"');  
		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);  
		curl_setopt($ch, CURLOPT_URL, $url);  
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		$api_response = curl_exec($ch);
		return $api_response;
	}



}

?>
