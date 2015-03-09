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
#import <Parse/Parse.h>
#import <AddressBook/AddressBook.h>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@implementation GBViewController{
    id<GAITracker> tracker;
}

CLLocationManager *locationManager;

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
@synthesize parseTripId;
@synthesize endLocationText;
@synthesize roundtripSwitch;

@synthesize currentLocationButton;
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

double topPos;
double topHeight;
double bottomPos;
double bottomHeight;
int counter;

UITapGestureRecognizer *maptap;
UITapGestureRecognizer *nonmaptaptop;
UITapGestureRecognizer *nonmaptapbottom;
UIPanGestureRecognizer *panGestureRecognizer;

- (void)viewWillAppear:(BOOL)animated {
    self.screenName = @"Home Screen";
    tracker = [[GAI sharedInstance] defaultTracker];
    
    
    
    topHeight = topView.frame.size.height;
    topPos = topView.frame.origin.y;
    bottomHeight = bottomView.frame.size.height;
    bottomPos = self.view.frame.size.height - bottomHeight;
}

- (void)viewDidLoad
{
    gasPriceLabel.userInteractionEnabled = YES;
    [self.view setClearsContextBeforeDrawing:NO];
    
    for (UIView *t in self.view.subviews) {
        t.userInteractionEnabled = YES;
    }
    
    self.topView.opaque = NO;
    self.bottomView.opaque = NO;
    [mapView setDelegate:self];
    
    //map stufff
    
    // Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    gas_type = [defaults objectForKey:@"gasType"];
    mpg = [defaults doubleForKey:@"mpg"];
    
    [self loadData];
    
    locationManager = [[CLLocationManager alloc] init];
    [self peopleSliderChanged:(self)];
    [self roundtripSwitchChanged:(self)];
    [self mpgSliderChanged:(self)];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    endLocationText.delegate = self;
    startLocationText.delegate = self;
    
    maptap = [[UITapGestureRecognizer alloc]
              initWithTarget:self
              action:@selector(mapHandler:)];
    
    nonmaptaptop = [[UITapGestureRecognizer alloc]
                    initWithTarget:self
                    action:@selector(topHandler:)];
    
    nonmaptapbottom = [[UITapGestureRecognizer alloc]
                       initWithTarget:self
                       action:@selector(bottomHandler:)];
    
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(moveViewWithGestureRecognizer:)];
    
    [mapView addGestureRecognizer:maptap];
    
    [topView addGestureRecognizer:nonmaptaptop];
    
    [bottomView addGestureRecognizer:nonmaptapbottom];
    [gasPriceLabel addGestureRecognizer:panGestureRecognizer];
}


-(void)hidePanels {
    [self dismissKeyboard];
    
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UI"
                    action:@"hidePanels"
                    label:@"Panels Hidden"
                    value:nil] build]];
    NSDictionary *dimensions = @{
                                 @"category": @"UI",
                                 @"action": @"hidePanels",
                                 };
    [PFAnalytics trackEvent:@"hidePanels" dimensions:dimensions];
    
    [UIView animateWithDuration:.25
                     animations:^{
                         topView.bounds = CGRectMake(0, +100, topView.frame.size.width, topView.frame.size.height);// its final location
                         bottomView.bounds = CGRectMake(0, -100, bottomView.frame.size.width, bottomView.frame.size.height);// its final location
                         
                         //                         topView.frame = CGRectMake(0, -100, topView.frame.size.width, topView.frame.size.height);
                         //                         bottomView.frame = CGRectMake(0, self.view.frame.size.height - bottomView.frame.size.height, bottomView.frame.size.width + 100, bottomView.frame.size.height - 100);
                         //
                         //bottomView.alpha = .7;
                         //topView.alpha = .8;
                     }];
}



