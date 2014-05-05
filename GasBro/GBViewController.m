//
//  GBViewController.m
//  GasBro
//
//  Created by Sean Thomas Burke on 9/26/13.
//  Copyright (c) 2013 Nyquist Labs. All rights reserved.
//

#import "GBViewController.h"
#import "GBCache.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.topView.opaque = NO;
    self.bottomView.opaque = NO;
    
    //map stufff
    [_mapView setDelegate:self];
    //_mapView.showsUserLocation = YES;
    //[_mapView setShowsUserLocation:YES];
    //[_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];

	// Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _gas_type = [defaults objectForKey:@"gasType"];
    _mpg = [defaults doubleForKey:@"mpg"];
    
    locationManager = [[CLLocationManager alloc] init];
    [self peopleSliderChanged:(self)];
    [self roundtripSwitchChanged:(self)];
    [self mpgSliderChanged:(self)];
    
    
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

-(void)hidePanels {
    [self dismissKeyboard];
    [UIView animateWithDuration:.25
                     animations:^{
                         _topView.frame = CGRectMake(0, -100, _topView.bounds.size.width, _topView.bounds.size.height);// its final location
                     }];
    [UIView animateWithDuration:.25
                     animations:^{
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
        [self startSearch:textField];
        [_endLocationText becomeFirstResponder];
    }
    else
    {
        [self endSearch:textField];
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)dismissKeyboard {
    [_startLocationText resignFirstResponder];
    [_endLocationText resignFirstResponder];
}

- (IBAction)startSearch:(UITextField *)sender {
    CLGeocoder *startgeocoder = [[CLGeocoder alloc] init];
    [startgeocoder geocodeAddressString:sender.text completionHandler:^(NSArray *startplacemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            _start_placemarker = [startplacemarks lastObject];
            _start_mapitem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:_start_placemarker]];
            float spanX = 1.00725;
            float spanY = 1.00725;
            MKCoordinateRegion region;
            region.span = MKCoordinateSpanMake(spanX, spanY);
            region.center = _start_placemarker.location.coordinate;
            [_mapView setRegion:region animated:YES];
            NSLog(@"long:%f,lat:%f", _start_placemarker.location.coordinate.latitude,_start_placemarker.location.coordinate.longitude);
            MKPointAnnotation  *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = _start_placemarker.location.coordinate;
            [_mapView addAnnotation:annotation];
            [self calculateGas];
        }
    }];
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

- (IBAction)endSearch:(UITextField *)sender {
    CLGeocoder *endgeocoder = [[CLGeocoder alloc] init];
    [endgeocoder geocodeAddressString:sender.text completionHandler:^(NSArray *endplacemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            _end_placemarker = [endplacemarks lastObject];
            _end_mapitem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:_end_placemarker]];
            float spanX = 1.00725;
            float spanY = 1.00725;
            MKCoordinateRegion region;
            region.span = MKCoordinateSpanMake(spanX, spanY);
            NSLog(@"long:%f,lat:%f", _end_placemarker.location.coordinate.latitude,_end_placemarker.location.coordinate.longitude);
            [self getDirections];
            MKPointAnnotation  *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = _end_placemarker.location.coordinate;
            [_mapView addAnnotation:annotation];
        }
    }];
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
                _startLocationText.text = @"Network Error";
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
        
        [_mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
        
    }
    _miles = _miles/1609.34;
    NSLog(@"Miles:%f", _miles);
    MKCoordinateRegion region = [self zoomToCenter:_mapView withStart:_start_placemarker.location.coordinate withEnd:_end_placemarker.location.coordinate];
    NSLog([NSString stringWithFormat:@"long: %f long: %f", _start_placemarker.location.coordinate.longitude, _end_placemarker.location.coordinate.longitude]);
    NSLog([NSString stringWithFormat:@"lat: %f lat: %f", _start_placemarker.location.coordinate.latitude, _end_placemarker.location.coordinate.latitude]);
    NSLog([NSString stringWithFormat:@"long: %f lat: %f", region.center.longitude, region.center.latitude]);
    [_mapView setRegion:region animated:YES];
    [self calculateCost];
}

- (MKCoordinateRegion)zoomToCenter:(MKMapView *)mapView withStart:(CLLocationCoordinate2D)start withEnd:(CLLocationCoordinate2D)end {
    CLLocationCoordinate2D locationCenter;
    MKCoordinateSpan locationSpan;
    float border = 2;
    if(start.longitude > end.longitude)
    {
        locationCenter.longitude = ((start.longitude - end.longitude)/2 + end.longitude);
        locationSpan.longitudeDelta = (start.longitude - end.longitude)*border;
    }
    else
    {
        locationCenter.longitude = ((end.longitude - start.longitude)/2 + start.longitude);
        locationSpan.longitudeDelta = (end.longitude - start.longitude)*border;
    }
    
    if(start.latitude > end.latitude)
    {
        locationCenter.latitude = ((start.latitude - end.latitude)/2 + end.latitude);
        locationSpan.latitudeDelta = (start.latitude - end.latitude)*border;
    }
    else
    {
        locationCenter.latitude = ((end.latitude - start.latitude)/2 + start.latitude);
        locationSpan.latitudeDelta = (end.latitude - start.latitude)*border;
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
    return region;
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

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
        } else {
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
                                   initWithTitle:@"No Gas Stations Found" message:@"Try typing in a nearby U.S. city" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        _startLocationText.text = @"Location Error";
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
    
    [_mapView setShowsUserLocation:YES];
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    
    if ([_startLocationText.text  isEqual: @"Locating..."])
    {
        _startLocationText.text = _city;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getCurrentLocation:(id)sender {
    
    [_startLocationText setText:@"Locating..."];
    dispatch_async(kBgQueue, ^{
        
        _start_mapitem = nil;
        
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
        _start_placemarker = [[MKPlacemark alloc] initWithCoordinate:locationManager.location.coordinate addressDictionary:NULL];
        _start_mapitem = [MKMapItem mapItemForCurrentLocation];
        MKPointAnnotation  *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = _start_placemarker.location.coordinate;
        [_mapView addAnnotation:annotation];
        [locationManager stopUpdatingLocation];
        [self calculateGas];
    });
    
    
    
}


- (IBAction) unwindToMain:(UIStoryboardSegue *)segue{
    //nothing
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //[self calculateGas];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    _startLocationText.text = @"Error Try Again";
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location. Make sure Location services are enabled in Settings>Privacy>Location Services" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    
    [errorAlert show];
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
