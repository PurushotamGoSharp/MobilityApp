//
//  RoomRecognizer.h
//  SimplicITy
//
//  Created by Varghese Simon on 3/25/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>
#define GIMBAL_RSSI_VALUE_CHANGE @"gimbalRSSIValueChangeKey"
#define GIMBAL_CAHNGE_IN_NO_RECGNIZED_LIST @"gimbalChangeInRecognizedListKey"

@interface RoomRecognizer : NSObject

+ (instancetype)sharedRecognizer;

- (void)startRecognize;
- (void)stopRecognize;
- (NSArray *)recognizedRooms;

@end