-(void)showPanels {
    [self dismissKeyboard];
    counter++;
    NSLog(@"%i", counter);
    
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UI"
                    action:@"showPanels"
                    label:@"Panels Hidden"
                    value:nil] build]];
    [UIView animateWithDuration:.25
                     animations:^{
                         topView.bounds = CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height);// its final location
                         bottomView.bounds = CGRectMake(0, 0, bottomView.frame.size.width, bottomView.frame.size.height);// its final location
                         
                         
                         //                         topView.frame = CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height);
                         //                         bottomView.frame = CGRectMake(0, self.view.frame.size.height - bottomView.frame.size.height, bottomView.frame.size.width, bottomView.frame.size.height);
                         //                         //bottomView.alpha = .90;
                         //topView.alpha = .90;
                     }];
}


-(void)topHandler:(UITapGestureRecognizer *)tapGestureRecognizer{
    CGPoint point = [tapGestureRecognizer locationInView:gasPriceLabel];
    NSLog(@"top tapped: %f, %f",point.x, point.y);
    [self showPanels];
}

-(void)bottomHandler:(UITapGestureRecognizer *)tapGestureRecognizer{
    CGPoint location = [tapGestureRecognizer locationInView:topView];
    NSLog(@"bottom tapped: %f, %f",location.x, location.y);
    [self showPanels];
}

-(void)mapHandler:(UITapGestureRecognizer *)tapGestureRecognizer{
    CGPoint location = [tapGestureRecognizer locationInView:topView];
    NSLog(@"map tapped: %f, %f",location.x, location.y);
    [self hidePanels];
}

-(void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer{
    //CGPoint touchLocation = [panGestureRecognizer locationInView:self.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    
    price -= velocity.y*.0001;
    
    price = roundf(price*100.0)/100.0;
    
    if(price < .01){
        price = 0;
        
    }
    gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", price];
    [self calculateCost];
    
}

-(void)updateView:(NSString *)tripId{
    
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Any additional checks to ensure you have the correct textField here.
    if(textField == startLocationText)
    {
        [self startSearchHandler:textField withError:YES];
        [endLocationText becomeFirstResponder];
    }
    else if(textField == endLocationText)
    {
        [self endSearchHandler:textField withError:YES];
        [self hidePanels];
    }
    else if(textField == parseTripId)
    {
        [self getTrip:parseTripId.text];
    }
    return YES;
}

-(void)dismissKeyboard {
    [startLocationText resignFirstResponder];
    [endLocationText resignFirstResponder];
}

-(void)alert:(NSString*)title withMessage:(NSString*)message withButton:(NSString*)button
{
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"Error"
                    action:title
                    label:message
                    value:nil] build]];
    
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:title
                               message:message
                               delegate:nil
                               cancelButtonTitle:button
                               otherButtonTitles:nil];
    [errorAlert show];
}
-(void)startSearchHandler:(UITextField*)sender withError:(BOOL)showError{
    if(![sender.text isEqualToString:@""])
    {
        
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"Location"
                        action:@"Start Search Field"
                        label:sender.text
                        value:0] build]];
        
        startLocationText.clearsOnBeginEditing = NO;
        CLGeocoder *startgeocoder = [[CLGeocoder alloc] init];
        [startgeocoder geocodeAddressString:sender.text completionHandler:^(NSArray *startplacemarks, NSError *error)
         {
             
             if (error) {
                 NSLog(@"%@", error.debugDescription);
                 NSString *title;
                 NSString *message;
                 NSString *button;
                 if(error.code == 2)
                 {
                     title = [NSString stringWithFormat:@"%@", @"Too many requests"];
                     message = @"Try waiting a few mintues, Apple blocks multiple map geolocation requests in a short time period.";
                     button = @"OK";
                 }
                 else if(error.code == 8){
                     title = [NSString stringWithFormat:@"%@ not found", sender.text];
                     message = @"Please check for spelling errors and try again";
                     button = @"OK";
                 }
                 else{
                     title = [NSString stringWithFormat:@"%@", error.domain];
                     message = error.description;
                     button = @"OK";
                 }
                 price = 0;
                 gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", price];
                 if(showError)
                     [self alert:title withMessage:message withButton:button];
                 
             } else {
                 start_placemarker = [startplacemarks lastObject];
                 if(![start_placemarker.country  isEqual: @"United States"])
                 {
                     NSLog(@"%@", error.debugDescription);
                     NSString *title = @"Country Error";
                     NSString *message = @"Gas Bro currently only works in the U.S. Please choose a location within the U.S.";
                     NSString *button = @"OK";
                     price = 0;
                     gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", price];
                     if(showError){
                         [self alert:title withMessage:message withButton:button];
                     }
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
                         [tracker send:[[GAIDictionaryBuilder
                                         createEventWithCategory:@"Location"
                                         action:@"Start Address Geocoded"
                                         label:addr
                                         value:nil] build]];
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
                     //center map
                     [mapView selectAnnotation:start_annotation animated:YES];
                     [self zoomToCenter:mapView withStart:start_annotation.coordinate withEnd:start_annotation.coordinate animated:YES];
                     [self calculateGas];
                 }
             }
         }];
    }
    
}

