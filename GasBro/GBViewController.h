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
#import "GBInfoViewController.h"
#import "GBCache.h"
#import "GBStartAnnotation.h"
#import "GBEndAnnotation.h"

@interface GBViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate, MKAnnotation>{
}


@property (readwrite) Float64 price;
@property (readwrite) NSString *gas_type;
@property (readwrite) NSString *share_text;
@property (readwrite) NSString *city;
@property (readwrite) NSInteger gas_index;
@property (readwrite) Float64 cost;
@property (readwrite) Float64 total;
@property (readwrite) Float64 miles;
@property (readwrite) MKPlacemark *start_placemarker;
@property (readwrite) MKPlacemark *end_placemarker;

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
@property (weak, nonatomic) IBOutlet UISwitch *roundtripSwitch;
@property (strong, nonatomic) IBOutlet MKMapView *routeMap;
@property (strong, nonatomic, readwrite) MKMapItem *end_mapitem;
@property (strong, nonatomic, readwrite) MKMapItem *start_mapitem;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gas_type_segment;
@property (weak, nonatomic) IBOutlet GBInfoViewController *infoView;

@property (readwrite) IBOutlet UIView *topView;
@property (readwrite) IBOutlet UIView *bottomView;
@property (readwrite) IBOutlet MKMapView *mapView;
@property (readwrite, strong, nonatomic) GBCache *cache;

@property (readwrite, strong) GBStartAnnotation *start_annotation;
@property (readwrite, strong) GBEndAnnotation *end_annotation;


- (IBAction)getCurrentLocation:(id)sender;
- (IBAction)peopleSliderChanged:(id)sender;
- (IBAction)mpgSliderChanged:(id)sender;
- (IBAction)roundtripSwitchChanged:(id)sender;
- (IBAction)startSearch:(id)sender;
- (IBAction)updateGasType:(id)sender;
- (IBAction)infoButtonClicked:(id)sender;
- (IBAction) unwindToMain:(UIStoryboardSegue *)segue;

-(void) saveData;
-(void) loadData;
- (void)calculateGas;
- (void)calculateCost;

@end
