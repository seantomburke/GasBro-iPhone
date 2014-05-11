//
//  GBViewController.m
//  GasBro
//
//  Created by Sean Thomas Burke on 9/26/13.
//  Copyright (c) 2013 Nyquist Labs. All rights reserved.
//

#import "GBViewController.h"
#import "GBCache.h"
#import "GBStartAnnotation.h"
#import "GBEndAnnotation.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1



@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress;
-(NSData*)toJSON;
@end

@implementation NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL:
                    [NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}
@end

@interface GBViewController (){
    CLLocationManager *locationManager;
    
    NSArray *activityItems;
    
    UIActivityViewController *activityController;
    
}

@end

@implementation GBViewController
@synthesize cache;
@synthesize currentLocationButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.topView.opaque = NO;
    self.bottomView.opaque = NO;
    [_mapView setDelegate:self];
    
    //map stufff
    
	// Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _gas_type = [defaults objectForKey:@"gasType"];
    _mpg = [defaults doubleForKey:@"mpg"];
    
    locationManager = [[CLLocationManager alloc] init];
    [self peopleSliderChanged:(self)];
    [self roundtripSwitchChanged:(self)];
    [self mpgSliderChanged:(self)];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    _endLocationText.delegate = self;
    _startLocationText.delegate = self;
    
    UITapGestureRecognizer *maptap = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self
                                      action:@selector(hidePanels)];
    
    [_mapView addGestureRecognizer:maptap];
    
    UITapGestureRecognizer *nonmaptaptop = [[UITapGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(showPanels)];
    
    [_topView addGestureRecognizer:nonmaptaptop];
    
    UITapGestureRecognizer *nonmaptapbottom = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(showPanels)];
    
    [_bottomView addGestureRecognizer:nonmaptapbottom];
    
    
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(void)hidePanels {
    [self dismissKeyboard];
    [UIView animateWithDuration:.25
                     animations:^{
                         _topView.frame = CGRectMake(0, -100, _topView.bounds.size.width, _topView.bounds.size.height);
                         _bottomView.frame = CGRectMake(0, self.view.bounds.size.height - _bottomView.bounds.size.height + 100, _bottomView.bounds.size.width, _bottomView.bounds.size.height);// its final location
                     }];
}


