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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) unwindAction:(UIStoryboardSegue *)segue{
    
}


- (IBAction)infoButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