- (void)endSearchHandler:(UITextField *)sender withError:(BOOL)showError{
    if(![sender.text isEqualToString:@""])
    {
        //        [tracker send:[[GAIDictionaryBuilder
        //                        createEventWithCategory:@"Location"
        //                        action:@"End Address Field"
        //                        label:sender.text
        //                        value:nil] build]];
        CLGeocoder *endgeocoder = [[CLGeocoder alloc] init];
        [endgeocoder geocodeAddressString:sender.text completionHandler:^(NSArray *endplacemarks, NSError *error) {
            if (error && showError) {
                NSLog(@"%@", error.debugDescription);
                NSString *title;
                NSString *message;
                NSString *button;
                if(error.code == 2)
                {
                    title = [NSString stringWithFormat:@"%@", @"Too many requests"];
                    message = @"Try waiting a few mintues, Apple blocks multiple map geolocation requests in a short time period.";
                    button = @"OK";
                }
                else if(error.code == 8){
                    title = [NSString stringWithFormat:@"%@ not found", sender.text];
                    message = @"Please check for spelling errors and try again";
                    button = @"OK";
                }
                else{
                    title = [NSString stringWithFormat:@"%@", error.domain];
                    message = error.description;
                    button = @"OK";
                }
                //_startLocationText.text = @"Network Error";
                //_price = 0;
                //_gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f",price];
                if(showError){
                    [self alert:title withMessage:message withButton:button];
                }
            } else {
                end_placemarker = [endplacemarks lastObject];
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
                    [tracker send:[[GAIDictionaryBuilder
                                    createEventWithCategory:@"Location"
                                    action:@"End Location Geocoded"
                                    label:addr
                                    value:nil] build]];
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
                //[mapView selectAnnotation:end_annotation animated:YES];
            }
        }];
    }
}

- (IBAction)getCurrentLocation:(id)sender {
    
    [locationManager requestWhenInUseAuthorization];
    [startLocationText setText:@"Locating..."];
    [currentLocationButton setSelected:YES];
    startLocationText.clearsOnBeginEditing = YES;
    mapView.showsUserLocation = YES;
    [mapView setShowsUserLocation:YES];
    //[mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
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
                    NSLog(@"%@", error.debugDescription);
                    NSString *title = @"Current Location Failed" ;
                    NSString *message = @"Could not find Current Location" ;
                    NSString *button = @"OK";
                    startLocationText.text = @"Network Error";
                    price = 0;
                    gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", price];
                    [self alert:title withMessage:message withButton:button];
                    
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
                    
                    
                    [tracker send:[[GAIDictionaryBuilder
                                    createEventWithCategory:@"Location"
                                    action:@"Getting Current Location"
                                    label:addr
                                    value:nil] build]];
                    
                    [mapView selectAnnotation:mapView.userLocation animated:YES];
                    [self zoomToCenter:mapView withStart:locationManager.location.coordinate withEnd:locationManager.location.coordinate animated:YES];
                    
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
        
        
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *point, NSError *error){
            [[PFUser currentUser] setObject:point forKey:@"Location"];
            [[PFUser currentUser] saveInBackground];
        }];
        
        [self calculateGas];
    });
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"Location"
                    action:@"Current Location Clicked"
                    label:locationManager.location.description
                    value:nil] build]];
    
    
}

