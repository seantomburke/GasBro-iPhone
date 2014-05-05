//
//  GBInfoViewController.m
//  GasBro
//
//  Created by Sean Thomas Burke on 1/16/14.
//  Copyright (c) 2014 Nyquist Labs. All rights reserved.
//

#import "GBInfoViewController.h"
#import "GBViewController.h"
#import "GBCache.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@interface GBInfoViewController ()
@property (strong, nonatomic) GBCache *cache;
@end


@implementation GBInfoViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.cache = [[GBCache alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *cached_image = [_cache getProfileImage];
    if(!cached_image)
    {
        [profile setImage:[UIImage imageNamed:@"iTunesArtwork"]];
        NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/hawaiianchimp/picture?height=154&type=normal&width=154"];
        dispatch_async(kBgQueue, ^{
        
            NSData *data = [NSData dataWithContentsOfURL:url];
            if(data != nil)
            {
                [self performSelectorOnMainThread:@selector(setProfileImage:)
                                   withObject:data waitUntilDone:YES];
            }
            else
            {
                [profile setImage:[UIImage imageNamed:@"iTunesArtwork"]];
            }
        });
    }
    else
    {
        [profile setImage:cached_image];
    }
           
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) unwindAction:(UIStoryboardSegue *)segue{
    
}

- (IBAction)openSean:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.seantburke.com/?r=gasbroios"]];
}


- (IBAction)infoButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setProfileImage:(NSData *)data {
    UIImage *profile_image = [[UIImage alloc] initWithData:data];
    [profile setImage:profile_image];
    [_cache storeProfileImage:profile_image];
}



@end
