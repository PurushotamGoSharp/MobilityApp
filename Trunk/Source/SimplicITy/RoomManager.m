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
    
//    recognizer = [RoomRecognizer sharedRecognizer];
    
    ewsManager =[[ESWRoomManager alloc] init];
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
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"emailIDOfRoom == %@", recognizedRoom.emailIDOfRoom];
                NSArray *filteredArray = [listOfRooms filteredArrayUsingPredicate:predicate];
                if (filteredArray.count > 0)
                {
                    NSInteger indexOfObj = [listOfRooms indexOfObject:[filteredArray firstObject]];
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


#pragma mark
#pragma mark ESWRoomManagerDelegate
- (void)ESWRoomManager:(ESWRoomManager *)manager FoundRooms:(NSArray *)rooms
{
//    [listOfRooms removeAllObjects];
//    [listOfRooms addObjectsFromArray:rooms];
//    
//    [self updateModelsWithBeaconValue];
    [self.delegate roomManager:self FoundRooms:rooms];
}

- (void)ESWRoomManager:(ESWRoomManager *)manager failedWithError:(NSError *)error
{
    [self.delegate roomManager:self failedWithError:error];
}

- (void)ESWRoomManager:(ESWRoomManager *)manager foundListsOfRooms:(NSArray *)rooms
{
    
}

- (void)ESWRoomManager:(ESWRoomManager *)manager foundSlotsAvailable:(NSArray *)availbleSlots For:(NSString *)room
{
    
}

- (void)ESWRoomManager:(ESWRoomManager *)manager foundAvailableRooms:(NSArray *)availableRooms
{
    [self.delegate roomManager:self foundAvailableRooms:availableRooms];
}

@end
