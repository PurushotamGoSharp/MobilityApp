//
//  RoomManager.h
//  SimplicITy
//
//  Created by Varghese Simon on 3/25/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RoomManager;

@protocol RoomManagerDelegate <NSObject>

- (void)roomManager:(RoomManager *)manager foundAvailableRooms:(NSArray *)availableRooms;
- (void)roomManager:(RoomManager *)manager failedWithError:(NSError *)error;

- (void)roomManager:(RoomManager *)manager FoundRooms:(NSArray *)rooms;

@end

@interface RoomManager : NSObject

@property (weak, nonatomic) id <RoomManagerDelegate> delegate;

- (void)reloadList; // this will call required APIs and update the list
- (NSArray *)getCompleteRoomsList; //call reload before this method is called
- (void)getRoomsForRoomList:(NSString *)emailID;
- (void)availablityOfRooms:(NSArray *)rooms forStart:(NSDate *)startDate toEnd:(NSDate *)endDate;


@end
