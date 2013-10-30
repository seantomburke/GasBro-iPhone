//
//  GBMapView.m
//  GasBro
//
//  Created by Sean Thomas Burke on 10/29/13.
//  Copyright (c) 2013 Nyquist Labs. All rights reserved.
//

#import "GBMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation GBMapViewController {
    GMSMapView *mapView_;
    
}

// You don't need to modify the default initWithNibName:bundle: method.


- (void)loadView {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    self.view = mapView_;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView_;
}

@end
