//
//  GBInfoViewController.m
//  GasBro
//
//  Created by Sean Thomas Burke on 1/16/14.
//  Copyright (c) 2014 Nyquist Labs. All rights reserved.
//

#import "GBInfoViewController.h"

@interface GBInfoViewController ()

@end

@implementation GBInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/hawaiianchimp/picture?height=960&type=normal&width=960"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    [profile setImage:[[UIImage alloc] initWithData:data]];
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



@end
