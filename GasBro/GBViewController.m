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
    [self mpgSliderChanged:(self)];
    
    
}

- (void)calculateGas
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.gasbro.com/gas.php?longitude=%f&latitude=%f", locationManager.location.coordinate.longitude, locationManager.location.coordinate.latitude]];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        url];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
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
        float gasPrice =    [price floatValue];
        
        // 3) Set the label appropriately
        humanReadble.text = [NSString stringWithFormat:@"The Cost of gas in %@ is $%0.2f",
                             city,
                             gasPrice];
        _gasPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", gasPrice];
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
    
        [self calculateGas];
}

- (IBAction)peopleSliderChanged:(id)sender {
    _peopleLabel.text = [NSString stringWithFormat:@"%d", (int) _peopleSlider.value];
}

- (IBAction)mpgSliderChanged:(id)sender {
    _mpgLabel.text = [NSString stringWithFormat:@"%d", (int) _mpgSlider.value];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
}

@end