- (IBAction)updateGasType:(id)sender {
    gas_type =  [gas_type_segment titleForSegmentAtIndex:gas_type_segment.selectedSegmentIndex].lowercaseString;
    NSInteger index = gas_type_segment.selectedSegmentIndex;
    
    gas_index = index;
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UI"
                    action:@"Gas Type Segment Changed"
                    label:gas_type
                    value:[NSNumber numberWithFloat:gas_index]] build]];
    [self calculateGas];
}

- (IBAction)infoButtonClicked:(id)sender {
    infoView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UI"
                    action:@"Page Navigation"
                    label:@"To Info Page"
                    value:nil] build]];
    [self presentViewController:infoView animated:YES completion:nil];
}


- (IBAction)peopleSliderChanged:(id)sender {
    peopleLabel.text = [NSString stringWithFormat:@"%d", (int) peopleSlider.value];
    people = peopleSlider.value;
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UI"
                    action:@"People Slider Changed"
                    label:[NSString stringWithFormat:@"%f", peopleSlider.value]
                    value:[NSNumber numberWithFloat:peopleSlider.value]] build]];
    [self calculateCost];
}

- (IBAction)mpgSliderChanged:(id)sender {
    mpgLabel.text = [NSString stringWithFormat:@"%d", (int) mpgSlider.value];
    mpg = mpgSlider.value;
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UI"
                    action:@"MPG Slider Changed"
                    label:[NSString stringWithFormat:@"%f", mpgSlider.value]
                    value:[NSNumber numberWithFloat:mpgSlider.value]] build]];
    [self calculateCost];
}

- (IBAction)roundtripSwitchChanged:(id)sender {
    if(roundtripSwitch.on)
        roundtrip = 2;
    else
        roundtrip = 1;
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UI"
                    action:@"MPG Slider Changed"
                    label:[NSString stringWithFormat:@"%i", roundtrip]
                    value:[NSNumber numberWithInt:roundtrip]] build]];
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
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"Calculations"
                        action:@"Calculating Gas Price"
                        label:nil
                        value:nil] build]];
        
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
                NSString *title = @"Network Error" ;
                NSString *message = @"No Connection" ;
                NSString *button = @"OK";
                price = 0;
                gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", price];
                [self alert:title withMessage:message withButton:button];
            }
        });
        
    }
}

- (void)calculateCost
{
    
    if(mpg > 0)
    {
        total = (price*miles*roundtrip)/mpg;
        cost = total/people;
        
        NSString *cost_string = [NSString stringWithFormat:@"$%0.2f", cost];
        NSString *total_string = [NSString stringWithFormat:@"$%0.2f", total];
        
        if([cost_string length] > 6) {
            // The source string is too long.
            gasPerPersonLabel.text = [NSString stringWithFormat:@"$%0.0f", cost];
        }
        else {
            // The source string is already less than 6 characters.
            gasPerPersonLabel.text = [NSString stringWithFormat:@"$%0.2f", cost];
        }
        
        if([total_string length] > 6){
            gasTotalLabel.text = [NSString stringWithFormat:@"$%0.0f", total];
        }
        else{
            
            gasTotalLabel.text = [NSString stringWithFormat:@"$%0.2f", total];
        }
    }
    
    if((price > 0) && (miles > 0))
    {
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"Calculations"
                        action:@"Total Cost"
                        label:gasTotalLabel.text
                        value:[NSNumber numberWithFloat:total]] build]];
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"Calculations"
                        action:@"Per Person Cost"
                        label:gasPerPersonLabel.text
                        value:[NSNumber numberWithFloat:cost]] build]];
        [Appirater userDidSignificantEvent:NO];
        [Appirater tryToShowPrompt];
        [[PFUser currentUser] incrementKey:@"calculatedCost"];
        [[PFUser currentUser] saveInBackground];
    }
}

