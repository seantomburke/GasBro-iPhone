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
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAILogger.h"
#import "GAIDictionaryBuilder.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@interface GBViewController (){
    CLLocationManager *locationManager;
    
}

@end

@implementation GBViewController{}

@synthesize price;
@synthesize gas_type;
@synthesize share_text;
@synthesize city;
@synthesize gas_index;
@synthesize cost;
@synthesize total;
@synthesize miles;
@synthesize start_placemarker;
@synthesize end_placemarker;

@synthesize people;
@synthesize mpg;
@synthesize roundtrip;

@synthesize peopleLabel;
@synthesize mpgLabel;
@synthesize peopleSlider;
@synthesize mpgSlider;
@synthesize gasPriceLabel;
@synthesize gasTotalLabel;
@synthesize gasPerPersonLabel;
@synthesize startLocationText;
@synthesize endLocationText;
@synthesize roundtripSwitch;

@synthesize currentLocationButton;
@synthesize routeMap;
@synthesize end_mapitem;
@synthesize start_mapitem;
@synthesize gas_type_segment;
@synthesize infoView;

@synthesize topView;
@synthesize bottomView;
@synthesize mapView;
@synthesize cache;

@synthesize start_annotation;
@synthesize end_annotation;




- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Home Screen";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.topView.opaque = NO;
    self.bottomView.opaque = NO;
    [mapView setDelegate:self];
    
    //map stufff
    
	// Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    gas_type = [defaults objectForKey:@"gasType"];
    mpg = [defaults doubleForKey:@"mpg"];
    
    locationManager = [[CLLocationManager alloc] init];
    [self peopleSliderChanged:(self)];
    [self roundtripSwitchChanged:(self)];
    [self mpgSliderChanged:(self)];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    endLocationText.delegate = self;
    startLocationText.delegate = self;
    
    UITapGestureRecognizer *maptap = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self
                                      action:@selector(hidePanels)];
    
    [mapView addGestureRecognizer:maptap];
    
    UITapGestureRecognizer *nonmaptaptop = [[UITapGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(showPanels)];
    
    [topView addGestureRecognizer:nonmaptaptop];
    
    UITapGestureRecognizer *nonmaptapbottom = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(showPanels)];
    
    [bottomView addGestureRecognizer:nonmaptapbottom];
    
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(void)hidePanels {
    [self dismissKeyboard];
    [UIView animateWithDuration:.25
                     animations:^{
                         topView.frame = CGRectMake(0, -100, topView.bounds.size.width, topView.bounds.size.height);
                         bottomView.frame = CGRectMake(0, self.view.bounds.size.height - bottomView.bounds.size.height + 100, bottomView.bounds.size.width, bottomView.bounds.size.height);// its final location
                     }];
}


