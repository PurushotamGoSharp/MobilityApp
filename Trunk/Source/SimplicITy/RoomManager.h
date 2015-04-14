//
//  RoomManager.h
//  SimplicITy
//
//  Created by Varghese Simon on 3/25/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RoomManager;
@class CalendarEvent;

@protocol RoomManagerDelegate <NSObject>

@optional
- (void)roomManager:(RoomManager *)manager foundAvailableRooms:(NSArray *)availableRooms;
- (void)roomManager:(RoomManager *)manager foundSlotsAvailable:(NSDictionary *)dictOfAllRooms;

- (void)roomManager:(RoomManager *)manager FoundRooms:(NSArray *)rooms;

- (void)roomManager:(RoomManager *)manager createdRoomWith:(NSString *)eventID;

- (void)roomManager:(RoomManager *)manager successfullYGotContacts:(NSArray *)foundContacts;

- (void)roomManager:(RoomManager *)manager failedWithError:(NSError *)error;

@end

@interface RoomManager : NSObject

@property (weak, nonatomic) id <RoomManagerDelegate> delegate;

- (void)reloadList; // this will call required APIs and update the list
- (NSArray *)getCompleteRoomsList; //call reload before this method is called
- (void)getRoomsForRoomList:(NSString *)emailID;
- (void)availablityOfRooms:(NSArray *)rooms forStart:(NSDate *)startDate toEnd:(NSDate *)endDate;

- (void)createCalendarEvent:(CalendarEvent *)event;

//- (void)getContactsForEntry:(NSString *)entry withSuccess:(void (^)(BOOL foundContacts ,NSArray *contactsFound))success;
- (void)getContactsForEntry:(NSString *)entry;

@end