- (void)getDirections
{
    if(start_mapitem && end_mapitem){
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
                 NSString *alert;
                 NSString *message;
                 NSString *button;
                 switch (error.code) {
                     case 5:
                     {
                        alert = @"No Directions Available";
                        message = [NSString stringWithFormat:@"There are no driving directions from %@ to %@", startLocationText.text, endLocationText.text];
                        button = @"OK";
                        break;
                     }
                     default:{
                         alert = @"No Directions Available";
                         message = [NSString stringWithFormat:@"There are no driving directions from %@ to %@", startLocationText.text, endLocationText.text];
                         button = @"OK";
                         break;
                     }
                 }
                 [self alert:alert withMessage:message withButton:button];
                 
             } else {
                 [self showRoute:response];
             }
         }];
    }
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    miles = 0;
    for (MKRoute *route in response.routes)
    {
        miles += route.distance;
        
        [mapView removeOverlays: [mapView overlays]];
        [mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        //        for (MKRouteStep *step in route.steps)
        //        {
        //            NSLog(@"%@", step.instructions);
        //        }
        
    }
    miles = miles/1609.34;
    NSLog(@"Miles:%f", miles);
    [self zoomToCenter:mapView withStart:start_placemarker.location.coordinate withEnd:end_placemarker.location.coordinate animated:YES];
    [self calculateCost];
}

- (void)zoomToCenter:(MKMapView *)map withStart:(CLLocationCoordinate2D)start withEnd:(CLLocationCoordinate2D)end animated:(BOOL)animate{
    CLLocationCoordinate2D locationCenter;
    MKCoordinateSpan locationSpan;
    int border = 4.5;
    
    locationCenter.longitude = ((start.longitude - end.longitude)/2 + end.longitude);
    locationCenter.latitude = ((start.latitude - end.latitude)/2 + end.latitude);
    NSLog(@"latitudedelta: %f", map.region.span.latitudeDelta);
    locationSpan.longitudeDelta = fabsf(start.longitude - end.longitude)*border;
    locationSpan.latitudeDelta = fabsf(start.latitude - end.latitude)*border;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
    locationCenter.latitude += .15*region.span.latitudeDelta;
    MKCoordinateRegion newRegion = MKCoordinateRegionMake(locationCenter, locationSpan);
    
    [map setRegion:newRegion animated:animate];
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
    
    NSLog(@"stations: %@", gasStations[0]); //3
    
    // 1) Get the first gas station
    if(gasStations == nil || [gasStations count] == 0)
    {
        NSString *title = @"No Gas Stations Nearby" ;
        NSString *message = @"Try typing in the nearest U.S. city" ;
        NSString *button = @"OK";
        startLocationText.text = @"Location Error";
        [currentLocationButton setSelected:NO];
        
        price = 0;
        gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", price];
        
        [self alert:title withMessage:message withButton:button];
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
            [tracker send:[[GAIDictionaryBuilder
                            createEventWithCategory:@"Location"
                            action:@"Gas Station Location"
                            label:city
                            value:[NSNumber numberWithFloat:price]] build]];
            [tracker send:[[GAIDictionaryBuilder
                            createEventWithCategory:@"Calculations"
                            action:@"Gas Price"
                            label:gasPriceLabel.text
                            value:[NSNumber numberWithFloat:price]] build]];
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
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"Error"
                    action:@"Memory Warning"
                    label:nil
                    value:nil] build]];
    // Dispose of any resources that can be recreated.
}

- (IBAction) unwindToMain:(UIStoryboardSegue *)segue{
    //nothing
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UI"
                    action:@"Page Navigation"
                    label:@"To Home Page"
                    value:nil] build]];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //[self calculateGas];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    [manager stopUpdatingLocation];
    startLocationText.text = @"Location Error";
    [currentLocationButton setSelected:NO];
    NSLog(@"didFailWithError: %@", error.debugDescription);
    NSString *title = @"Location Error" ;
    NSString *message = @"Failed to Get Your Location. Make sure Location services are enabled in Settings>Privacy>Location Services" ;
    NSString *button = @"OK";
    
    [self alert:title withMessage:message withButton:button];
    startLocationText.clearsOnBeginEditing = YES;
}