-(void)showPanels {
    
    [self dismissKeyboard];
    [UIView animateWithDuration:.25
                     animations:^{
                         topView.frame = CGRectMake(0, 0, topView.bounds.size.width, topView.bounds.size.height);// its final location
                     }];
    [UIView animateWithDuration:.25
                     animations:^{
                         bottomView.frame = CGRectMake(0, self.view.bounds.size.height - bottomView.bounds.size.height, bottomView.bounds.size.width, bottomView.bounds.size.height);// its final location
                     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Any additional checks to ensure you have the correct textField here.
    if(textField == startLocationText)
    {
        [self startSearch:textField withError:true];
        [endLocationText becomeFirstResponder];
    }
    else
    {
        [self endSearch:textField withError:true];
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)dismissKeyboard {
    [startLocationText resignFirstResponder];
    [endLocationText resignFirstResponder];
}
-(void)startSearch:(UITextField*)sender withError:(BOOL)showError{
    if(![sender.text isEqualToString:@""])
    {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:[GAIFields customDimensionForIndex:1] value:sender.text];
        [tracker set:kGAIScreenName value:@"Home screen"];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"start_text"
                                                          forKey:[GAIFields customDimensionForIndex:1]] build]];
        
        startLocationText.clearsOnBeginEditing = NO;
        CLGeocoder *startgeocoder = [[CLGeocoder alloc] init];
        [startgeocoder geocodeAddressString:sender.text completionHandler:^(NSArray *startplacemarks, NSError *error)
         {
             if (error) {
                 NSLog(@"%@", error);
                 UIAlertView *errorAlert = [[UIAlertView alloc]
                                            initWithTitle:[NSString stringWithFormat:@"%@ not found", sender.text] message:@"Please check for spelling errors and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 //startLocationText.text = @"Network Error";
                 price = 0;
                 gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", price];
                 if(showError)
                     [errorAlert show];
                 
             } else {
                 start_placemarker = [startplacemarks lastObject];
                 if(![start_placemarker.country  isEqual: @"United States"])
                 {
                     NSLog(@"%@", error);
                     UIAlertView *errorAlert = [[UIAlertView alloc]
                                                initWithTitle:@"Country Error" message:@"Gas Bro currently only works in the U.S. Please choose a location within the U.S." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     //startLocationText.text = @"Network Error";
                     price = 0;
                     gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", price];
                     if(showError)
                         [errorAlert show];
                 }
                 else
                 {
                     
                     start_mapitem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:start_placemarker]];
                     MKPlacemark *s = start_placemarker;
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
                     if(![addr isEqual: @""])
                     {
                         startLocationText.text = addr;
                         [tracker set:[GAIFields customDimensionForIndex:1] value:startLocationText.text];
                         [tracker set:kGAIScreenName value:@"Home screen"];
                         [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"start_addr"
                                                                           forKey:[GAIFields customDimensionForIndex:1]] build]];
                     }
                     [mapView removeAnnotation:start_annotation];
                     start_annotation = [[GBStartAnnotation alloc] init];
                     [start_annotation setColor:MKPinAnnotationColorGreen];
                     float spanX = 1.00725;
                     float spanY = 1.00725;
                     MKCoordinateRegion region;
                     region.span = MKCoordinateSpanMake(spanX, spanY);
                     region.center = start_placemarker.location.coordinate;
                     [mapView setRegion:region animated:YES];
                     NSLog(@"long:%f,lat:%f", start_placemarker.location.coordinate.latitude,start_placemarker.location.coordinate.longitude);
                      [start_annotation setCoordinate:start_placemarker.location.coordinate];
                      [start_annotation setTitle:@"Start Location"];
                      [start_annotation setSubtitle:addr];
                      [mapView addAnnotation:start_annotation];
                      [mapView selectAnnotation:start_annotation animated:YES];
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
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:[GAIFields customDimensionForIndex:1] value:sender.text];
        [tracker set:kGAIScreenName value:@"Home screen"];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"end_text"
                                                          forKey:[GAIFields customDimensionForIndex:1]] build]];
        CLGeocoder *endgeocoder = [[CLGeocoder alloc] init];
        [endgeocoder geocodeAddressString:sender.text completionHandler:^(NSArray *endplacemarks, NSError *error) {
            if (error && showError) {
                NSLog(@"%@", error);
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle:[NSString stringWithFormat:@"%@ not found", sender.text] message:@"Please check for spelling errors and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //_startLocationText.text = @"Network Error";
                //_price = 0;
                //_gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f",price];
                if(showError)
                    [errorAlert show];
            } else {
                end_placemarker = [endplacemarks lastObject];
                if(! [end_placemarker.country  isEqual: @"United States"] && showError)
                {
                    NSLog(@"%@", error);
                    UIAlertView *errorAlert = [[UIAlertView alloc]
                                               initWithTitle:@"Country Error" message:@"Please choose a location within the U.S." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    //_startLocationText.text = @"Network Error";
                    //_price = 0;
                    //_gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", price];
                    if(showError)
                        [errorAlert show];
                }
                else
                {
                    end_mapitem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:end_placemarker]];
                    MKPlacemark *s = end_placemarker;
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
                    
                     [mapView removeAnnotation:end_annotation];
                    end_annotation = [[GBEndAnnotation alloc] init];
                    
                    if(![addr isEqual:@""])
                    {
                         [endLocationText setText:addr];
                         [end_annotation setSubtitle:addr];
                        id tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker set:[GAIFields customDimensionForIndex:1] value:endLocationText.text];
                        [tracker set:kGAIScreenName value:@"Home screen"];
                        [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"end_addr"
                                                                          forKey:[GAIFields customDimensionForIndex:1]] build]];
                    }
                    
                     [end_annotation setTitle:@"Destination"];
                    
                    float spanX = 1.00725;
                    float spanY = 1.00725;
                    MKCoordinateRegion region;
                    region.span = MKCoordinateSpanMake(spanX, spanY);
                    NSLog(@"long:%f,lat:%f", end_placemarker.location.coordinate.latitude,end_placemarker.location.coordinate.longitude);
                    [self getDirections];
                     [end_annotation setColor:MKPinAnnotationColorRed];
                     [end_annotation setCoordinate:end_placemarker.location.coordinate];
                     [mapView addAnnotation:end_annotation];
                     [end_annotation setSubtitle:addr];
                     [mapView selectAnnotation:end_annotation animated:YES];
                }
            }
        }];
    }
}

