//
//  RoomManager.m
//  SimplicITy
//
//  Created by Varghese Simon on 3/25/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "RoomManager.h"
#import "ESWRoomManager.h"
#import "RoomModel.h"
#import "RoomRecognizer.h"

@interface RoomManager ()<ESWRoomManagerDelegate>

@end

@implementation RoomManager
{
    ESWRoomManager *ewsManager;
    NSMutableArray *listOfRooms, *listOfLists;
    
    RoomRecognizer *recognizer;
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
    listOfRooms = [[NSMutableArray alloc] init];
    
    recognizer = [RoomRecognizer sharedRecognizer];
//    [recognizer startRecognize];
    ewsManager = [[ESWRoomManager alloc] init];
    ewsManager.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateModelsWithBeaconValue) name:GIMBAL_CAHNGE_IN_NO_RECGNIZED_LIST object:nil];
}

- (void)reloadList
{
    [ewsManager getRoomsList];
}

- (NSArray *)getCompleteRoomsList
{
    return listOfRooms;
}



- (void)updateModelsWithBeaconValue
{
    NSArray *recognizedRooms = [recognizer recognizedRooms];
    [self replaceObjectOfCompleteListWithObjectOf:recognizedRooms];
    
    for (RoomModel *roomModel in listOfRooms)
    {
        if (![recognizedRooms containsObject:roomModel])
        {
            roomModel.RSSIValue = NSIntegerMin;
        }
    }
    
//    NSSortDescriptor *sortForRSSI = [NSSortDescriptor sortDescriptorWithKey:@"RSSIValue" ascending:NO];
//    NSSortDescriptor *sortForNameOfRoom = [NSSortDescriptor sortDescriptorWithKey:@"nameOfRoom" ascending:YES];
//    
//    [listOfRooms sortUsingDescriptors:@[sortForRSSI, sortForNameOfRoom]];
    
    if ([self.delegate respondsToSelector:@selector(roomManager:updatedRSSIValueForRooms:)])
    {
        [self.delegate roomManager:self updatedRSSIValueForRooms:listOfRooms];
    }
}

- (void)replaceObjectOfCompleteListWithObjectOf:(NSArray *)replaceArray
{
    if (replaceArray.count > 0)
    {
        for (RoomModel *recognizedRoom in replaceArray)
        {
            //We need to replace objects of completeRoomsList with objects in recognizedRooms so that we can sort according to RSSI value of room.  For that first we will find the array of rooms with same email id as that of recognized room. Then we will replace that object on completeRoomList with the recognizedRoom object.
            if (![listOfRooms containsObject:recognizedRoom])
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"emailIDOfRoom = %@", recognizedRoom.emailIDOfRoom];
                NSArray *filteredArray = [listOfRooms filteredArrayUsingPredicate:predicate];
                if (filteredArray.count > 0)
                {
                    RoomModel *roomFromEWS = [filteredArray firstObject];
                    recognizedRoom.nameOfRoom = roomFromEWS.nameOfRoom;
                    NSInteger indexOfObj = [listOfRooms indexOfObject:roomFromEWS];
                    [listOfRooms replaceObjectAtIndex:indexOfObj withObject:recognizedRoom];
                }
            }
        }
    }
}

- (void)findAvailabityOfRooms:(NSArray *)rooms forDate:(NSDate *)requestedDate
{
    
}

- (void)getRoomsForRoomList:(NSString *)emailID
{
    t_EmailAddressType *emailIDType = [[t_EmailAddressType alloc] init];
    emailIDType.EmailAddress = emailID;
    
    [ewsManager getRoomsForRoomList:emailIDType];
}

- (void)availablityOfRooms:(NSArray *)rooms forStart:(NSDate *)startDate toEnd:(NSDate *)endDate
{
    [ewsManager availablityOfRooms:rooms forStart:startDate toEnd:endDate];
}

- (void)createCalendarEvent:(CalendarEvent *)event
{
    [ewsManager createCalendarEvent:event] ;
}

- (void)getContactsForEntry:(NSString *)entry
{
    [ewsManager getContactsForEntry:entry];
}

- (void)findFreeSlotsOfRooms:(NSArray *)rooms forStart:(NSDate *)startDate toEnd:(NSDate *)endDate
{
    [ewsManager findFreeSlotsOfRooms:rooms forStart:startDate toEnd:endDate];
}

- (void)startRecognize
{
    [recognizer startRecognize];
}
- (void)stopRecognize
{
    [recognizer stopRecognize];
}

- (void)dealloc
{
    NSLog(@"Room recognizer is dealloced");
//    [recognizer stopRecognize];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GIMBAL_CAHNGE_IN_NO_RECGNIZED_LIST
                                                  object:nil];
}

#pragma mark
#pragma mark ESWRoomManagerDelegate
- (void)ESWRoomManager:(ESWRoomManager *)manager FoundRooms:(NSArray *)rooms
{
    [listOfRooms removeAllObjects];
    [listOfRooms addObjectsFromArray:rooms];
    
    [self updateModelsWithBeaconValue];
    [self.delegate roomManager:self FoundRooms:listOfRooms];
}

- (void)ESWRoomManager:(ESWRoomManager *)manager failedWithError:(NSError *)error
{
    [self.delegate roomManager:self failedWithError:error];
}

- (void)ESWRoomManager:(ESWRoomManager *)manager foundListsOfRooms:(NSArray *)rooms
{
    
}

- (void)ESWRoomManager:(ESWRoomManager *)manager foundSlotsAvailable:(NSDictionary *)dictOfAllRooms
{
    [self.delegate roomManager:self foundSlotsAvailable:dictOfAllRooms];
}

- (void)ESWRoomManager:(ESWRoomManager *)manager foundAvailableRooms:(NSArray *)availableRooms
{
    [self.delegate roomManager:self foundAvailableRooms:availableRooms];
}

- (void)ESWRoomManager:(ESWRoomManager *)manager createdRoomWith:(NSString *)eventID
{
    [self.delegate roomManager:self createdRoomWith:eventID];
}

- (void)ESWRoomManager:(ESWRoomManager *)manager successfullYGotContacts:(NSArray *)foundContacts
{
    [self.delegate roomManager:self successfullYGotContacts:foundContacts];
}

- (void)ESWRoomManager:(ESWRoomManager *)manager failedToGetPassword:(PasswordManager *)passwordManager
{
    [self.delegate roomManager:self gotPassword:passwordManager];
}

- (void)ESWRoomManager:(ESWRoomManager *)manager gotPassword:(PasswordManager *)passwordManager
{
    [self.delegate roomManager:self failedToGetPassword:passwordManager];
}

@end
