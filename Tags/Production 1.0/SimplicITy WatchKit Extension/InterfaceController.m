//
//  InterfaceController.m
//  SimplicITy WatchKit Extension
//
//  Created by Vmoksha on 05/08/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "InterfaceController.h"
#import "NSDateFormatter+Locale.h"


int currentValue;
bool shouldStopCountDown;

//NSInteger  daysleftInt;


@interface InterfaceController() <NSURLConnectionDelegate>
@end


@implementation InterfaceController
{
    NSURLConnection *connection;
    NSURLRequest *request;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
//    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
//                                  initWithSuiteName:@"group.com.ucb.app.SimplicITy"];
    
    [self.pExpireLabel setAlpha:0];
    __block NSDictionary *userInfo;
    [WKInterfaceController openParentApplication:@{@"MobilITy":@"Verifiation"} reply:^(NSDictionary *replyInfo, NSError *error) {
        userInfo = replyInfo;
        NSString *ldapBaseURl = userInfo[@"ucbAPIURL"];
        NSString *corpID = userInfo[@"corpID"];
        
        NSString *expirationURLString = [NSString stringWithFormat:@"%@ad/account-status/id/%@",ldapBaseURl, corpID];
        
        NSURL *url = [NSURL URLWithString:expirationURLString];
        request = [NSURLRequest requestWithURL:url];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }];
    
//    NSDictionary *userInfo = [myDefaults objectForKey:@"SharedUserInfoDictKey"];

}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    NSLog(@"AppleInterface Watch Is Activated/...........");
    
//    [self.passwordProgress setBackgroundImageNamed:@"initialBackgroundImage"];
//    [self.pDaysLabel setText:@"0"];
//    [self.passwordProgress setHidden:NO];
//    [self.pDaysLabel setHidden:NO];
}


- (void)didDeactivate
{
    [super didDeactivate];

    NSLog(@"AppleInterface Watch Is DeActivated/...........");
}

#pragma mark:


- (void)identity:(SecIdentityRef *)identity andCertificate:(SecCertificateRef *)certificate forPKC12Data:(NSData *)certData withPassphrase:(NSString *)passphrase
{
    // bridge the import data to foundation objects
    CFStringRef importPassphrase = (__bridge CFStringRef)passphrase;
    CFDataRef importData = (__bridge CFDataRef)certData;
    
    // create dictionary of options for the PKCS12 import
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { importPassphrase };
    CFDictionaryRef importOptions = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    // create array to store our import results
    CFArrayRef importResults = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus pkcs12ImportStatus = errSecSuccess;
    pkcs12ImportStatus = SecPKCS12Import(importData, importOptions, &importResults);
    
    // check if import was successful
    if (pkcs12ImportStatus == errSecSuccess)
    {
        CFDictionaryRef identityAndTrust = CFArrayGetValueAtIndex (importResults, 0);
        
        // retrieve the identity from the certificate imported
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (identityAndTrust, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
        
        // extract the certificate from the identity
        SecCertificateRef tempCertificate = NULL;
        OSStatus certificateStatus = errSecSuccess;
        certificateStatus = SecIdentityCopyCertificate (*identity, &tempCertificate);
        *certificate = (SecCertificateRef)tempCertificate;
    }else
    {
        NSLog(@"Status is %d", (int)pkcs12ImportStatus);
    }
    
    // clean up
    if (importOptions)
    {
        CFRelease(importOptions);
    }
}

#pragma mark:
#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"p12"];
    NSData *certData = [[NSData alloc] initWithContentsOfFile:certPath];
    
    SecIdentityRef identity = NULL;
    SecCertificateRef certificate = NULL;
    
    [self identity:&identity
    andCertificate:&certificate
      forPKC12Data:certData
    withPassphrase:@"test"];
    
    NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identity
                                                             certificates:@[(__bridge id)certificate] persistence:NSURLCredentialPersistencePermanent];
    if (credential)
    {
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }else
    {
        NSLog(@"Error in credential");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    NSLog(@"Success....");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"string %@ ",string);
    
    [self parseresponseData:data];
    
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error.code == -1009) {
        [self.pExpireLabel setText:@"Please check Internet connection."];
        [self.pExpireLabel setAlpha:1];
    }
    NSLog(@"Errorror %@", error);
}

- (void)parseresponseData:(NSData *)data
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSLog(@"%@",json);
    NSInteger dayLeftToExpire = [json[@"password-expires-days"] integerValue];
    [self animateIndicatorTo:dayLeftToExpire];
}

- (void)animateIndicatorTo:(NSInteger)days
{
    CGFloat animationDuration = 1;
    if (days <= 44)
    {
        animationDuration = 0.2;
    }else if (days <= 90)
    {
        animationDuration = 0.5;
    }else if (days <= 134)
    {
        animationDuration = 0.7;
    }else
    {
        animationDuration = 1.0;
    }
    
    NSLog(@"%li", days/4);
    [self.passwordProgress setBackgroundImageNamed:@"singleArc"];
    [self.passwordProgress startAnimatingWithImagesInRange:NSMakeRange(0, days/4) duration:animationDuration repeatCount:1];
    
    [self.pDaysLabel setText:[NSString stringWithFormat:@"%li", (long)days]];
    [self.pExpireLabel setAlpha:1];
}

@end



