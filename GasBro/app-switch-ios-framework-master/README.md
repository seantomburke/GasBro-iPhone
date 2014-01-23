Venmo App Switch SDK
========================

This open-source Cocoa Touch Static Library allows users of your app to pay or charge with Venmo. 
It switches to the Venmo app if it's installed on the device. Otherwise, it opens Venmo in a web view. When the transaction is complete, it switches back to your app.

Create a Venmo Application
--------------------------

Create a new Venmo Application by visiting https://venmo.com/ 

Login and go to: Account > Developers > [New Application][1].

![Create new application](https://dl.dropboxusercontent.com/s/ffo01uzr65y9kzw/GbalC.png)


Project Setup
-------------

#### Ensure you have the latest (released or beta) version of Xcode installed.

#### Download the VenmoAppSwitch framework & add to your project

Download the framework folder [here](https://github.com/venmo/app-switch-ios-framework/archive/master.zip).

Unzip the folder, and drag VenmoAppSwitch.framework into your Xcode project.

*Make sure the "Copy items to destination's group folder" checkbox is checked.*

- Click on the Targets → Your app name → and then the 'Build Phases' tab and then expand 'Link Binary With Libraries' arrow.
- Click the plus button in the bottom left of the 'Link Binary With Libraries' section.
- Add UIKit.framework and Foundation.framework if they are not already added. 

#### Add the Venmo URL Type

Select the "Info" tab. Add a URL Type with Identifier: `Venmo`, Role: `Editor`, and URL Schemes: `venmo1234`, where `1234` is your app ID from your app settings on https://venmo.com.

Using Venmo in Your App
-----------------------
First, create a Venmo client and transaction. 
```objc
#import <VenmoAppSwitch/Venmo.h>

VenmoClient *venmoClient = [VenmoClient clientWithAppId:kVenmoAppId secret:kVenmoAppSecret];
    
VenmoTransaction *venmoTransaction = [[VenmoTransaction alloc] init];
venmoTransaction.type = VenmoTransactionTypePay;
venmoTransaction.amount = [NSDecimalNumber decimalNumberWithString:@"0.05"];
venmoTransaction.note = @"hello world";
venmoTransaction.toUserHandle = @"matthewhamilton";
```

Call -[VenmoClient viewControllerWithTransaction:], which will open the Venmo app or return a VenmoViewController.
```objc
VenmoViewController *venmoViewController = [venmoClient viewControllerWithTransaction:
                                                venmoTransaction];
if (venmoViewController) {
    [self presentModalViewController:venmoViewController animated:YES];
}
```

Handle the redirect back to your app in your AppDelegate.m file.
```objc
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"openURL: %@", url);
    return [venmoClient openURL:url completionHandler:^(VenmoTransaction *transaction, NSError *error) {
        if (transaction) {
            NSString *success = (transaction.success ? @"Success" : @"Failure");
            NSString *title = [@"Transaction " stringByAppendingString:success];
            NSString *message = [@"payment_id: " stringByAppendingFormat:@"%@. %@ %@ %@ (%@) $%@ %@",
                                 transaction.transactionID,
                                 transaction.fromUserID,
                                 transaction.typeStringPast,
                                 transaction.toUserHandle,
                                 transaction.toUserID,
                                 transaction.amountString,
                                 transaction.note];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message
                                                               delegate:nil cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else { // error
            NSLog(@"transaction error code: %i", error.code);
        }
    }];
}
```
