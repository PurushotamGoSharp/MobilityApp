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
#import "UserInfo.h"

@interface ESWRoomManager() <SSLCredentialsManaging>

@end

@implementation ESWRoomManager 
{
    NSMutableArray *roomsListsArray;
    ExchangeWebService_ExchangeServiceBinding *binding;
    ESWPropertyCreater *propertyCreater;
    
    NSDateFormatter *dateFormatter;
    
    NSString *EWSUserName, *EWSPassword;
    
    NSInteger noOfFailedAuth;
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
    NSString *ewsRequestURL = [[NSUserDefaults standardUserDefaults] objectForKey:EWS_REQUSET_URL_KEY];
    
    binding  = [[ExchangeWebService ExchangeServiceBinding] initWithAddress:ewsRequestURL];
    
    binding.logXMLInOut = YES;
    
    t_ElementRequestServerVersion *serverVersion = [[t_ElementRequestServerVersion alloc] init];
    serverVersion.Version = t_ExchangeVersionType_Exchange2010_SP2;
    binding.RequestServerVersionHeader = serverVersion;
    binding.sslManager = self;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    
    noOfFailedAuth = 0;
}

- (void)getRoomsList
{
    noOfFailedAuth = 0;
    
    ExchangeWebService_GetRoomListsType *request = [[ExchangeWebService_GetRoomListsType alloc] init];

    [binding GetRoomLists:request
                  success:^(NSArray *headers, NSArray *bodyParts) {
                      
                      [self createRoomListForResponse:bodyParts];
                      
                  } error:^(NSError *error) {
                      
                      NSLog(@"Get Room List Error: %@", error);
                      
                  }];
}

- (BOOL)getUserNameAndPasswordForEWS
{
//    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:EWS_USER_NAME];
    NSString *userName = [UserInfo sharedUserInfo].cropID;
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:EWS_USERS_PASSWORD];
    
    if (userName == nil | password == nil)
    {
        return NO;
    }
    
    EWSUserName = userName;
    EWSPassword = password;
    return YES;
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
    noOfFailedAuth = 0;

    ExchangeWebService_GetRoomsType *requestRooms = [[ExchangeWebService_GetRoomsType alloc] init];
    requestRooms.RoomList = emailID;
    
    roomsListsArray = [[ NSMutableArray alloc] init];
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
                              roomModel.nameOfRoom = [self nameOfRoomAfterRemovingCountryCode:aRoom.Id.Name];
                              roomModel.emailIDOfRoom = aRoom.Id.EmailAddress;
                              roomModel.emailIDEWS = aRoom.Id;
                              
                              [roomsListsArray addObject:roomModel];
                          }
                          
                          [self.delegate ESWRoomManager:self FoundRooms:roomsListsArray];
                      }
                  }
              } error:^(NSError *error) {
                  
                  [self.delegate ESWRoomManager:self failedWithError:error];

              }];
    
}

- (NSString *)nameOfRoomAfterRemovingCountryCode:(NSString *)initialRoomName
{
//For UCB first 8 letter will represent location eg)"* BLR - KRISHNA - Board Room" . We are removing this to get actual name of rooms
    NSRange firstOccurance = [initialRoomName rangeOfString:@" - "];
    NSRange rangeToBeRemove;
    rangeToBeRemove.location = 0;
    rangeToBeRemove.length = firstOccurance.location + firstOccurance.length;
    
    if (rangeToBeRemove.location == NSNotFound)
    {
        return initialRoomName;
    }
    
    return [[initialRoomName mutableCopy] stringByReplacingCharactersInRange:rangeToBeRemove withString:@""];
}

