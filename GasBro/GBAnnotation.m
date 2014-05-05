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
-(id)annotationView{
    return self;
}
@end