-(void)showPanels {
    
    [self dismissKeyboard];
    [UIView animateWithDuration:.25
                     animations:^{
                         _topView.frame = CGRectMake(0, 0, _topView.bounds.size.width, _topView.bounds.size.height);// its final location
                     }];
    [UIView animateWithDuration:.25
                     animations:^{
                         _bottomView.frame = CGRectMake(0, self.view.bounds.size.height - _bottomView.bounds.size.height, _bottomView.bounds.size.width, _bottomView.bounds.size.height);// its final location
                     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Any additional checks to ensure you have the correct textField here.
    if(textField == _startLocationText)
    {
        [self startSearch:textField withError:true];
        [_endLocationText becomeFirstResponder];
    }
    else
    {
        [self endSearch:textField withError:true];
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)dismissKeyboard {
    [_startLocationText resignFirstResponder];
    [_endLocationText resignFirstResponder];
}
-(void)startSearch:(UITextField*)sender withError:(BOOL)showError{
    if(![sender.text isEqualToString:@""])
    {
        _startLocationText.clearsOnBeginEditing = NO;
        CLGeocoder *startgeocoder = [[CLGeocoder alloc] init];
        [startgeocoder geocodeAddressString:sender.text completionHandler:^(NSArray *startplacemarks, NSError *error)
         {
             if (error) {
                 NSLog(@"%@", error);
                 UIAlertView *errorAlert = [[UIAlertView alloc]
                                            initWithTitle:[NSString stringWithFormat:@"%@ not found", sender.text] message:@"Please check for spelling errors and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 //_startLocationText.text = @"Network Error";
                 _price = 0;
                 _gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", _price];
                 if(showError)
                     [errorAlert show];
                 
             } else {
                 _start_placemarker = [startplacemarks lastObject];
                 if(![_start_placemarker.country  isEqual: @"United States"])
                 {
                     NSLog(@"%@", error);
                     UIAlertView *errorAlert = [[UIAlertView alloc]
                                                initWithTitle:@"Country Error" message:@"Gas Bro currently only works in the U.S. Please choose a location within the U.S." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     //_startLocationText.text = @"Network Error";
                     _price = 0;
                     _gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", _price];
                     if(showError)
                         [errorAlert show];
                 }
                 else
                 {
                     
                     _start_mapitem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:_start_placemarker]];
                     MKPlacemark *s = _start_placemarker;
                     NSMutableString *addr = [[NSMutableString alloc] init];
                     if(s.subThoroughfare)
                     {
                         [addr appendString:s.subThoroughfare];
                         [addr appendString:@" "];
                         
                     }
                     if(s.thoroughfare)
                     {
                         [addr appendString:s.thoroughfare];
                         [addr appendString:@", "];
                     }
                     if(s.locality)
                     {
                         [addr appendString:s.locality];
                         [addr appendString:@", "];
                     }
                     if(s.administrativeArea)
                     {
                         [addr appendString:s.administrativeArea];
                         [addr appendString:@" "];
                     }
                     if(s.postalCode)
                     {
                         [addr appendString:s.postalCode];
                     }
                     if([addr  isEqual: @""])
                         _startLocationText.text = addr;
                     [_mapView removeAnnotation:_start_annotation];
                     _start_annotation = [[GBStartAnnotation alloc] init];
                     [_start_annotation setColor:MKPinAnnotationColorGreen];
                     float spanX = 1.00725;
                     float spanY = 1.00725;
                     MKCoordinateRegion region;
                     region.span = MKCoordinateSpanMake(spanX, spanY);
                     region.center = _start_placemarker.location.coordinate;
                     [_mapView setRegion:region animated:YES];
                     NSLog(@"long:%f,lat:%f", _start_placemarker.location.coordinate.latitude,_start_placemarker.location.coordinate.longitude);
                     [_start_annotation setCoordinate:_start_placemarker.location.coordinate];
                     [_start_annotation setTitle:@"Start Location"];
                     [_start_annotation setSubtitle:addr];
                     [_mapView addAnnotation:_start_annotation];
                     [_mapView selectAnnotation:_start_annotation animated:YES];
                     [self calculateGas];
                 }
             }
         }];
    }
    
}
- (IBAction)startSearch:(UITextField *)sender{
    [self startSearch:sender withError:false];
}

- (void)endSearch:(UITextField *)sender withError:(BOOL)showError{
    if(![sender.text isEqualToString:@""])
    {
        CLGeocoder *endgeocoder = [[CLGeocoder alloc] init];
        [endgeocoder geocodeAddressString:sender.text completionHandler:^(NSArray *endplacemarks, NSError *error) {
            if (error && showError) {
                NSLog(@"%@", error);
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle:[NSString stringWithFormat:@"%@ not found", sender.text] message:@"Please check for spelling errors and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //_startLocationText.text = @"Network Error";
                //_price = 0;
                //_gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", _price];
                if(showError)
                    [errorAlert show];
            } else {
                _end_placemarker = [endplacemarks lastObject];
                if(![_end_placemarker.country  isEqual: @"United States"] && showError)
                {
                    NSLog(@"%@", error);
                    UIAlertView *errorAlert = [[UIAlertView alloc]
                                               initWithTitle:@"Country Error" message:@"Please choose a location within the U.S." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    //_startLocationText.text = @"Network Error";
                    //_price = 0;
                    //_gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", _price];
                    if(showError)
                        [errorAlert show];
                }
                else
                {
                    _end_mapitem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:_end_placemarker]];
                    MKPlacemark *s = _end_placemarker;
                    NSMutableString *addr = [[NSMutableString alloc] init];
                    if(s.subThoroughfare)
                    {
                        [addr appendString:s.subThoroughfare];
                        [addr appendString:@" "];
                        
                    }
                    if(s.thoroughfare)
                    {
                        [addr appendString:s.thoroughfare];
                        [addr appendString:@", "];
                    }
                    if(s.locality)
                    {
                        [addr appendString:s.locality];
                        [addr appendString:@", "];
                    }
                    if(s.administrativeArea)
                    {
                        [addr appendString:s.administrativeArea];
                        [addr appendString:@" "];
                    }
                    if(s.postalCode)
                    {
                        [addr appendString:s.postalCode];
                    }
                    
                    [_mapView removeAnnotation:_end_annotation];
                    _end_annotation = [[GBEndAnnotation alloc] init];
                    
                    if(![addr isEqual:@""])
                    {
                        [_endLocationText setText:addr];
                        [_end_annotation setSubtitle:addr];
                    }
                    
                    [_end_annotation setTitle:@"Destination"];
                    
                    float spanX = 1.00725;
                    float spanY = 1.00725;
                    MKCoordinateRegion region;
                    region.span = MKCoordinateSpanMake(spanX, spanY);
                    NSLog(@"long:%f,lat:%f", _end_placemarker.location.coordinate.latitude,_end_placemarker.location.coordinate.longitude);
                    [self getDirections];
                    [_end_annotation setColor:MKPinAnnotationColorRed];
                    [_end_annotation setCoordinate:_end_placemarker.location.coordinate];
                    [_mapView addAnnotation:_end_annotation];
                    [_end_annotation setSubtitle:addr];
                    [_mapView selectAnnotation:_end_annotation animated:YES];
                }
            }
        }];
    }
}

- (IBAction)endSearch:(UITextField *)sender {
    [self endSearch:sender withError:false];
}

- (IBAction)getCurrentLocation:(id)sender {
    
    [_startLocationText setText:@"Locating..."];
    [currentLocationButton setSelected:YES];
    _startLocationText.clearsOnBeginEditing = YES;
    _mapView.showsUserLocation = YES;
    [_mapView setShowsUserLocation:YES];
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    dispatch_async(kBgQueue, ^{
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
        int i = 0;
        int lat = 0;
        while (lat == 0 && i<1500) {
            i++;
            NSLog(@"%f",locationManager.location.coordinate.latitude);
            lat = locationManager.location.coordinate.latitude;
        }
        
        
        if(locationManager.location.coordinate.latitude != 0)
        {
            CLGeocoder *currentgeocoder = [[CLGeocoder alloc] init];
            [currentgeocoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray *startplacemarks, NSError *error){
                if (error) {
                    NSLog(@"%@", error);
                    UIAlertView *errorAlert = [[UIAlertView alloc]
                                               initWithTitle:@"Current Location Failed" message:@"Could not find Current Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    _startLocationText.text = @"Network Error";
                    _price = 0;
                    _gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", _price];
                    [errorAlert show];
                    
                } else {
                    MKPlacemark *s = [startplacemarks lastObject];
                    NSMutableString *addr = [[NSMutableString alloc] init];
                    if(s.subThoroughfare)
                    {
                        [addr appendString:s.subThoroughfare];
                        [addr appendString:@" "];
                        
                    }
                    if(s.thoroughfare)
                    {
                        [addr appendString:s.thoroughfare];
                        [addr appendString:@", "];
                    }
                    if(s.locality)
                    {
                        [addr appendString:s.locality];
                        [addr appendString:@", "];
                    }
                    if(s.administrativeArea)
                    {
                        [addr appendString:s.administrativeArea];
                        [addr appendString:@" "];
                    }
                    if(s.postalCode)
                    {
                        [addr appendString:s.postalCode];
                    }
                    _startLocationText.text = addr;
                    [currentLocationButton setSelected:NO];
                    _mapView.userLocation.subtitle = addr;
                }
            }];
        }
        else
        {
            if(![_startLocationText isEditing])
            {
                [_startLocationText setText:@"Location Error"];

                [currentLocationButton setSelected:NO];
            _startLocationText.clearsOnBeginEditing = YES;
            }
        }
        
        _start_placemarker = [[MKPlacemark alloc] initWithCoordinate:locationManager.location.coordinate addressDictionary:NULL];
        _start_mapitem = [MKMapItem mapItemForCurrentLocation];
        
        [locationManager stopUpdatingLocation];
        
        [_mapView selectAnnotation:_mapView.userLocation animated:YES];
        [self calculateGas];
    });
    
    
    
}

- (IBAction)updateGasType:(id)sender {
    _gas_type = [_gas_type_segment titleForSegmentAtIndex:_gas_type_segment.selectedSegmentIndex].lowercaseString;
    NSInteger index = _gas_type_segment.selectedSegmentIndex;
    _gas_index = index;
    [self calculateGas];
}

- (IBAction)infoButtonClicked:(id)sender {
    _infoView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:_infoView animated:YES completion:nil];
}


- (IBAction)peopleSliderChanged:(id)sender {
    _peopleLabel.text = [NSString stringWithFormat:@"%d", (int) _peopleSlider.value];
    _people = _peopleSlider.value;
    [self calculateCost];
}

- (IBAction)mpgSliderChanged:(id)sender {
    _mpgLabel.text = [NSString stringWithFormat:@"%d", (int) _mpgSlider.value];
    _mpg = _mpgSlider.value;
    [self calculateCost];
}

- (IBAction)roundtripSwitchChanged:(id)sender {
    if(_roundtripSwitch.on)
        _roundtrip = 2;
    else
        _roundtrip = 1;
    [self calculateCost];
}

- (void)calculateGas
{
    if(_start_placemarker.location.coordinate.latitude != 0)
    {
        _gas_type = [_gas_type_segment titleForSegmentAtIndex:_gas_type_segment.selectedSegmentIndex].lowercaseString;
        NSInteger index = _gas_type_segment.selectedSegmentIndex;
        _gas_index = index;
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.gasbro.com/gas.php?longitude=%f&latitude=%f&gas_type=%li", _start_placemarker.location.coordinate.longitude, _start_placemarker.location.coordinate.latitude, (long)_gas_index]];
        
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:
                            url];
            if(data != nil)
            {
                [self performSelectorOnMainThread:@selector(fetchedData:)
                                       withObject:data waitUntilDone:YES];
            }
            else
            {
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle:@"Network Error" message:@"No Connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //_startLocationText.text = @"Network Error";
                _price = 0;
                _gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", _price];
                [errorAlert show];
            }
        });
        
    }
}

