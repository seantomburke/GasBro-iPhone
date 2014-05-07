//
//  GBAnnotation.h
//  GasBro
//
//  Created by Sean Thomas Burke on 5/3/14.
//  Copyright (c) 2014 Nyquist Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GBAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic, readwrite) NSString *title;
@property (copy, nonatomic, readwrite) NSString *subtitle;
@property (nonatomic, readwrite) MKPinAnnotationColor color;

-(id)initWithLocation:(CLLocationCoordinate2D)coordinate;
-(id)initWithLocation:(CLLocationCoordinate2D)coordinate withTitle:(NSString*)title;
-(id)initWithLocation:(CLLocationCoordinate2D)coordinate withTitle:(NSString*)title withSubtitle:(NSString*)subtitle;
-(MKAnnotationView *)annotationView;
@end

@protocol GBAnnotation <MKAnnotation>

-(MKPinAnnotationColor)color;

@end