//
//  GBStartAnnotation.m
//  GasBro
//
//  Created by Sean Thomas Burke on 5/7/14.
//  Copyright (c) 2014 Nyquist Labs. All rights reserved.
//

#import "GBAnnotation.h"

@implementation GBAnnotation
@synthesize color;
@synthesize title;
@synthesize subtitle;
@synthesize coordinate;

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

-(id)initWithLocation:(CLLocationCoordinate2D)coordinates withTitle:(NSString*)titles withSubtitle:(NSString*)subtitles{
    self = [self initWithLocation:coordinate withTitle:titles];
    [self setSubtitle:subtitles];
    return self;
}

-(MKPinAnnotationView *)annotationView{
    MKPinAnnotationView *pinView;
    // If an existing pin view was not available, create one.
    pinView = [[MKPinAnnotationView alloc] init];
    //pinView.canShowCallout = YES;
    pinView.animatesDrop = TRUE;
    return pinView;
}
@end
