//
//  RoomRecognizer.h
//  SimplicITy
//
//  Created by Varghese Simon on 3/25/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomRecognizer : NSObject

+ (instancetype)sharedRecognizer;

- (NSArray *)recognizedRooms;

@end
