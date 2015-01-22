//
//  SendRequestsManager.m
//  SimplicITy
//
//  Created by Varghese Simon on 1/22/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "SendRequestsManager.h"
#import <AFNetworking/AFNetworking.h>
#import "DBManager.h"
#import "RequestModel.h"
#import "Postman.h"

@interface SendRequestsManager () <DBManagerDelegate, postmanDelegate>

@end

@implementation SendRequestsManager
{
    DBManager *dbManager;
//    NSDateFormatter *dateFormatter;
    NSMutableArray *arrayOfRequestsToBeSend;
    NSArray *statusArray;
    
    Postman *postman;
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
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        [self networkStatusChanged:status];
        
    }];
    
    statusArray = @[@"low", @"medium", @"high", @"critical"];
    
    postman = [[Postman alloc] init];
    postman.delegate = self;
    
//    dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"hh:mm a, dd MMM, yyyy"];
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
    
    [arrayOfRequestsToBeSend removeAllObjects];
    
    NSString *queryString =  @"SELECT * FROM raisedTickets where syncFlag = 0";
    [dbManager getDataForQuery:queryString];

//    queryString =  @"SELECT * FROM raisedOrders where syncFlag = 1";
//    [dbManager getDataForQuery:queryString];
    
    [self startSendingRequests];
}



- (void)startSendingRequests
{
    //Get background queue and call methods one after another (synchronously)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (RequestModel *aRequest in arrayOfRequestsToBeSend)
        {
            [self sendRequestSyncronouslyForRequest:aRequest];
        }
        
    });
}

- (void)sendRequestSyncronouslyForRequest:(RequestModel *)requestModel
{
    NSData *parameter = [self parameterForRequest:requestModel];
    NSURL *URL = [NSURL URLWithString:RAISE_A_TICKET_API];
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL];
    [URLRequest setHTTPMethod:@"POST"];
    [URLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [URLRequest setHTTPBody:parameter];
    
    NSURLResponse *URLresponse = nil;
    NSError *error = nil;
    
    NSData *responseData =[NSURLConnection sendSynchronousRequest:URLRequest
                                                returningResponse:&URLresponse
                                                            error:&error];
    if (error != nil)
    {
        if (responseData)
        {
            NSError *JSONError;
            NSDictionary *JSONDict =[NSJSONSerialization JSONObjectWithData:responseData
                                                                    options:kNilOptions
                                                                      error:&JSONError];
            if (JSONError != nil)
            {
                NSString *incidentNo = JSONDict[@"Incident_Number"];
                
                if (incidentNo != nil)
                {
                    requestModel.requestIncidentNo = incidentNo;
                    [self updateLocalDBForRequest:requestModel];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self updateUI];
                        
                    });
                    
                }else
                {
                    NSLog(@"Error: Inident no is nil");
                }
            }else
            {
                NSLog(@"JSON parsing error");
            }
        }
        
    }else
    {
        NSLog(@"Failure for %@", [[NSString alloc] initWithData:parameter
                                                       encoding:NSUTF8StringEncoding]);
    }
}

- (void)updateLocalDBForRequest:(RequestModel *)requestModel
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate = self;
    }
    
    NSString *insertSQL = [NSString stringWithFormat:@"UPDATE raisedTickets SET syncFlag = 1, incidentNumber = '%@' WHERE  loaclID = %li", requestModel.requestIncidentNo, (long)requestModel.requestLocalID];

    [dbManager saveDataToDBForQuery:insertSQL];
}

- (void)updateUI
{
    
}

- (NSData *)parameterForRequest:(RequestModel *)request
{
    if (request == nil)
    {
        return nil;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"firstName"] = @"Marc";
    dict[@"lastName"] = @"Van Cutsem";
    dict[@"impact"] = statusArray[request.requestImpact];
    dict[@"service"] = @"mobility";
    dict[@"description"] = request.requestDetails;
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:kNilOptions
                                                         error:nil];
    
    return JSONData;
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
        
        //        NSString *dateInString = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 5)];
        //        request.requestDate = [dateFormatter dateFromString:dateInString];
        [arrayOfRequestsToBeSend addObject:request];
    }
}

#pragma mark
#pragma mark DBManagerDelegate
- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    
}

@end
