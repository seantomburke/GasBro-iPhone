//
//  GBViewController.h
//  GasBro
//
//  Created by Sean Thomas Burke on 9/26/13.
//  Copyright (c) 2013 Nyquist Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface GBViewController : UIViewController <CLLocationManagerDelegate>{
    IBOutlet UILabel* humanReadble;
}

@property (readwrite) Float64 start_longitude;
@property (readwrite) Float64 start_latitude;
@property (readwrite) Float64 end_longitude;
@property (readwrite) Float64 end_latitude;
@property (readwrite) Float64 price;
@property (readwrite) NSString *gas_type;
@property (readwrite) Float64 cost;
@property (readwrite) Float64 total;
@property (readwrite) Float64 miles;
@property (readwrite) int people;
@property (readwrite) int mpg;
@property (readwrite) int roundtrip;

@property (weak, nonatomic) IBOutlet UILabel *peopleLabel;
@property (weak, nonatomic) IBOutlet UILabel *mpgLabel;
@property (weak, nonatomic) IBOutlet UISlider *peopleSlider;
@property (weak, nonatomic) IBOutlet UISlider *mpgSlider;
@property (weak, nonatomic) IBOutlet UILabel *gasPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *gasTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *gasPerPersonLabel;
@property (weak, nonatomic) IBOutlet UITextField *startLocationText;
@property (weak, nonatomic) IBOutlet UITextField *endLocationText;
@property (weak, nonatomic) IBOutlet UIViewController *googlemap;
@property (weak, nonatomic) IBOutlet UISwitch *roundtripSwitch;

@property (strong, nonatomic) IBOutlet MKMapView *routeMap;
@property (strong, nonatomic) CLPlacemark *end_placemarker;
@property (strong, nonatomic) CLPlacemark *start_placemarker;

@property (strong, nonatomic) MKMapItem *end_mapitem;
@property (strong, nonatomic) MKMapItem *start_mapitem;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gas_type_segment;

- (IBAction)getCurrentLocation:(id)sender;
- (IBAction)peopleSliderChanged:(id)sender;
- (IBAction)mpgSliderChanged:(id)sender;
- (IBAction)roundtripSwitchChanged:(id)sender;
- (IBAction)updateStartToLoading;
- (IBAction)startSearch:(id)sender;
- (IBAction)updateGasType:(id)sender;
- (void)calculateGas;
- (void)calculateCost;

@end
