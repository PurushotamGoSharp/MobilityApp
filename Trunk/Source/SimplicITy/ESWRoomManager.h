//
//  ESWRoomManager.h
//  SimplicITy
//
//  Created by Varghese Simon on 3/25/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ESWRoomManager;

@protocol ESWRoomManagerDelegate <NSObject>

- (void)ESWRoomManager:(ESWRoomManager *)manager FoundRooms:(NSArray *)rooms;

@end

@interface ESWRoomManager : NSObject 

@property (weak, nonatomic) id<ESWRoomManagerDelegate> delegate;

- (void)getRoomsList;

@end
