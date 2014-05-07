//
//  GBAnnotation.h
//  GasBro
//
//  Created by Sean Thomas Burke on 5/3/14.
//  Copyright (c) 2014 Nyquist Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GBAnnotation : MKAnnotationView <MKAnnotation>


@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic, readwrite) NSString *title;
@property (copy, nonatomic, readwrite) NSString *subTitle;
@property (readwrite) MKPinAnnotationColor color;

-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;
-(id)initWithLocation:(CLLocationCoordinate2D)coordinate;
-(id)initWithLocation:(CLLocationCoordinate2D)coordinate withTitle:(NSString*)title;
-(id)initWithLocation:(CLLocationCoordinate2D)coordinate withTitle:(NSString*)title withSubTitle:(NSString*)subtitle;
-(MKAnnotationView *)annotationView;
@end
