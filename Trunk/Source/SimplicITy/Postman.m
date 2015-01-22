//
//  Postman.m
//  EuLux
//
//  Created by Varghese Simon on 3/3/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "Postman.h"
#import "CustomAFRequestOperationManager.h"

@implementation Postman
{
    AFHTTPRequestOperationManager *manager;
    NSURLCredential *credential;
}

- (id)init
{
    if (self = [super init])
    {
        [self initiate];
    }
    
    return self;
}

- (void)initiate
{
    manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [requestSerializer setValue:@"G800189" forHTTPHeaderField:@"x-cropid"];
    [requestSerializer setValue:@"test.mailadminbraexcap0112@ucb.com" forHTTPHeaderField:@"x-emailid"];
    [requestSerializer setValue:@"test" forHTTPHeaderField:@"x-name"];
    [requestSerializer setValue:@"dnpnl4jjg5mf" forHTTPHeaderField:@"x-deviceserialno"];
    [requestSerializer setValue:@"ind" forHTTPHeaderField:@"x-region"];
    [requestSerializer setValue:@"iOS" forHTTPHeaderField:@"x-referer"];

    manager.requestSerializer = requestSerializer;
//    NSLog(@"headers %@", requestSerializer.HTTPRequestHeaders);
}

- (void)post:(NSString *)URLString withParameters:(NSString *)parameter
{
    NSLog(@"parameters = %@", parameter);
    NSDictionary *parameterDict = [NSJSONSerialization JSONObjectWithData:[parameter dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    [manager POST:URLString
       parameters:parameterDict
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              NSData *responseData = [operation responseData];
              [self.delegate postman:self gotSuccess:responseData forURL:URLString];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self.delegate postman:self gotFailure:error forURL:URLString];
              NSLog(@"ERROR %@",[operation responseString]);
          }];
    

}

- (void)get:(NSString *)URLString
{
    [manager GET:URLString
      parameters:Nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSData *responseData = [operation responseData];
             [self.delegate postman:self gotSuccess:responseData forURL:URLString] ;
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             [self.delegate postman:self gotFailure:error forURL:URLString];
             NSLog(@"ERROR %@",[operation responseString]);
             
         }];
}

- (void)UCB_post:(NSString *)URLString withParameters:(NSString *)parameter
{
    if (!credential)
    {
        credential = [self createCredential];
    }
    
    manager.credential = credential;
    
    NSDictionary *parameterDict = [NSJSONSerialization JSONObjectWithData:[parameter dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
//    [manager POST:URLString
//       parameters:parameterDict
//          success:^(AFHTTPRequestOperation *operation, id responseObject){
//              NSData *responseData = [operation responseData];
//              [self.delegate postman:self gotSuccess:responseData forURL:URLString];
//          }
//          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//              [self.delegate postman:self gotFailure:error forURL:URLString];
//              NSLog(@"ERROR %@",[operation responseString]);
//          }];
    
    NSString *urlString = [@"https://simplicity-dev.ucb.com/ad/account-status/id/" stringByAppendingFormat:@"G800189"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];

    [manager HTTPRequestOperationWithRequest:req
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         
                                         NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                         
                                         NSLog(@"%@", string);
                                         
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         
                                         NSLog(@"ERROR %@", operation);
                                         
                                     }];
}

- (NSURLCredential *)createCredential
{
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"p12"];
    NSData *certData = [[NSData alloc] initWithContentsOfFile:certPath];
    
    SecIdentityRef identity = NULL;
    SecCertificateRef certificate = NULL;
    
    [Postman identity:&identity
       andCertificate:&certificate
         forPKC12Data:certData
       withPassphrase:@"test"];
    
    NSURLCredential *cred = [NSURLCredential credentialWithIdentity:identity
                                                       certificates:@[(__bridge id)certificate]
                                                        persistence:NSURLCredentialPersistencePermanent];
    return cred;
}

+ (void)identity:(SecIdentityRef *)identity andCertificate:(SecCertificateRef *)certificate forPKC12Data:(NSData *)certData withPassphrase:(NSString *)passphrase
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
