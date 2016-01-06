//
//  RoomBeacon.h
//  SimplicITy
//
//  Created by Varghese Simon on 5/7/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomBeacon : NSObject

@property (strong, nonatomic) NSString *uniqueID;

@property (strong, nonatomic) NSString *beaconID;
@property (assign, nonatomic) NSInteger majorID;
@property (assign, nonatomic) NSInteger minorID;

@property (assign, nonatomic) BOOL updating;

@property (assign, nonatomic) NSInteger RSSIValue; //RSSI value is negative. So instead of zero value, we have to give NSIntegerMin

@property (strong, nonatomic) NSMutableArray *roomsAssociated;

@end