- (void)calculateCost
{
    _total = (_price*_miles*_roundtrip)/_mpg;
    _cost = _total/_people;
    
    NSString *cost_string = [NSString stringWithFormat:@"$%0.2f", _cost];
    NSString *total_string = [NSString stringWithFormat:@"$%0.2f", _total];
    
    if([cost_string length] > 6) {
        // The source string is long enough to grab a substring of.
        _gasPerPersonLabel.text = [NSString stringWithFormat:@"$%0.0f", _cost];
    }
    else {
        // The source string is already less than fifty characters.
        _gasPerPersonLabel.text = [NSString stringWithFormat:@"$%0.2f", _cost];
    }
    
    if([total_string length] > 6){
        _gasTotalLabel.text = [NSString stringWithFormat:@"$%0.0f", _total];
    }
    else{
        
        _gasTotalLabel.text = [NSString stringWithFormat:@"$%0.2f", _total];
    }
}

- (void)getDirections
{
    MKDirectionsRequest *request =
    [[MKDirectionsRequest alloc] init];
    
    request.source = _start_mapitem;
    request.destination = _end_mapitem;
    
    request.requestsAlternateRoutes = NO;
    MKDirections *directions =
    [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle error
         } else {
             [self showRoute:response];
         }
     }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    _miles = 0;
    for (MKRoute *route in response.routes)
    {
        _miles += route.distance;
         
        [_mapView removeOverlays:[_mapView overlays]];
        [_mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
        
    }
    _miles = _miles/1609.34;
    NSLog(@"Miles:%f", _miles);
    [self zoomToCenter:_mapView withStart:_start_placemarker.location.coordinate withEnd:_end_placemarker.location.coordinate animated:YES];
    [self hidePanels];
    [self calculateCost];
}