-(void)saveData
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:city forKey:@"city"];
    [defaults setDouble:cost forKey:@"cost"];
    [defaults setDouble:total forKey:@"total"];
    [defaults setDouble:end_placemarker.location.coordinate.latitude forKey:@"end_lat"];
    [defaults setDouble:end_placemarker.location.coordinate.longitude forKey:@"end_lng"];
    [defaults setObject:endLocationText.text forKey:@"endLocationText"];
    [defaults setObject:gas_type forKey:@"gas_type"];
    [defaults setInteger:gas_index forKey:@"gas_index"];
    [defaults setDouble:miles forKey:@"miles"];
    [defaults setInteger:mpg forKey:@"mpg"];
    [defaults setInteger:people forKey:@"people"];
    [defaults setInteger:price forKey:@"price"];
    [defaults setInteger:roundtrip forKey:@"roundtrip"];
    [defaults setObject:startLocationText.text forKey:@"startLocationText"];
    
    [defaults setDouble:start_placemarker.location.coordinate.latitude forKey:@"start_lat"];
    [defaults setDouble:start_placemarker.location.coordinate.longitude forKey:@"start_lng"];
    
    [defaults setObject:gasPriceLabel.text forKey:@"gasPriceLabel"];
    [defaults setObject:gasTotalLabel.text forKey:@"gasTotalLabel"];
    [defaults setObject:gasPerPersonLabel.text forKey:@"gasPerPersonLabel"];
    
    NSLog(@"Saving data: %f", [defaults doubleForKey:@"gas_index"]);
    
    PFObject *trip = [PFObject objectWithClassName:@"Trip"];
    trip[@"city"] = city ? city: @"";
    trip[@"cost_per"] = [NSNumber numberWithDouble:cost] ? [NSNumber numberWithDouble:cost]:0;
    trip[@"cost_total"] = [NSNumber numberWithDouble:total] ? [NSNumber numberWithDouble:total]: 0;
    trip[@"end_lat"] = [NSNumber numberWithDouble:end_placemarker.location.coordinate.latitude] ? [NSNumber numberWithDouble:end_placemarker.location.coordinate.latitude]:0;
    trip[@"end_lng"] = [NSNumber numberWithDouble:end_placemarker.location.coordinate.longitude] ? [NSNumber numberWithDouble:end_placemarker.location.coordinate.longitude]:0;
    trip[@"end_location"] = endLocationText.text?endLocationText.text:@"";
    trip[@"fuel_type"] = gas_type?gas_type:@"";
    trip[@"gas_type"] = [NSNumber numberWithDouble:gas_index] ? [NSNumber numberWithDouble:gas_index]:0;
    trip[@"miles"] = [NSNumber numberWithDouble:miles] ? [NSNumber numberWithDouble:miles]: 0;
    trip[@"mpg"] = [NSNumber numberWithDouble:mpg] ? [NSNumber numberWithDouble:mpg]: 0;
    trip[@"people"] = [NSNumber numberWithDouble:people] ? [NSNumber numberWithDouble:people]:0;
    trip[@"price"] = [NSNumber numberWithDouble:price] ? [NSNumber numberWithDouble:price]:0;
    trip[@"roundtrip"] = [NSNumber numberWithInt:roundtrip] ? [NSNumber numberWithInt:roundtrip]:0;
    trip[@"start_lat"] = [NSNumber numberWithDouble:start_placemarker.location.coordinate.latitude] ? [NSNumber numberWithDouble:start_placemarker.location.coordinate.latitude]: 0;
    trip[@"start_lng"] = [NSNumber numberWithDouble:start_placemarker.location.coordinate.longitude] ? [NSNumber numberWithDouble:start_placemarker.location.coordinate.longitude]:0;
    trip[@"start_location"] = startLocationText.text ? startLocationText.text:@"";
    trip[@"start_coord"] = [PFGeoPoint geoPointWithLatitude:start_placemarker.location.coordinate.latitude longitude:start_placemarker.location.coordinate.longitude];
    [trip setObject:[PFUser currentUser] forKey:@"createdBy"];
    
    [trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Saving data to Parse");
        } else {
            NSLog(@"Failed to Save data to Parse");
        }
    }];
}

