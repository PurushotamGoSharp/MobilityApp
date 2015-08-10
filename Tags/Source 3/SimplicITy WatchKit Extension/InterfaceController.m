//
//  InterfaceController.m
//  SimplicITy WatchKit Extension
//
//  Created by Vmoksha on 05/08/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "InterfaceController.h"
#import "UserInfo.h"
#import "ADExpirationViewController.h"



#define DAYS_LEFT_FOR_PASSWORD_EXPIRES @"DaysLeftForPasswordExpairs"
#define IPHONE_6_CROPID  @""


int currentValue;
bool shouldStopCountDown;




@interface InterfaceController() <NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *numOfDaysLeftLbl;



@end


@implementation InterfaceController













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
    
    
    
}

-(void)parseresponseData:(NSData *)data
{
    
    
    NSDate *currentDate = [NSDate date];
    
    //    NSCalendar *cal = [NSCalendar currentCalendar];
    //    NSLog(@"%@", [NSTimeZone knownTimeZoneNames]);
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSLog(@"%@",json);
    
    NSString *dateInString = json[@"password-expires"];
    
    NSDate *passwordExpiresDate = [formater dateFromString:dateInString];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:currentDate toDate:passwordExpiresDate options:0];
    
    NSLog(@"Password Expires Date is %@ and current Date is %@",passwordExpiresDate,currentDate);
    
    NSLog(@"The difference between from date and to date is %ld days and %ld hours and %ld minute and %ld second",(long)components.day,(long)components.hour,(long)components.minute,(long)components.second);
    
    NSInteger daysLeft =  MAX(0, components.day);
    NSLog(@"%li",(long)daysLeft);
    
    self.numOfDaysLeftLbl.text = [NSString stringWithFormat:@"%li",(long)daysLeft];
    
    //    [[NSUserDefaults standardUserDefaults] setObject:self.numOfDaysLeftLbl.text forKey:DAYS_LEFT_FOR_PASSWORD_EXPIRES];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
}


//- (IBAction)paswordSelfServiceBtnPressed:(id)sender
//{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mdm2.ucb.com/psynch/docs/en-us/indexf.html"]];
//}




- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    
    //    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    //    {
    //        NSDictionary *serverConfig;
    //
    //        serverConfig = [[UserInfo sharedUserInfo] getServerConfig];
    //        NSString *cropID;
    //        NSString *urlString;
    //        if (serverConfig != nil)
    //        {
    //            cropID = (NSString *)serverConfig[@"corpID"];
    //            urlString = [LDAP_URL stringByAppendingString:cropID];
    //        }else
    //        {
    //            urlString = [LDAP_URL stringByAppendingString:IPHONE_6_CROPID];
    //        }
    //
    //        NSURL *url = [NSURL URLWithString:urlString];
    //        NSURLRequest *req = [NSURLRequest requestWithURL:url];
    //
    //        NSURLConnection *connections = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    //
    //
    //    }
    //    else
    //    {
    //        self.numOfDaysLeftLbl.text = [[NSUserDefaults standardUserDefaults] objectForKey:DAYS_LEFT_FOR_PASSWORD_EXPIRES];
    //
    //        //        UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:@"Warning !" message:@"The device is not connected to internet. For checking \"Days Left  for Password Expiry\" Internet connection is required" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //        //        [noNetworkAlert show];
    //
    //
    //
    //    }
    
    
    
    //    _passwordProgress.setBackgroundImageNamed("singleArc")
    //    passwordProgress.startAnimatingWithImagesInRange(NSMakeRange(0, 101), duration: duration, repeatCount: 1)
    
    
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    NSLog(@"AppleInterface Watch Is Activated/...........");
    
    
    [self performSelector:@selector(animateToProgress) withObject:nil afterDelay:.2];
    
    
    
    
}

- (void)animateToProgress
{
    [self.passwordProgress setBackgroundImageNamed:@"singleArc"];
    [self.passwordProgress startAnimatingWithImagesInRange:NSMakeRange(0, 45) duration:1 repeatCount:1];
    
    
    
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    
    NSLog(@"AppleInterface Watch Is DeActivated/...........");
}

@end



