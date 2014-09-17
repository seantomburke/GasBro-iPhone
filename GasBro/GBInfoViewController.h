//
//  GBInfoViewController.h
//  GasBro
//
//  Created by Sean Thomas Burke on 1/16/14.
//  Copyright (c) 2014 Nyquist Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Appirater.h>
#import "GAITrackedViewController.h"

@interface GBInfoViewController : GAITrackedViewController <UITextFieldDelegate> {
}
@property IBOutlet UIImageView *profile;

- (IBAction) unwindAction:(UIStoryboardSegue *)segue;
- (IBAction)openSean:(id)sender;
@end
