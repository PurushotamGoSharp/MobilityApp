//
//  SendRequestsManager.m
//  SimplicITy
//
//  Created by Varghese Simon on 1/22/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "SendRequestsManager.h"
//#import <AFNetworking/AFNetworking.h>
#import "DBManager.h"
#import "UserInfo.h"
#import <MBProgressHUD/MBProgressHUD.h>

#define AIRWATCH_CONFIG_ERROR @"User Details are not configured. Hence ticket can not be raised"


@interface SendRequestsManager () <DBManagerDelegate>

@end

@implementation SendRequestsManager
{
    UIAlertView *netwrokErrorAlert;
    
    DBManager *dbManager;
    NSDateFormatter *dateFormatter;
    NSMutableArray *arrayOfRequestsToBeSend;
    NSArray *statusArray;
    
    NSOperationQueue *operationQueue;
    BOOL isRaisingTicket;
}

+ (instancetype)sharedManager
{
    static SendRequestsManager *_shareManager = nil;
    static dispatch_once_t onceTocken;
    
    dispatch_once(&onceTocken, ^{
        
        _shareManager = [[SendRequestsManager alloc] init];
        
    });
    
    return _shareManager;
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
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
    {        
        [self networkStatusChanged:status];
      
    }];
    
    statusArray = @[@"low", @"medium", @"high", @"critical"];
        
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    
    dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"hh:mm a, dd MMM, yyyy"];
    
    [dateFormatter setDateFormat:@"yyyy MM dd hh mm ss a"];

}

- (void)networkStatusChanged:(AFNetworkReachabilityStatus)status
{
    if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN)
    {
        [self sendRequestsToServer];
    }
}

- (void)sendRequestsToServer
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate = self;
    }
    
    if (operationQueue)
    {
        [operationQueue cancelAllOperations];
    }
    
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    
    if (arrayOfRequestsToBeSend)
    {
        [arrayOfRequestsToBeSend removeAllObjects];
    }else
    {
        arrayOfRequestsToBeSend = [[NSMutableArray alloc] init];
    }
    
    [self getNonSyncedTicketsFromLocal];
    [self getNonSyncedOrdersFromLocal];
    
    [self authenticateServer];
    [self startSendingRequests];
}

- (void)getNonSyncedTicketsFromLocal
{
    isRaisingTicket = YES;
    NSString *queryString =  @"SELECT * FROM raisedTickets where syncFlag = 0";
    [dbManager getDataForQuery:queryString];
}

- (void)getNonSyncedOrdersFromLocal
{
    isRaisingTicket = NO;
    NSString *queryString =  @"SELECT * FROM raisedOrders where syncFlag = 0";
    [dbManager getDataForQuery:queryString];
}


- (void)authenticateServer
{
    NSString *urlString = ITSM_AUTH_API;
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", [operation responseString]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Failer%@", [operation responseString]);
        NSLog(@"%@", error);
        
    }];
    
    [self setAuthenticationBlockForOperation:operation];
    [operationQueue addOperation:operation];
}

- (void)startSendingRequests
{
    for (RequestModel *aRequest in arrayOfRequestsToBeSend)
    {
        [self sendRequestSyncronouslyForRequest:aRequest blockUI:NO];
    }
}

- (void)sendRequestSyncronouslyForRequest:(RequestModel *)requestModel blockUI:(BOOL)blockUI
{
    if (![AFNetworkReachabilityManager sharedManager].isReachable)
    {
        return;
    }
    
    if ([[UserInfo sharedUserInfo] getServerConfig] == nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_FOR_ALERT
                                                            message:AIRWATCH_CONFIG_ERROR
                                                           delegate:nil
                                                  cancelButtonTitle:OK_FOR_ALERT
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (blockUI)
    {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:NO];
    }
    
    NSURL *URL;
    
    if ([requestModel.requestType isEqualToString:@"ORDER"])
    {
        URL = [NSURL URLWithString:RAISE_AN_ORDER_API];
    }else
    {
         URL = [NSURL URLWithString:RAISE_A_TICKET_API];
    }
    
    NSData *parameter = [self parameterForRequest:requestModel];
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL];
    [URLRequest setHTTPMethod:@"POST"];
    [URLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [URLRequest setHTTPBody:parameter];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:URLRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (blockUI)
        {
            [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:NO];
        }
        
        BOOL success = NO;
        
        if (responseObject)
        {
            NSError *JSONError;
            NSDictionary *JSONDict =[NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:kNilOptions
                                                                      error:&JSONError];
            if (JSONDict)
            {
                NSString *incidentNo = JSONDict[@"Incident_Number"];
                
                if (incidentNo != nil)
                {
                    success = YES;
                    NSLog(@"Incident_Number %@", incidentNo);
                    requestModel.requestIncidentNo = incidentNo;
                    [self updateLocalDBForRequest:requestModel];
                    [self updateUIWithRequest:requestModel];
                    
                }else
                {
                    NSLog(@"Error: Inident no is nil");
                }
            }else
            {
                NSLog(@"JSON parsing error %@", [[NSString alloc] initWithData:responseObject
                                                                      encoding:NSUTF8StringEncoding]);
            }
        }
        
        if (!success)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_SYNC_FAILURE_NOTIFICATION_KEY object:requestModel];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (blockUI)
        {
            [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:NO];
        }
        
        NSLog(@"Error : %@", error);
        
        NSLog(@"Error explanation = %@", [operation responseString]);
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_SYNC_FAILURE_NOTIFICATION_KEY object:requestModel];

    }];
    
    [self setAuthenticationBlockForOperation:operation];
    [operationQueue addOperation:operation];
}