-(void)loadData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    city = [defaults objectForKey:@"city"] ? [defaults objectForKey:@"city"]:city;
    cost = [defaults doubleForKey:@"cost"] ? [defaults doubleForKey:@"cost"]:cost;
    total = [defaults doubleForKey:@"total"] ? [defaults doubleForKey:@"total"]:total;
    
    end_placemarker = [defaults objectForKey:@"end_placemarker"] ? [defaults objectForKey:@"end_placemarker"]:end_placemarker;
    end_mapitem = [defaults objectForKey:@"end_mapitem"] ? [defaults objectForKey:@"end_mapitem"]:end_mapitem;
    end_annotation = [defaults objectForKey:@"end_annotation"] ? [defaults objectForKey:@"end_annotation"]:end_annotation;
    gas_type = [defaults objectForKey:@"gas_type"] ? [defaults objectForKey:@"gas_type"] : gas_type;
    gas_index = [defaults integerForKey:@"gas_index"] ? [defaults doubleForKey:@"gas_index"]:gas_index;
    miles = [defaults doubleForKey:@"miles"] ? [defaults doubleForKey:@"miles"]:miles;
    mpg = [defaults doubleForKey:@"mpg"] ? [defaults doubleForKey:@"mpg"]:mpg;
    people = [defaults doubleForKey:@"people"] ? [defaults doubleForKey:@"people"]:people;
    price = [defaults doubleForKey:@"price"] ? [defaults doubleForKey:@"price"]:price;
    roundtrip = [defaults doubleForKey:@"roundtrip"] ? [defaults doubleForKey:@"roundtrip"]:roundtrip;
    gas_index = [defaults doubleForKey:@"gas_index"] ? [defaults doubleForKey:@"gas_index"]:gas_index;
    
    startLocationText.text = [defaults objectForKey:@"startLocationText"] ? [defaults objectForKey:@"startLocationText"]:startLocationText.text;
    
    if([defaults doubleForKey:@"start_lat"] && [defaults doubleForKey:@"start_lng"]){
        [start_placemarker setCoordinate:CLLocationCoordinate2DMake([defaults doubleForKey:@"start_lat"],[defaults doubleForKey:@"start_lng"])];
        [start_annotation setCoordinate:CLLocationCoordinate2DMake([defaults doubleForKey:@"start_lat"],[defaults doubleForKey:@"start_lng"])];
        [self startSearchHandler:startLocationText withError:NO];
    }
    
    endLocationText.text = [defaults objectForKey:@"endLocationText"] ? [defaults objectForKey:@"endLocationText"]:endLocationText.text;
    if([defaults doubleForKey:@"end_lat"] && [defaults doubleForKey:@"end_lng"]){
        [end_placemarker setCoordinate:CLLocationCoordinate2DMake([defaults doubleForKey:@"end_lat"],[defaults doubleForKey:@"end_lng"])];
        [end_annotation setCoordinate:CLLocationCoordinate2DMake([defaults doubleForKey:@"end_lat"],[defaults doubleForKey:@"end_lng"])];
        if(![endLocationText.text  isEqual: @""] && ![startLocationText.text  isEqual: @""]){
        [self endSearchHandler:endLocationText withError:YES];
        }
    }
    
    gasPriceLabel.text = [defaults objectForKey:@"gasPriceLabel"] ? [defaults objectForKey:@"gasPriceLabel"]:gasPriceLabel.text;
    gasTotalLabel.text = [defaults objectForKey:@"gasTotalLabel"] ? [defaults objectForKey:@"gasTotalLabel"]:gasTotalLabel.text;
    gasPerPersonLabel.text = [defaults objectForKey:@"gasPerPersonLabel"] ? [defaults objectForKey:@"gasPerPersonLabel"]:gasPerPersonLabel.text;
    
    gas_type_segment.selectedSegmentIndex = gas_index;
    mpgSlider.value = mpg;
    peopleSlider.value = people;
}

