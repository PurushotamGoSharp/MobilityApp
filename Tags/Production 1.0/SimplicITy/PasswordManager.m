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
    NSString *base64EncodedString = [[NSUserDefaults standardUserDefaults] objectForKey:EWS_USERS_PASSWORD];
    NSString *password;
    
    if (base64EncodedString)
    {
        NSData *passwordData = [[NSData alloc] initWithBase64EncodedString:base64EncodedString
                                                                   options:0];
        password = [[NSString alloc] initWithData:passwordData
                                                   encoding:NSUTF8StringEncoding];
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
        NSString *password = passwordField.text;
        NSData *passWordData = [password dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64EncodedString = [passWordData base64EncodedStringWithOptions:0];
        
        NSLog(@"Encoded Password %@", base64EncodedString);

        [[NSUserDefaults standardUserDefaults] setObject:base64EncodedString
                                                  forKey:EWS_USERS_PASSWORD];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.delegate passwordManagerGotPassword:self];
    }else
    {
        [self.delegate passwordManagerFailedToGetPassoword:self];
    }
}

@end
