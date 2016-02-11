//
//  FirstInterfaceController.m
//  SimplicITy
//
//  Created by Vmoksha on 12/08/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "FirstInterfaceController.h"

@interface FirstInterfaceController ()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *passwordExpiryLabel;

@end

@implementation FirstInterfaceController
{
    NSString *passwordExpText;
}

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
//    [WKInterfaceController openParentApplication:@{@"MobilITy":@"Verifiation"} reply:^(NSDictionary * _Nonnull replyInfo, NSError * _Nullable error) {
//        [self.passwordExpiryLabel setText:replyInfo[@"PasswordExpText"]];
//    }];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