-(IBAction)updateTrip:(id)sender{
    [self getTrip:parseTripId.text];
    
}

-(void)getTrip:(NSString *)tripid{
    if(![tripid  isEqual: @""])
    {
        PFQuery *query = [PFQuery queryWithClassName:@"Trip"];
        [query getObjectWithId:tripid];
        [query getObjectInBackgroundWithId:tripid block:^(PFObject *tripObject, NSError *error) {
            if(error)
            {
                [self alert:@"Trip ID not found" withMessage:@"This is an invalid Trip ID, create a new one at gasbro.com" withButton:@"OK"];
            }
            else
            {
                startLocationText.text = [tripObject valueForKey:@"start_location"];
                endLocationText.text = [tripObject valueForKey:@"end_location"];
                
                NSString *parseGasType = [tripObject objectForKey:@"gas_type"];
                gas_index = parseGasType.intValue;
                gas_type_segment.selectedSegmentIndex = gas_index;
                
                
                NSString *parseMiles = [tripObject objectForKey:@"miles"];
                miles = parseMiles.floatValue;
                NSString *parseMPG = [tripObject objectForKey:@"mpg"];
                mpg = parseMPG.intValue;
                mpgSlider.value = mpg;
                
                NSString *parsePeople = [tripObject objectForKey:@"people"];
                people = parsePeople.intValue;
                peopleSlider.value = people;
                
                NSString *parseRoundtrip = [tripObject objectForKey:@"roundtrip"];
                roundtrip = parseRoundtrip.intValue;
                NSString *parsePrice = [tripObject objectForKey:@"price"];
                price = parsePrice.floatValue;
                
                city = [tripObject valueForKey:@"city"];
                
                NSDictionary *startAddrDict = @{
                                                (NSString *) kABPersonAddressStreetKey : startLocationText.text,
                                                (NSString *) kABPersonAddressCityKey : city
                                                };
                NSString *parseStartLat = [tripObject objectForKey:@"start_lat"];
                NSString *parseStartLng = [tripObject objectForKey:@"start_lng"];
                
                CLLocationDegrees startLat = parseStartLat.floatValue;
                CLLocationDegrees startLng = parseStartLng.floatValue;
                
                CLLocationCoordinate2D startLocation = CLLocationCoordinate2DMake(startLat, startLng);
                
                
                NSDictionary *endAddrDict = @{
                                              (NSString *) kABPersonAddressStreetKey : endLocationText.text
                                              };
                
                NSString *parseEndLat = [tripObject objectForKey:@"end_lat"];
                NSString *parseEndLng = [tripObject objectForKey:@"end_lng"];
                
                CLLocationDegrees endLat = parseEndLat.floatValue;
                CLLocationDegrees endLng = parseEndLng.floatValue;
                
                CLLocationCoordinate2D endLocation = CLLocationCoordinate2DMake(endLat, endLng);
                
                MKPlacemark *parseStartPlacemarker = [[MKPlacemark alloc] initWithCoordinate:startLocation addressDictionary:startAddrDict];
                MKPlacemark *parseEndPlacemarker = [[MKPlacemark alloc] initWithCoordinate:endLocation addressDictionary:endAddrDict];
                
                start_placemarker = parseStartPlacemarker;
                end_placemarker = parseEndPlacemarker;
                
                [self calculateCost];
                
                [self updateView:parseTripId.text];
            }
        }];
        
    }
    
}

- (IBAction)panOnGasPriceAction:(id)sender{
    NSLog(@"Pan Action");
}

-(void)viewDidDisappear:(BOOL)animated{
    [self saveData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self saveData];
}

@end