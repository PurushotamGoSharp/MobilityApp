//
//  RoomManager.m
//  SimplicITy
//
//  Created by Varghese Simon on 3/25/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "RoomManager.h"
#import "ESWRoomManager.h"

@interface RoomManager ()<ESWRoomManagerDelegate>

@end

@implementation RoomManager
{
    ESWRoomManager *ewsManager;
    NSMutableArray *completeRoomsList;
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
    completeRoomsList = [[NSMutableArray alloc] init];
    
    ewsManager =[[ESWRoomManager alloc] init];
    ewsManager.delegate = self;
}

- (void)reloadList
{
    [ewsManager getRoomsList];
}

- (NSArray *)getCompleteRoomsList
{
    return completeRoomsList;
}

- (void)ESWRoomManager:(ESWRoomManager *)manager FoundRooms:(NSArray *)rooms
{
    [completeRoomsList removeAllObjects];
    
    [completeRoomsList addObjectsFromArray:rooms];
    
}

@end