- (IBAction)endSearch:(UITextField *)sender {
    [self endSearch:sender withError:false];
}

- (IBAction)getCurrentLocation:(id)sender {
    
    [startLocationText setText:@"Locating..."];
    [currentLocationButton setSelected:YES];
    startLocationText.clearsOnBeginEditing = YES;
    mapView.showsUserLocation = YES;
    [mapView setShowsUserLocation:YES];
    [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
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
                    startLocationText.text = @"Network Error";
                    price = 0;
                    gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", price];
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
                    startLocationText.text = addr;
                    [currentLocationButton setSelected:NO];
                    mapView.userLocation.subtitle = addr;
                    
                    [mapView selectAnnotation:mapView.userLocation animated:YES];
                }
            }];
        }
        else
        {
            if(! [startLocationText isEditing])
            {
                 [startLocationText setText:@"Location Error"];

                [currentLocationButton setSelected:NO];
            startLocationText.clearsOnBeginEditing = YES;
            }
        }
        
        start_placemarker = [[MKPlacemark alloc] initWithCoordinate:locationManager.location.coordinate addressDictionary:NULL];
        start_mapitem = [MKMapItem mapItemForCurrentLocation];
        
        [locationManager stopUpdatingLocation];
        
        [self calculateGas];
    });
    
    
    
}

- (IBAction)updateGasType:(id)sender {
    gas_type =  [gas_type_segment titleForSegmentAtIndex:gas_type_segment.selectedSegmentIndex].lowercaseString;
    NSInteger index = gas_type_segment.selectedSegmentIndex;
    gas_index = index;
    [self calculateGas];
}

- (IBAction)infoButtonClicked:(id)sender {
    infoView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:infoView animated:YES completion:nil];
}


- (IBAction)peopleSliderChanged:(id)sender {
    peopleLabel.text = [NSString stringWithFormat:@"%d", (int) peopleSlider.value];
    people = peopleSlider.value;
    [self calculateCost];
}

- (IBAction)mpgSliderChanged:(id)sender {
    mpgLabel.text = [NSString stringWithFormat:@"%d", (int) mpgSlider.value];
    mpg = mpgSlider.value;
    [self calculateCost];
}

- (IBAction)roundtripSwitchChanged:(id)sender {
    if(roundtripSwitch.on)
        roundtrip = 2;
    else
        roundtrip = 1;
    [self calculateCost];
}

- (void)calculateGas
{
    if(start_placemarker.location.coordinate.latitude != 0)
    {
        gas_type =  [gas_type_segment titleForSegmentAtIndex:gas_type_segment.selectedSegmentIndex].lowercaseString;
        NSInteger index = gas_type_segment.selectedSegmentIndex;
        gas_index = index;
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.gasbro.com/gas.php?longitude=%f&latitude=%f&gas_type=%li", start_placemarker.location.coordinate.longitude, start_placemarker.location.coordinate.latitude, (long)gas_index]];
        
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
                price = 0;
                gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", price];
                [errorAlert show];
            }
        });
        
    }
}

