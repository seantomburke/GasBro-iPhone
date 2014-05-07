//
//  GBAnnotation.m
//  GasBro
//
//  Created by Sean Thomas Burke on 5/3/14.
//  Copyright (c) 2014 Nyquist Labs. All rights reserved.
//

#import "GBAnnotation.h"

@implementation GBAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize color;

-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
}

-(id)initWithLocation:(CLLocationCoordinate2D)coordinates{
    self = [super init];
    [self setCoordinate:coordinates];
    return self;
}

-(id)initWithLocation:(CLLocationCoordinate2D)coordinates withTitle:(NSString*)titles{
    self = [self initWithLocation:coordinates];
    [self setTitle:titles];
    return self;
}

-(id)initWithLocation:(CLLocationCoordinate2D)coordinates withTitle:(NSString*)titles withSubTitle:(NSString*)subtitles{
    self = [self initWithLocation:coordinate withTitle:title];
    [self setSubTitle:subtitles];
    return self;
}

-(MKPinAnnotationView *)annotationView{
    MKPinAnnotationView *pinView;
    // If an existing pin view was not available, create one.
    pinView = [[MKPinAnnotationView alloc] init];
    pinView.canShowCallout = YES;
    pinView.animatesDrop = TRUE;
    [pinView setPinColor:color];
    return pinView;
}
@end