-(void)getListOfTickets:(NSString *)URL // getting the list of all tickets 
{
    NSURL *url = [NSURL URLWithString:URL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData *responseData = [operation responseData];
        [self.delegate ticketLists:self gotSucess:responseData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self.delegate ticketListsFailed:self];
        
        NSLog(@"Error %@", error);
        
        if (error.code == -1009)
        {
            [self showNetworkAlert];

        }
        
        
        
    }];
    
    [self setAuthenticationBlockForOperation:operation];
    [operationQueue addOperation:operation];

}

- (void)showNetworkAlert
{
    if (netwrokErrorAlert == nil)
    {
        netwrokErrorAlert = [[UIAlertView alloc] initWithTitle:ERROR_FOR_ALERT
                                                       message:STRING_FOR_LANGUAGE(@"Contact.Administrator")
                                                      delegate:self
                                             cancelButtonTitle:OK_FOR_ALERT
                                             otherButtonTitles:nil];
    }
    
    [netwrokErrorAlert show];
}

- (void)setAuthenticationBlockForOperation:(AFHTTPRequestOperation *)operation
{
    [operation setWillSendRequestForAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
        
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

- (void)updateLocalDBForRequest:(RequestModel *)requestModel
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate = self;
    }
    
    requestModel.requestDate = [NSDate date];
    NSString *dateOfSync = [dateFormatter stringFromDate:requestModel.requestDate];
    
    NSString *insertSQL;
    if ([requestModel.requestType isEqualToString:@"ORDER"])
    {
        insertSQL = [NSString stringWithFormat:@"UPDATE raisedOrders SET syncFlag = 1, incidentNumber = '%@', date = '%@' WHERE  loaclID = %li", requestModel.requestIncidentNo, dateOfSync, (long)requestModel.requestLocalID];
    }else
    {
         insertSQL = [NSString stringWithFormat:@"UPDATE raisedTickets SET syncFlag = 1, incidentNumber = '%@', date = '%@' WHERE  loaclID = %li", requestModel.requestIncidentNo, dateOfSync, (long)requestModel.requestLocalID];
    }
    
    [dbManager saveDataToDBForQuery:insertSQL];
}

- (void)updateUIWithRequest:(RequestModel *)requestModel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_SYNC_NOTIFICATION_KEY object:requestModel];
}

- (void)updateUIForFailureWithRequest:(RequestModel *)requestModel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_SYNC_FAILURE_NOTIFICATION_KEY object:requestModel];
}

- (NSData *)parameterForRequest:(RequestModel *)request
{
    if (request == nil)
    {
        return nil;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"firstName"] = [UserInfo sharedUserInfo].firstName;
    dict[@"lastName"] = [UserInfo sharedUserInfo].lastName;
    dict[@"impact"] = statusArray[request.requestImpact];
    dict[@"service"] = request.requestServiceName;
    dict[@"description"] = request.requestDetails;
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:kNilOptions
                                                         error:nil];
    return JSONData;
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

#pragma mark
#pragma mark DBManagerDelegate
- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    while (sqlite3_step(statment) == SQLITE_ROW)
    {
        RequestModel *request = [[RequestModel alloc] init];
        
        request.requestLocalID = sqlite3_column_int(statment, 0);
        request.requestImpact = sqlite3_column_int(statment, 1);
        request.requestServiceCode = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 2)];
        request.requestServiceName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 3)];
        request.requestDetails = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 4)];
        
        if (isRaisingTicket)
        {
            request.requestType = @"TICKET";
        }else
        {
            request.requestType = @"ORDER";
        }

//        NSString *dateInString = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 5)];
//        request.requestDate = [dateFormatter dateFromString:dateInString];
        [arrayOfRequestsToBeSend addObject:request];
    }
}


@end
