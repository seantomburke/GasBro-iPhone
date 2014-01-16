//
//  GBViewController.m
//  GasBro
//
//  Created by Sean Thomas Burke on 9/26/13.
//  Copyright (c) 2013 Nyquist Labs. All rights reserved.
//

#import "GBViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@interface GBViewController ()

@end



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


@implementation GBViewController{
    CLLocationManager *locationManager;
    
    NSArray *activityItems;
    
    UIActivityViewController *activityController;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    locationManager = [[CLLocationManager alloc] init];
    [self peopleSliderChanged:(self)];
    [self roundtripSwitchChanged:(self)];
    [self mpgSliderChanged:(self)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Any additional checks to ensure you have the correct textField here.
    [_startLocationText resignFirstResponder];
    [_endLocationText resignFirstResponder];
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
            float spanX = 1.00725;
            float spanY = 1.00725;
            MKCoordinateRegion region;
            _start_latitude = _start_placemarker.location.coordinate.latitude;
            _start_longitude = _start_placemarker.location.coordinate.longitude;
            _start_mapitem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:_start_placemarker]];
            region.span = MKCoordinateSpanMake(spanX, spanY);
            NSLog(@"long:%f,lat:%f", _start_latitude,_start_longitude);
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
            float spanX = 1.00725;
            float spanY = 1.00725;
            MKCoordinateRegion region;
            _end_latitude = _end_placemarker.location.coordinate.latitude;
            _end_longitude = _end_placemarker.location.coordinate.longitude;
            _end_mapitem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark: _end_placemarker]];
            region.span = MKCoordinateSpanMake(spanX, spanY);
            NSLog(@"long:%f,lat:%f", _end_latitude,_end_longitude);
            [self getDirections];
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
    if(_start_latitude != 0)
    {
        _gas_type = [_gas_type_segment titleForSegmentAtIndex:_gas_type_segment.selectedSegmentIndex].lowercaseString;
        NSInteger index = _gas_type_segment.selectedSegmentIndex;
        _gas_index = index;
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.gasbro.com/gas.php?longitude=%f&latitude=%f&gas_type=%li", _start_longitude, _start_latitude, (long)_gas_index]];
        
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
        
        //[addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
        
    }
    _miles = _miles/1609.34;
    NSLog(@"Miles:%f", _miles);
    
    [self calculateCost];
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
        
        _start_longitude = 0;
        _start_latitude = 0;
        _start_placemarker = nil;
        _start_mapitem = nil;
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
        int i = 0;
        _start_latitude = 0;
        while (_start_latitude == 0 && i<1500) {
            i++;
            NSLog(@"%f",locationManager.location.coordinate.latitude);
            _start_latitude = locationManager.location.coordinate.latitude;
        }
        _start_longitude = locationManager.location.coordinate.longitude;
        _start_mapitem = [MKMapItem mapItemForCurrentLocation];
        
        [self calculateGas];
    });
    
    
    
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

@end
