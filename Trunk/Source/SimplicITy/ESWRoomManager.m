//
//  ESWRoomManager.m
//  SimplicITy
//
//  Created by Varghese Simon on 3/25/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "ESWRoomManager.h"
#import "ExchangeWebService.h"
#import "ESWPropertyCreater.h"
#import "RoomModel.h"

@interface ESWRoomManager() <SSLCredentialsManaging>

@end

@implementation ESWRoomManager 
{
    NSMutableArray *roomArray;
}

- (instancetype)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

- (void)getRoomsList
{
    ExchangeWebService_ExchangeServiceBinding *binding  = [[ExchangeWebService ExchangeServiceBinding] initWithAddress:@"https://10.10.3.162/EWS/exchange.asmx"];
    
    binding.logXMLInOut = YES;
    //    BasicSSLCredentialsManager *credentailsManager = [BasicSSLCredentialsManager managerWithUsername:@"sundar@vmex.com" andPassword:@"Power@1234"];
    //    binding.sslManager = credentailsManager;
    
    t_ElementRequestServerVersion *serverVersion = [[t_ElementRequestServerVersion alloc] init];
    serverVersion.Version = t_ExchangeVersionType_Exchange2010_SP2;
    binding.RequestServerVersionHeader = serverVersion;
    binding.sslManager = self;
    ExchangeWebService_GetRoomListsType *request = [[ExchangeWebService_GetRoomListsType alloc] init];
    
//    ExchangeWebService_ExchangeServiceBindingResponse *response = [binding GetRoomLists:request];
    
    [binding GetRoomLists:request
                  success:^(NSArray *headers, NSArray *bodyParts) {
                      
                      [self createRoomListForResponse:bodyParts];
                      
                  } error:^(NSError *error) {
                      
                      NSLog(@"Get Room List Error: %@", error);
                      
                  }];
}

- (void)createRoomListForResponse:(NSArray *)bodyParts
{
    for (id resp in bodyParts)
    {
        if ([resp isKindOfClass:[ExchangeWebService_GetRoomListsResponseMessageType class]])
        {
            NSLog(@"Yes...");
            roomArray = [[NSMutableArray alloc] init];
            
            ExchangeWebService_GetRoomListsResponseMessageType *roomListsObj = (ExchangeWebService_GetRoomListsResponseMessageType *)resp;
            NSArray *arrayOfRooms = roomListsObj.RoomLists;
            
            for (t_EmailAddressType *anEmailIDObj in arrayOfRooms)
            {
                RoomModel *roomDetails = [[RoomModel alloc] init];
                roomDetails.nameOfRoom = anEmailIDObj.Name;
                roomDetails.emailIDOfRoom = anEmailIDObj.EmailAddress;
                [roomArray addObject:roomDetails];
            }
            
            [self.delegate ESWRoomManager:self FoundRooms:roomArray];
        }
    }
}

- (BOOL)canAuthenticateForAuthenticationMethod:(NSString *)authMethod
{
    return YES;
}

- (BOOL)authenticateForChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLCredential *newCredential = [NSURLCredential
                                      credentialWithUser:@"sundar@vmex.com"
                                      password:@"Power@1234"
                                      persistence:NSURLCredentialPersistenceForSession];
    
    [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    
    return YES;
}

@end
