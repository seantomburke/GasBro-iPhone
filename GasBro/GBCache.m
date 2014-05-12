//
//  GBCache.m
//  GasBro
//
//  Created by Sean Thomas Burke on 5/4/14.
//  Copyright (c) 2014 Nyquist Labs. All rights reserved.
//

#import "GBCache.h"
static GBCache* gbCache = nil;

@implementation GBCache
@synthesize cache;

- (instancetype)init
{
    self = [super init];
    if (self) {
        cache = [[NSCache alloc] init];
    }
    return self;
}

-(void)storeProfileImage:(UIImage *)image {
    [cache setObject:image forKey:@"profile"];
}

-(UIImage*)getProfileImage{
    UIImage *image = [cache objectForKey:@"profile"];
    return image;
}

+(void)load{
    gbCache = [[GBCache alloc] init];
}

+(GBCache*)gbCache {
    return gbCache;
}


@end
