//
//  GBViewController.h
//  GasBro
//
//  Created by Sean Thomas Burke on 9/26/13.
//  Copyright (c) 2013 Nyquist Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GBViewController : UIViewController <CLLocationManagerDelegate>{
    IBOutlet UILabel* humanReadble;
    IBOutlet UILabel* jsonSummary;
}

@property (readwrite) Float64 longitude;
@property (readwrite) Float64 latitude;
@property (readwrite) Float64 price;
@property (readwrite) Float64 cost;
@property (readwrite) Float64 miles;
@property (readwrite) int people;
@property (readwrite) int mpg;
@property (readwrite) Boolean roundtrip;

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

- (IBAction)getCurrentLocation:(id)sender;
- (IBAction)peopleSliderChanged:(id)sender;
- (IBAction)mpgSliderChanged:(id)sender;
-(void)calculateGas;
-(IBAction)updateStartToLoading;

@end
