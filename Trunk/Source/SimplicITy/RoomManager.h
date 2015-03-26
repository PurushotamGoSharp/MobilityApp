//
//  RoomManager.h
//  SimplicITy
//
//  Created by Varghese Simon on 3/25/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomManager : NSObject

- (void)reloadList; // this will call required APIs and update the list
- (NSArray *)getCompleteRoomsList; //call reload before this method is called

@end