- (void)calculateCost
{
    total = (price*miles*roundtrip)/mpg;
    cost = total/people;
    
    NSString *cost_string = [NSString stringWithFormat:@"$%0.2f", cost];
    NSString *total_string = [NSString stringWithFormat:@"$%0.2f", total];
    
    if([cost_string length] > 6) {
        // The source string is long enough to grab a substring of.
        gasPerPersonLabel.text = [NSString stringWithFormat:@"$%0.0f", cost];
    }
    else {
        // The source string is already less than fifty characters.
        gasPerPersonLabel.text = [NSString stringWithFormat:@"$%0.2f", cost];
    }
    
    if([total_string length] > 6){
        gasTotalLabel.text = [NSString stringWithFormat:@"$%0.0f", total];
    }
    else{
        
        gasTotalLabel.text = [NSString stringWithFormat:@"$%0.2f", total];
    }
}

- (void)getDirections
{
    MKDirectionsRequest *request =
    [[MKDirectionsRequest alloc] init];
    
    request.source = start_mapitem;
    request.destination = end_mapitem;
    
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
    miles = 0;
    for (MKRoute *route in response.routes)
    {
        miles += route.distance;
         
         [mapView removeOverlays: [mapView overlays]];
         [mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
        
    }
    miles = miles/1609.34;
    NSLog(@"Miles:%f", miles);
    [self zoomToCenter:mapView withStart:start_placemarker.location.coordinate withEnd:end_placemarker.location.coordinate animated:YES];
    [self hidePanels];
    [self calculateCost];
}

- (void)zoomToCenter:(MKMapView *)map withStart:(CLLocationCoordinate2D)start withEnd:(CLLocationCoordinate2D)end animated:(BOOL)animate{
    CLLocationCoordinate2D locationCenter;
    MKCoordinateSpan locationSpan;
    int border = 2;
    
    locationCenter.longitude = ((start.longitude - end.longitude)/2 + end.longitude);
    locationCenter.latitude = ((start.latitude - end.latitude)/2 + end.latitude);
    locationSpan.longitudeDelta = fabsf(start.longitude - end.longitude)*border;
    locationSpan.latitudeDelta = fabsf(start.latitude - end.latitude)*border;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
    [map setRegion:region animated:animate];
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
        startLocationText.text = @"Location Error";
        [currentLocationButton setSelected:NO];

        price = 0;
        gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", price];
        [errorAlert show];
    }
    else
    {
        int j=0;
        NSNumber* temp_price = 0;
        price = 0;
        while(temp_price == 0 && j<[gasStations count])
        {
            NSDictionary* station = [gasStations objectAtIndex:j];
            
            // 2) Get the funded amount and loan amount
            temp_price = [station objectForKey:@"price"];
            city = [station objectForKey:@"city"];
            price = [temp_price floatValue];
            j++;
        }
        
        // 3) Set the label appropriately
        //humanReadble.text = [NSString stringWithFormat:@"The Cost of gas in %@ is $%0.2f",
        //                     city,
        //                     price];
        gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", price];
        
        [self calculateCost];
        
    }
    
    if ( [startLocationText.text  isEqual: @"Locating..."])
    {
        startLocationText.text = city;
        startLocationText.clearsOnBeginEditing = NO;
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
    startLocationText.text = @"Location Error";
    [currentLocationButton setSelected:NO];
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Location Error" message:@"Failed to Get Your Location. Make sure Location services are enabled in Settings>Privacy>Location Services" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    
    [errorAlert show];
    startLocationText.clearsOnBeginEditing = YES;
}

-(void)saveData
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:gas_index forKey:@"gas_index"];
    [defaults setInteger:people forKey:@"people"];
    [defaults setInteger:mpg forKey:@"mpg"];
    [defaults synchronize];
}

-(void)loadData
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"mpg"])
    {
        people = [(NSNumber *)[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"people"] intValue];
        
        mpg = [(NSNumber *)[[NSUserDefaults standardUserDefaults]
                             objectForKey:@"mpg"] intValue];
        
        gas_index = [(NSNumber *)[[NSUserDefaults standardUserDefaults]
                                   objectForKey:@"gas_index"] intValue];
    }
}

@end
