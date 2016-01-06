//
//  RoomBeacon.m
//  SimplicITy
//
//  Created by Varghese Simon on 5/7/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "RoomBeacon.h"

@implementation RoomBeacon

- (instancetype)init
{
    if (self = [super init])
    {
        //RSSI value is negative. So instead of zero value, we have to give NSIntegerMin
        self.RSSIValue = NSIntegerMin;
    }
    
    return self;
}

@end
