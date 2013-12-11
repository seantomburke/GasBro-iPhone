//
//  GBViewController.m
//  GasBro
//
//  Created by Sean Thomas Burke on 9/26/13.
//  Copyright (c) 2013 Nyquist Labs. All rights reserved.
//

#import "GBViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kLatestKivaLoansURL [NSURL URLWithString: @"http://api.kivaws.org/v1/loans/search.json?status=fundraising"] //2


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

-(void)dismissKeyboard {
    [_startLocationText resignFirstResponder];
    [_endLocationText resignFirstResponder];
}

-(void)updateStartToLoading {
    _startLocationText.text = @"Loading...";
}

- (IBAction)startSearch:(UITextField *)sender {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:sender.text completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            } else {
                _start_placemarker = [placemarks lastObject];
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

- (IBAction)endSearch:(UITextField *)sender {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:sender.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            _end_placemarker = [placemarks lastObject];
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
        if(_start_longitude == 0)
        {
            NSLog(@"Failed to get location");
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle:@"Error" message:@"Failed to Get Your Location. Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
            _startLocationText.text = @"Error Try Again";
        }
        else{
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.gasbro.com/gas.php?longitude=%f&latitude=%f", _start_longitude, _start_latitude]];
    
            dispatch_async(kBgQueue, ^{
                NSData* data = [NSData dataWithContentsOfURL:
                        url];
                [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
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
    if(sizeof gasStations == 0)
    {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"No Gas Stations Near here" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
    else
    {
        NSDictionary* station = [gasStations objectAtIndex:0];
        
        // 2) Get the funded amount and loan amount
        NSNumber* price = [station objectForKey:@"price"];
        NSString* city = [station objectForKey:@"city"];
        _price =    [price floatValue];
        
        // 3) Set the label appropriately
        humanReadble.text = [NSString stringWithFormat:@"The Cost of gas in %@ is $%0.2f",
                             city,
                             _price];
        _gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", _price];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getCurrentLocation:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    NSLog(@"%f",locationManager.location.coordinate.latitude);
    _start_latitude = locationManager.location.coordinate.latitude;
    _start_longitude = locationManager.location.coordinate.longitude;
    _start_mapitem = [MKMapItem mapItemForCurrentLocation];
    _startLocationText.text = @"Current Location";
    [self calculateGas];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //[self calculateGas];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

@end