- (void)findEventForRoom:(NSString *)room forDate:(NSDate *)requestedDate
{
    if (propertyCreater == nil)
    {
        propertyCreater = [[ESWPropertyCreater alloc] init];
    }
    
    noOfFailedAuth = 0;

    ExchangeWebService_GetUserAvailabilityRequestType *request = [[ExchangeWebService_GetUserAvailabilityRequestType alloc] init];
    request.TimeZone = [propertyCreater timeZone];
    request.MailboxDataArray = [propertyCreater mailBoxArrayWithEmailIDS:@[room]];
    //Converting in to ONE day window. First create START DATE and add one day to it to create END DATE
    
    [dateFormatter setDateFormat:@"yyyy MM dd"];//removes time and only get date;
    NSString *dateInString = [dateFormatter stringFromDate:requestedDate];
    NSDate *startDate = [dateFormatter dateFromString:dateInString];
    NSDate *endDate = [NSDate dateWithTimeInterval:60*60*24 sinceDate:startDate];
    
    request.FreeBusyViewOptions = [propertyCreater freeBusyViewOptionsWith:startDate andEndsAt:endDate];
    
    
    [binding GetUserAvailabilityUsingGetUserAvailabilityRequest:request success:^(NSArray *headers, NSArray *bodyParts) {
        
        for (id resp in bodyParts)
        {
            if ([resp isKindOfClass:[ExchangeWebService_GetUserAvailabilityResponseType class]])
            {
                ExchangeWebService_GetUserAvailabilityResponseType *availabilityResp = (ExchangeWebService_GetUserAvailabilityResponseType *)resp;
                
                NSArray *freeBusyArray = availabilityResp.FreeBusyResponseArray;
//#warning Not using loop.
//                ExchangeWebService_FreeBusyResponseType *freeBusyResponse = [freeBusyArray firstObject];
//                NSArray *calenderEvents = freeBusyResponse.FreeBusyView.CalendarEventArray;
            }
        }
        
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)availablityOfRooms:(NSArray *)rooms forStart:(NSDate *)startDate toEnd:(NSDate *)endDate
{
    __block NSMutableArray *availableRooms;

    if (rooms.count == 0 | rooms == nil)
    {
        
        NSLog(@"There should be atleast one room in the list");
        return;
    }
    
    noOfFailedAuth = 0;

    if (propertyCreater == nil)
    {
        propertyCreater = [[ESWPropertyCreater alloc] init];
    }
    ExchangeWebService_GetUserAvailabilityRequestType *request = [[ExchangeWebService_GetUserAvailabilityRequestType alloc] init];
    request.TimeZone = [propertyCreater timeZone];
    request.MailboxDataArray = [propertyCreater mailBoxArrayWithEmailIDS:rooms];
    request.FreeBusyViewOptions = [propertyCreater freeBusyViewOptionsWith:startDate andEndsAt:endDate];
    
    [binding GetUserAvailabilityUsingGetUserAvailabilityRequest:request success:^(NSArray *headers, NSArray *bodyParts) {
        
        for (id resp in bodyParts)
        {
            if ([resp isKindOfClass:[ExchangeWebService_GetUserAvailabilityResponseType class]])
            {
                ExchangeWebService_GetUserAvailabilityResponseType *availabilityResp = (ExchangeWebService_GetUserAvailabilityResponseType *)resp;
                
                NSArray *freeBusyArray = availabilityResp.FreeBusyResponseArray;
                availableRooms = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < freeBusyArray.count; i++)
                {
                    ExchangeWebService_FreeBusyResponseType *freeBusyResponse = freeBusyArray[i];
                    NSArray *calenderEvents = freeBusyResponse.FreeBusyView.CalendarEventArray;
                    
                    //If there is no calender events in the response, then that room is available for that time.
                    if (calenderEvents == nil | calenderEvents.count == 0)
                    {
                        [availableRooms addObject:rooms[i]];
                    }else
                    {
                        //Even canceled events will be returned in EVENTS_ARRAY with status as FREE. And if all events are FREE, that room is free for appoinment.
                        BOOL allAreCanceledEvents = YES;
                        for (t_CalendarEvent *anEvent in calenderEvents)
                        {
                            if (anEvent.BusyType != t_LegacyFreeBusyType_Free)
                            {
                                allAreCanceledEvents = NO;
                                break;
                            }
                        }
                        
                        if (allAreCanceledEvents)
                        {
                            [availableRooms addObject:rooms[i]];
                        }
                    }
                    
                }
                
                [self.delegate ESWRoomManager:self foundAvailableRooms:availableRooms];
            }
        }
        
        NSLog(@"Available Rooms %@", availableRooms);
        
    } error:^(NSError *error) {
        
        [self.delegate ESWRoomManager:self failedWithError:error];
        NSLog(@"%@", error);
    }];

}

- (BOOL)canAuthenticateForAuthenticationMethod:(NSString *)authMethod
{
    return YES;
}

- (BOOL)authenticateForChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (![self getUserNameAndPasswordForEWS])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Please enter Password in settings page"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
        
        [self.delegate ESWRoomManager:self failedWithError:nil];

        return NO;
    }

//This method will be called TWO times for proper Credentials. BUT it will be called COUNTINOUSLY (INFINTE TIMES) is credentials are WRONG.
    if (noOfFailedAuth > 1)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Please check Password given in settings page"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
        
        [self.delegate ESWRoomManager:self failedWithError:nil];

        return NO;
    }
    
    NSLog(@"Auth called");
    
    NSURLCredential *newCredential = [NSURLCredential
                                      credentialWithUser:EWSUserName
                                      password:EWSPassword
                                      persistence:NSURLCredentialPersistenceForSession];
    
    [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    
    noOfFailedAuth++;
    return YES;
}

@end
