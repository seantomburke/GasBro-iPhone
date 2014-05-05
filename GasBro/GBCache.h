//
//  GBCache.h
//  GasBro
//
//  Created by Sean Thomas Burke on 5/4/14.
//  Copyright (c) 2014 Nyquist Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBCache : NSObject

@property (strong, nonatomic, readwrite) NSCache *cache;

-(void)storeProfileImage:(UIImage *)image;
-(UIImage*)getProfileImage;

@end
