<?php 
session_start();
error_reporting(1);
ini_set('display_errors', 'On');

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

	public $access_token;
	public $me;
	public $auth_link;
	public $loggedin = false;

	/**
	 * Venmo() 
	 * creates the object and decides based on the $_SESSION whether to request() or processCallBack()
	 *
	 * @author 	Sean Thomas Burke <http://www.seantburke.com/>
     */
	public function __construct($access_token){
	    
	    if($this->loggedin($access_token))
	    {
	        //echo 'using:access_token<br>';
	        $this->loggedin = true;
	        $this->access_token = $access_token;
	        $_SESSION['access_token'] = $access_token;
	        //echo 'session: '.$_SESSION['access_token'].'<br>';
	    }
	    elseif($this->loggedin($_SESSION['access_token']))
	    {
	        //echo 'using:session<br>';
	        $this->loggedin = true;
	        $this->access_token = $_SESSION['access_token'];
	    }
	    else
	    {
	       //echo 'using:neither '.$_SESSION['access_token'].'<br>';
	       $this->loggedin = false;
	    }
	    //echo "access_token: ".$this->access_token."<br>";
		$this->me = $this->me();
		$this->auth_link = 'https://api.venmo.com/oauth/authorize?client_id='.self::$CLIENT_ID.'&scope='.self::$SCOPE;
		//$this->auth_link = 'https://api.venmo.com/oauth/authorize?client_id=1447&scope=make_payments,access_profile&response_type=code'
	}
	
	private function loggedin($access_token)
	{
	    if(empty($access_token))
	    {
	        return false;
	    }
	    else
	    {
    	    //echo "username: ".$this->me($access_token)->username."<br>";
    	    return $this->me($access_token)->username;
	    }
	}

	public function request()
	{
		//request URl
		$url = 'https://api.venmo.com/oauth/authorize';
		// initiate a cURL; if you don't know what curl is, look it up at http://curl.haxx.se/
		$ch = curl_init(); 
		//Venmo uses plaintext OAuth 1.0; make the header for this request
		$headers = array('Authorization: OAuth oauth_version="1.0", oauth_signature_method="PLAINTEXT", oauth_consumer_key="'.self::$APP_KEY.'", oauth_signature="'.self::$APP_SECRET.'&"');  
		// set cURL options and execute
		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);  
		curl_setopt($ch, CURLOPT_URL, $url.'?client_id='.self::$CLIENT_ID.'&scope='.self::$SCOPE);  
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);  
		$request_token_response = curl_exec($ch);
	}

	public function me($access_token = null)
	{
		return $this->get("/me", $access_token);
	}
	
	public function friends($term = '', $limit = '20', $after = 0, $access_token = null)
	{
	    $input = $this->get("/users/".$this->me->id."/friends?limit=".$limit."&after=".$after, $access_token);
	    foreach($input as $key1 => $value1)
	    {
	        if(strpos($value1->display_name, $term) !== false)
	        {
    	        $output[$key1]['caption'] = $value1->display_name;
    	        $output[$key1]['value'] = $value1->id;
    	        $output[$key1]['tokens'][0] = $value1->display_name;
    	        $output[$key1]['tokens'][1] = $value1->username;
    	        foreach($value1 as $key2 => $value2)
    	        {
    	            $output[$key1][$key2] = $value2;
    	        }
	        }
	        else
	        {
	            $output[$key1]['error'] = 'The term '.$term.' was not found'; 
	        }
	    }
	    //var_dump($output);
	    $str = preg_replace('/\\\"/','"', json_encode($output));
	    return $str;
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
	function get($path, $access_token)
	{	
	    $access_token = ($access_token) ? $access_token:$this->access_token;
		$question_mark = (strstr($path, '?')) ? '&':'?';

		$url = "https://api.venmo.com".$path.$question_mark."access_token=".$access_token;
		//echo "url:".$url;
		$ch = curl_init(); 
		$headers = array('Authorization: OAuth oauth_version="2.0"');  
		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);  
		curl_setopt($ch, CURLOPT_URL, $url);  
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		$api_response = curl_exec($ch);
		$output = json_decode($api_response);
		return $output->data;
	}



}

?>