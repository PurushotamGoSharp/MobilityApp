//
//  InviteAttendeesViewController.h
//  SimplicITy
//
//  Created by Vmoksha on 06/04/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "CustomColoredViewController.h"
#import "RoomModel.h"

@interface InviteAttendeesViewController : CustomColoredViewController

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (strong, nonatomic) RoomModel *selectedRoom;

@property (assign, nonatomic) BOOL fromSelectRoomVC;

@end