- (void)zoomToCenter:(MKMapView *)mapView withStart:(CLLocationCoordinate2D)start withEnd:(CLLocationCoordinate2D)end animated:(BOOL)animate{
    CLLocationCoordinate2D locationCenter;
    MKCoordinateSpan locationSpan;
    int border = 2;
    
    locationCenter.longitude = ((start.longitude - end.longitude)/2 + end.longitude);
    locationCenter.latitude = ((start.latitude - end.latitude)/2 + end.latitude);
    locationSpan.longitudeDelta = fabsf(start.longitude - end.longitude)*border;
    locationSpan.latitudeDelta = fabsf(start.latitude - end.latitude)*border;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
    [mapView setRegion:region animated:animate];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView* aView = [[MKPolylineView alloc]initWithPolyline:(MKPolyline*)overlay] ;
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        aView.lineWidth = 10;
        return aView;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    // handle our three custom annotations
    //
    if ([annotation isKindOfClass:[GBStartAnnotation class]]) // for Golden Gate Bridge
    {
        // try to dequeue an existing pin view first
        static NSString *startAnnotationIdentifier = @"startPins";
        
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *) [theMapView dequeueReusableAnnotationViewWithIdentifier:startAnnotationIdentifier];
        if (pinView == nil)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView *startPinView = [[MKPinAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:startAnnotationIdentifier];
            startPinView.pinColor = MKPinAnnotationColorGreen;
            startPinView.animatesDrop = YES;
            startPinView.canShowCallout = YES;
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: when the detail disclosure button is tapped, we respond to it via:
            //       calloutAccessoryControlTapped delegate method
            //
            // by using "calloutAccessoryControlTapped", it's a convenient way to find out which annotation was tapped
            //
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            //startPinView.rightCalloutAccessoryView = rightButton;
            
            return startPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    else if ([annotation isKindOfClass:[GBEndAnnotation class]])   // for City of San Francisco
    {
        // try to dequeue an existing pin view first
        static NSString *endAnnotationIdentifier = @"endPins";
        
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *) [theMapView dequeueReusableAnnotationViewWithIdentifier:endAnnotationIdentifier];
        if (pinView == nil)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView *startPinView = [[MKPinAnnotationView alloc]
                                                 initWithAnnotation:annotation reuseIdentifier:endAnnotationIdentifier];
            startPinView.pinColor = MKPinAnnotationColorRed;
            startPinView.animatesDrop = YES;
            startPinView.canShowCallout = YES;
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: when the detail disclosure button is tapped, we respond to it via:
            //       calloutAccessoryControlTapped delegate method
            //
            // by using "calloutAccessoryControlTapped", it's a convenient way to find out which annotation was tapped
            //
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            //startPinView.rightCalloutAccessoryView = rightButton;
            
            return startPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    
    return nil;
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    
    NSArray* gasStations = [json objectForKey:@"stations"]; //2
    
    NSLog(@"stations: %@", gasStations); //3
    
    // 1) Get the first gas station
    if(gasStations == nil || [gasStations count] == 0)
    {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"No Gas Stations Nearby" message:@"Try typing in the nearest U.S. city" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        _startLocationText.text = @"Location Error";
        [currentLocationButton setSelected:NO];

        _price = 0;
        _gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", _price];
        [errorAlert show];
    }
    else
    {
        int j=0;
        NSNumber* price = 0;
        _price = 0;
        while(_price == 0 && j<[gasStations count])
        {
            NSDictionary* station = [gasStations objectAtIndex:j];
            
            // 2) Get the funded amount and loan amount
            price = [station objectForKey:@"price"];
            _city = [station objectForKey:@"city"];
            _price =    [price floatValue];
            j++;
        }
        
        // 3) Set the label appropriately
        //humanReadble.text = [NSString stringWithFormat:@"The Cost of gas in %@ is $%0.2f",
        //                     _city,
        //                     _price];
        _gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", _price];
        
        [self calculateCost];
        
    }
    
    if ([_startLocationText.text  isEqual: @"Locating..."])
    {
        _startLocationText.text = _city;
        _startLocationText.clearsOnBeginEditing = NO;
    }
    
    [currentLocationButton setSelected:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) unwindToMain:(UIStoryboardSegue *)segue{
    //nothing
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //[self calculateGas];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    [manager stopUpdatingLocation];
    _startLocationText.text = @"Location Error";
    [currentLocationButton setSelected:NO];
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Location Error" message:@"Failed to Get Your Location. Make sure Location services are enabled in Settings>Privacy>Location Services" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    
    [errorAlert show];
    _startLocationText.clearsOnBeginEditing = YES;
}

-(void)saveData
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:_gas_index forKey:@"gas_index"];
    [defaults setInteger:_people forKey:@"people"];
    [defaults setInteger:_mpg forKey:@"mpg"];
    [defaults synchronize];
}

-(void)loadData
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"mpg"])
    {
        _people = [(NSNumber *)[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"people"] intValue];
        
        _mpg = [(NSNumber *)[[NSUserDefaults standardUserDefaults]
                             objectForKey:@"mpg"] intValue];
        
        _gas_index = [(NSNumber *)[[NSUserDefaults standardUserDefaults]
                                   objectForKey:@"gas_index"] intValue];
    }
}

@end
