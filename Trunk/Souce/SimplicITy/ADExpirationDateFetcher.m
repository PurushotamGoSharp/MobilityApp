//
//  ADExpirationDateFetcher.m
//  SimplicITy
//
//  Created by Varghese Simon on 4/9/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "ADExpirationDateFetcher.h"
#import "UserInfo.h"
#import "NSDateFormatter+Locale.h"

@implementation ADExpirationDateFetcher
{
    NSOperationQueue *operationQueue;
    NSDateFormatter *formater;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    operationQueue = [[NSOperationQueue alloc] init];
//    [operationQueue setMaxConcurrentOperationCount:1];

}


- (void)getExpirationDateWithSuccess:(void (^)(NSInteger))success
{
    NSString *cropID = [UserInfo sharedUserInfo].cropID;
    NSString *urlString = [LDAP_URL stringByAppendingString:cropID];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *JSONDict =[NSJSONSerialization JSONObjectWithData:responseObject
                                                                options:kNilOptions
                                                                  error:nil];
        
        NSLog(@"%@", JSONDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    [self setAuthenticationBlockForOperation:operation];
    [operationQueue addOperation:operation];
}
- (void)getExpirationDateForURL:(NSString *)urlString withSuccess:(void (^)(NSInteger))success
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *JSONDict =[NSJSONSerialization JSONObjectWithData:responseObject
                                                                options:kNilOptions
                                                                  error:nil];
        
        NSLog(@"%@", JSONDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    [self setAuthenticationBlockForOperation:operation];
    [operationQueue addOperation:operation];
}

- (void)setAuthenticationBlockForOperation:(AFHTTPRequestOperation *)operation
{
    [operation setWillSendRequestForAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
        
        NSLog(@"Authe type = %@ for %@", challenge.protectionSpace.authenticationMethod, [connection.originalRequest.URL absoluteString]);

        NSString *certPath = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"p12"];
        NSData *certData = [[NSData alloc] initWithContentsOfFile:certPath];
        
        SecIdentityRef identity = NULL;
        SecCertificateRef certificate = NULL;
        
        [self identity:&identity
        andCertificate:&certificate
          forPKC12Data:certData
        withPassphrase:@"test"];
        
        NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identity
                                                                 certificates:@[(__bridge id)certificate]
                                                                  persistence:NSURLCredentialPersistencePermanent];
        if (credential)
        {
            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        }else
        {
            NSLog(@"Error in credential");
        }
        
    }];
}

- (void)parseresponseData:(NSData *)data
{
    NSDate *currentDate = [NSDate date];
    
    if (formater == nil)
    {
        formater = [[NSDateFormatter alloc] initWithSafeLocale];
        [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSString *dateInString = json[@"password-expires"];
    
    NSDate *passwordExpiresDate = [formater dateFromString:dateInString];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:currentDate toDate:passwordExpiresDate options:0];
    
    NSLog(@"Password Expires Date is %@ and current Date is %@",passwordExpiresDate,currentDate);
    
    NSLog(@"The difference between from date and to date is %ld days and %ld hours and %ld minute and %ld second",(long)components.day,(long)components.hour,(long)components.minute,(long)components.second);
    
    NSInteger daysLeft =  MAX(0, components.day);
    NSLog(@"%li",(long)daysLeft);
    
//    self.numOfDaysLeftLbl.text = [NSString stringWithFormat:@"%li",(long)daysLeft];
//    
//    [[NSUserDefaults standardUserDefaults] setObject:self.numOfDaysLeftLbl.text forKey:DAYS_LEFT_FOR_PASSWORD_EXPIRES];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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

@end
