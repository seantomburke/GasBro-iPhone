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
@property (strong, nonatomic) UIImage *facebook_image;
@end


@implementation GBInfoViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    GBCache *shared = [GBCache gbCache];
    _facebook_image = [shared getProfileImage];
    
    if(!_facebook_image)
    {
        [_profile setImage:[UIImage imageNamed:@"iTunesArtwork"]];
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
                [_profile setImage:[UIImage imageNamed:@"iTunesArtwork"]];
            }
        });
    }
    else
    {
        [_profile setImage:[UIImage imageNamed:@"iTunesArtwork"]];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"About Screen";
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self
                                      action:@selector(openSeanLink)];
    
    [_profile addGestureRecognizer:tap];
           
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) unwindAction:(UIStoryboardSegue *)segue{
    
}

-(void)openSeanLink{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.seantburke.com/?r=gasbroios"]];
}

- (IBAction)openSean:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.seantburke.com/?r=gasbroios"]];
}


- (IBAction)infoButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setProfileImage:(NSData *)data {
    _facebook_image = [[UIImage alloc] initWithData:data];
    [_profile setImage:_facebook_image];
}




@end
