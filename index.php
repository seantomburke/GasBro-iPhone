<?php
session_start();
error_reporting(1);
ini_set('display_errors', 'On');

include 'Venmo.class.php';
$venmo = new Venmo($_SESSION['access_token']);
if($_GET['access_token'])
{
    $_SESSION['access_token'] = $_GET['access_token'];
   //header("Location: //". $_SERVER['SERVER_NAME']);    
}

?>

<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <title>GasBro</title>
        <meta name="description" content="Easliy split the cost of gas with friends">
        <meta name="viewport" content="width=device-width">
        <meta property="og:title" content="GasBro" />
          <meta property="og:type" content="website" />
          <!--<meta property="og:site_name" content="http://www.gasbro.com/" />-->
          <meta property="og:image" content="/img/bro.png" />
          <meta property="og:description" content="Easily split the cost of gas with your friends!" />
          <!--<meta property="og:url" content="http://www.gasbro.com/" />-->

        <link rel="stylesheet" href="css/bootstrap.min.css">
        <style>
            body {
                padding-top: 60px;
                padding-bottom: 40px;
            }
        </style>
        <link rel="stylesheet" href="css/bootstrap-responsive.min.css">
        <link rel="stylesheet" href="css/main.css?<?php echo time() ?>">
        <link href='//fonts.googleapis.com/css?family=Lato:100,300,400' rel='stylesheet' type='text/css'>
    </head>
    <body data-spy="scroll" data-target="#navbar">
        <!--[if lt IE 7]>
            <p class="chromeframe">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">activate Google Chrome Frame</a> to improve your experience.</p>
        <![endif]-->
        <div id="navbar" class="navbar navbar-inverse">
            <div class="navbar-inner">
                <div class="container">
                    <a class="brand" href="#">Share</a>
                    <!-- AddThis Button BEGIN -->
                        <div class="addthis_toolbox addthis_default_style ">
                        <a class="addthis_button_facebook_like" fb:like:layout="button_count"></a>
                        <a class="addthis_button_tweet"></a>
                        <a class="addthis_counter addthis_pill_style"></a>
                        </div>
                        <!-- AddThis Button END -->
                    <div class="pull-right">
                    <?php 
                    if($venmo->loggedin)
                    {
                     echo  '
                     <div class="nav">
                         <li class="dropdown">
		                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">'.$venmo->me->display_name.'<b class="caret"></b></a>
		                        <ul class="dropdown-menu">
		                        	<li class="nav-header">Balance</li>
		                        	<li><a href="#">$'.$venmo->me->balance.'</a></li>
		                        	<li><a href="#">loggedin = '.$venmo->loggedin.'</a></li>
		                            <li class="divider"></li>
		                            <li class="nav-header">Completed</li>
		                            <li><a href="#">Logout</a></li>
		                        </ul>
		                    </li>
		            </div>';
                    }
                    else
                    {
                     echo   '<a class="btn" href="'.$venmo->auth_link.'">Login with Venmo</a>';
                     
                    }
                    
                    ?>
                    </div>
                </div>
            </div>
        </div>
        <header class="jumbotron subhead">
            <div class="media">
              <a class="pull-left" href="http://www.gasbro.com/">
                <img class="media-object" src="/img/bro.png" width="64">
              </a>
              <div class="media-body">
                <h1 class="media-heading">GasBro</h1>
                <p class="lead">Easliy split the cost of gas with friends</p>
              </div>
            </div>
        </header>
        
        
        <!-- Modal -->
        <div id="shareModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="modal" aria-hidden="true">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
            <h3 id="shareModalHeader">GasBro</h3>
          </div>
          <div class="modal-body">
            <div class="row-fluid">
              <div id="prices2" style="display:none" class="row-fluid">
                <div class="span3">
                    <div class="controls">
                        <span>Number of People:</span>
                        <h1 id="num_people" class=""></h1>
                    </div>
                </div>
                  <div class="span3">
                      <div class="controls">
                          <span>Gas in <span id="gas_span2"></span>:</span>
                          <h1 id="gas2" class=""></h1>
                      </div>
                  </div>
                  <div class="span3">
                      <div class="controls">
                          <span>Per Person:</span>
                          <h1 id="cost2" class=""></h1>
                      </div>
                  </div>
                  <div class="span3">
                      <div class="controls">
                          <span>Total:</span>
                          <h1 id="total2" class=""></h1>
                      </div>
                  </div>
              </div>
           </div>
            <div class="row">
              <?php 
                if($_SESSION['username'] == null)
                {
                echo '<a id="venmo-btn" class="btn btn-info" type="button" href="'.$venmo->auth_link.'">
                Login with Venmo
                    </a>';
                }
                else{
                echo '
                
                <div class="input-append">
                  <input class="typeahead" id="venmo-friends" type="text">
                  <button id="venmo-btn" class="btn btn-info" type="button" href="#"> 
                    Venmo!
                  </button>
                </div>';
                }
            ?>
            </div>
            
           </div>
          <div class="modal-footer">
            <div class="row text-center">
            <span> OR </span>
            </div>
            <div class="row">
            <div class="input-append">
              <input id="url" type="text">
              <button id="facebook" class="btn btn-primary" type="button" href="#" 
                onclick="
                  window.open(
                    'https://www.facebook.com/sharer/sharer.php?u='+encodeURIComponent(location.href), 
                    'facebook-share-dialog', 
                    'height=450, width=550, top='+($(window).height()/2 - 225) +', left='+$(window).width()/2 +', toolbar=0, location=0, menubar=0, directories=0, scrollbars=0'); 
                  return false;">
                Facebook
              </button>
              <button id="tweet" class="btn btn-info" type="button" href="#" 
                onclick="
                  window.open(
                  'http://twitter.com/share?url=' + encodeURIComponent(location.href) + '&text=' + document.title + '&', 'twitterwindow', 'height=450, width=550, top='+($(window).height()/2 - 225) +', left='+$(window).width()/2 +', toolbar=0, location=0, menubar=0, directories=0, scrollbars=0');
                  return false;">
                Tweet
              </button>
              </div>
            </div>
          </div>
        </div>
        
        
        <div class="container">
            <!-- Example row of columns -->
            <div class="row">
               <div class="span4 sidebar" >
                    <form class="form" id="main-form">
                        <div class="controls">
                            <span for="start-location">Start Location</span>
                            <br>
                            <div class="input-append">
                              <input id="start" type="text" name="start-location" placeholder="Start Location" required/>
                              <button id="current-location" class="btn" type="button" data-trigger"hover" data-toggle="popover" data-content="Click for current Location" data-placement="right"
                                data-loading-text="<i class='icon-refresh'></i>">
                                    <i class="icon-map-marker"></i>
                              </button>
                            </div>
                        </div>

                        <div class="controls">
                            <span for="end-location">End Destination</span>
                            <br>
                            <input id="end" type="text" name="end-location" placeholder="Destination" required/>
                        </div>
                        
                        <div class="controls">
                            <span for="end-location">Fuel Type</span>
                            <br>
                            <div class="btn-group" data-toggle="buttons-radio">
                              <button type="button" class="btn btn-primary">Reg</button>
                              <button type="button" class="btn btn-primary">Med</button>
                              <button type="button" class="btn btn-primary">Prem</button>
                              <button type="button" class="btn btn-primary">Deis</button>
                            </div>
                        </div>

                        <div class="controls">
                            <span for="people">Number of People</span>
                            <br>
                            <input id="people" placeholder="Number of People" type="number" name="people" required/>
                        </div>

                        <div class="controls">
                            <span for="mpg">Miles Per Gallon</span>
                            <br>
                            <input id="mpg" placeholder="MPG" type="number" name="mpg" required/>
                        </div>

                        <div class="controls">
                            <label class="checkbox">
                                <input id="roundtrip" type="checkbox" name="roundtrip"><span>Roundtrip?</span>
                            </label>
                        </div>

                        <div class="controls">
                            <button id="calculate" class="btn btn-large btn-info">Venmo</button>
                        </div>
                   </form>
                </div>
                <div class="span8">
                    <div id="map-frame" class="hidden-phone" style="height:320px;">
                        <div id="map-canvas" style="height:100%;"></div>
                    </div>
                </div>
            </div>
            <div id="prices" class="row">
              <div class="span3">
                  <div class="controls">
                      Number of People:
                      <h1 id="num_people2" class=""></h1>
                  </div>
              </div>
                <div class="span3">
                    <div class="controls">
                        Cost of gas in <span id="gas_span"></span>:
                        <h1 id="gas" class=""></h1>
                    </div>
                </div>
                <div class="span3">
                    <div class="controls">
                        <span>Cost per Person:</span>
                        <h1 id="cost" class=""></h1>
                    </div>
                </div>
                <div class="span3">
                    <div class="controls">
                        <span>Total Cost:</span>
                        <h1 id="total" class=""></h1>
                    </div>
                </div>
            </div>
            <hr>
            <footer>
                <p>Developed by <a href="http://www.seantburke.com/?r=GasBro">Sean Thomas Burke</a> &copy; GasBro <?php echo date('Y');?></p>
            </footer>

        </div> <!-- /container -->
        
        <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=true"></script>
        <script type="text/javascript" src="//www.parsecdn.com/js/parse-1.2.8.min.js"></script>
        <script type="text/javascript" src="js/vendor/modernizr-2.6.2-respond-1.1.0.min.js"></script>
        <script type="text/javascript" src="//code.jquery.com/jquery-1.10.1.min.js"></script>
        <script type="text/javascript">var addthis_config = {"data_track_addressbar":true};</script>
        <script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-502407f64d3ce404"></script>
        <!--<script type="text/javascript" src="//code.jquery.com/jquery-migrate-1.2.1.min.js"></script>-->
        <!--<script type="text/javascript" src="js/hogan.js"></script>-->
        <script type="text/javascript" src="js/vendor/bootstrap.min.js"></script>
        <script type="text/javascript" src="js/plugins.js"></script>
        <!--<script>if ( typeof window.JSON === 'undefined' ) { document.write('<script src="js/json2.js"><\/script>'); }</script>-->
        <script type="text/javascript" src="js/jquery.history.js"></script>
        <!--<script type="text/javascript" src="js/typeahead.min.js"></script>-->
        <script type="text/javascript" src="js/main.js?<?php echo time() ?>"></script>
        <script>
            getFriends(' <?php echo $venmo->access_token; ?> ');
        </script>
        <script>
            var _gaq=[['_setAccount','UA-42611920-1'],['_trackPageview']];
            (function(d,t){var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
            g.src=('https:'==location.protocol?'//ssl':'//www')+'.google-analytics.com/ga.js';
            s.parentNode.insertBefore(g,s)}(document,'script'));
        </script>
    </body>
</html>