//
//  ESWRoomManager.m
//  SimplicITy
//
//  Created by Varghese Simon on 3/25/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "ESWRoomManager.h"
#import "ExchangeWebService.h"
#import "RoomModel.h"

@interface ESWRoomManager() <SSLCredentialsManaging>

@end

@implementation ESWRoomManager 
{
    NSMutableArray *roomsListsArray;
    ExchangeWebService_ExchangeServiceBinding *binding;
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
    binding  = [[ExchangeWebService ExchangeServiceBinding] initWithAddress:EWS_REQUSET_URL];
    
    binding.logXMLInOut = YES;
    
    t_ElementRequestServerVersion *serverVersion = [[t_ElementRequestServerVersion alloc] init];
    serverVersion.Version = t_ExchangeVersionType_Exchange2010_SP2;
    binding.RequestServerVersionHeader = serverVersion;
    binding.sslManager = self;
}

- (void)getRoomsList
{
    ExchangeWebService_GetRoomListsType *request = [[ExchangeWebService_GetRoomListsType alloc] init];

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
            roomsListsArray = [[NSMutableArray alloc] init];
            
            ExchangeWebService_GetRoomListsResponseMessageType *roomListsObj = (ExchangeWebService_GetRoomListsResponseMessageType *)resp;
            
            NSArray *arrayOfListRooms = roomListsObj.RoomLists;
//Here we will be getting List of List of Rooms. eg) We will be getting List of location and a Location will have list of rooms.
//After getting  List of list of Rooms, we have to call the API with EMAIL ID of LIST to get the list of ROOMS of that particular LIST
            
            for (t_EmailAddressType *anEmailIDObj in arrayOfListRooms)
            {
                [roomsListsArray addObject:anEmailIDObj];
            }
            
            [self.delegate ESWRoomManager:self foundListsOfRooms:roomsListsArray];
//            [self getRoomsForRoomsLists:roomsListsArray];
        }
    }
}

- (void)getRoomsForRoomsLists:(NSArray *)roomListsList
{
    for (t_EmailAddressType *anEmailID in roomListsList)
    {
        [self getRoomsForRoomList:anEmailID];
    }
}

- (void)getRoomsForRoomList:(t_EmailAddressType *)emailID
{
    ExchangeWebService_GetRoomsType *requestRooms = [[ExchangeWebService_GetRoomsType alloc] init];
    requestRooms.RoomList = emailID;
    
    [binding GetRooms:requestRooms
              success:^(NSArray *headers, NSArray *bodyParts) {
                  
                  for (id resp in bodyParts)
                  {
                      if ([resp isKindOfClass:[ExchangeWebService_GetRoomsResponseMessageType class]])
                      {
                          ExchangeWebService_GetRoomsResponseMessageType *roomsListObj = (ExchangeWebService_GetRoomsResponseMessageType *)resp;
                          
                          for (t_RoomType *aRoom in roomsListObj.Rooms)
                          {
                              RoomModel *roomModel = [[RoomModel alloc] init];
                              roomModel.nameOfRoom = aRoom.Id.Name;
                              roomModel.emailIDOfRoom = aRoom.Id.EmailAddress;
                              roomModel.emailIDEWS = aRoom.Id;
                          }
                          
                          [self.delegate ESWRoomManager:self FoundRooms:roomsListsArray];
                      }
                  }
              } error:^(NSError *error) {
                  
              }];
    
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
