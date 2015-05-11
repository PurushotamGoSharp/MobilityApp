//
//  FreeSlotsViewController.h
//  SimplicITy
//
//  Created by Varghese Simon on 4/14/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "CustomColoredViewController.h"
@class RoomManager;

@interface FreeSlotsViewController : CustomColoredViewController

@property (strong, nonatomic) NSArray *rooms;
@property (strong, nonatomic) RoomManager *roomManager;
@end
