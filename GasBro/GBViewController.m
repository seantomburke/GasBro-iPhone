//
//  GBViewController.m
//  GasBro
//
//  Created by Sean Thomas Burke on 9/26/13.
//  Copyright (c) 2013 Nyquist Labs. All rights reserved.
//

#import "GBViewController.h"
#import <GoogleMaps/GoogleMaps.h>

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

- (void)calculateGas
{
        if(locationManager.location.coordinate.latitude == 0)
        {
            NSLog(@"Failed to get location");
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle:@"Error" message:@"Failed to Get Your Location. Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
        }
        else{
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.gasbro.com/gas.php?longitude=%f&latitude=%f", locationManager.location.coordinate.longitude, locationManager.location.coordinate.latitude]];
    
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
    _miles = 10;
    _total = (_price*_miles)/_mpg;
    _cost = _total/_people;
    _gasPerPersonLabel.text = [NSString stringWithFormat:@"$%0.2f", _cost];
    _gasTotalLabel.text = [NSString stringWithFormat:@"$%0.2f", _total];
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
        _startLocationText.text = [NSString stringWithFormat:@"%@", city];
        
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
    [self calculateGas];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //[self calculateGas];
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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

@end
