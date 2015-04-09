//
//  PasswordManager.m
//  SimplicITy
//
//  Created by Varghese Simon on 4/8/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "PasswordManager.h"

@interface PasswordManager () <UIAlertViewDelegate>

@end

@implementation PasswordManager
{
    UIAlertView *passwordAlert;
}

- (instancetype)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

- (NSString *)passwordForUser
{
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:EWS_USERS_PASSWORD];
    
    if (password == nil)
    {
        [self showAlertWithDefaultMessage];
    }
    
    return password;
}

- (void)showAlertForPasswordWithMessage:(NSString *)message
{
    if (passwordAlert == nil)
    {
        passwordAlert = [[UIAlertView alloc] initWithTitle:@"Password is required"
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                     otherButtonTitles:@"OK", nil];
        
        passwordAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;

    }
    
    passwordAlert.message = message;
    [passwordAlert show];
}

- (void)showAlertWithDefaultMessage
{
    [self showAlertForPasswordWithMessage:@"Please enter the 'Password' to continue"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        UITextField *passwordField = [alertView textFieldAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:passwordField forKey:EWS_USERS_PASSWORD];
        NSLog(@"%@", passwordField);
    }
}

@end
