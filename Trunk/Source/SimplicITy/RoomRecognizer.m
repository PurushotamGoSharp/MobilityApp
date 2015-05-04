//
//  RoomRecognizer.m
//  SimplicITy
//
//  Created by Varghese Simon on 3/25/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "RoomRecognizer.h"
#import <Gimbal/Gimbal.h>
#import "RoomModel.h"

@interface RoomRecognizer () <GMBLPlaceManagerDelegate, GMBLBeaconManagerDelegate>

@property (nonatomic) GMBLPlaceManager *placeManager;
@property (nonatomic) GMBLBeaconManager *beaconManager;

@end

@implementation RoomRecognizer
{
    NSMutableArray *roomsArray;
}

+ (instancetype)sharedRecognizer
{
    static RoomRecognizer *_recognizer = nil;
    static dispatch_once_t onceTocken;
    
    dispatch_once(&onceTocken, ^{
        
        _recognizer = [[RoomRecognizer alloc] init];
        
    });
    
    return _recognizer;
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
    roomsArray = [[NSMutableArray alloc] init];
    
    self.placeManager = [GMBLPlaceManager new];
    self.placeManager.delegate = self;
    [GMBLPlaceManager startMonitoring];
    
    self.beaconManager = [GMBLBeaconManager new];
    self.beaconManager.delegate = self;
    [self.beaconManager startListening];
}

- (NSArray *)recognizedRooms
{
    return roomsArray;
}


- (void)placeManager:(GMBLPlaceManager *)manager didBeginVisit:(GMBLVisit *)visit
{
    RoomModel *detectedRoom = [[RoomModel alloc] init];
    detectedRoom.gimbalID = visit.place.identifier;
    detectedRoom.nameOfRoom = [visit.place.attributes stringForKey:@"nameOfRoom"];
    detectedRoom.emailIDOfRoom = [visit.place.attributes stringForKey:@"emailID"];
    detectedRoom.beaconID = [visit.place.attributes stringForKey:@"beaconID"];

    [roomsArray addObject:detectedRoom];
    NSLog(@"Detected room = %@, and count of array = %li", detectedRoom.nameOfRoom, (unsigned long)roomsArray.count);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GIMBAL_CAHNGE_IN_NO_RECGNIZED_LIST object:nil];
}

- (void)placeManager:(GMBLPlaceManager *)manager didEndVisit:(GMBLVisit *)visit
{
    RoomModel *roomThatLostVisibility = [self roomForGimbalID:visit.place.identifier];
    
    //RSSI value is negative. So instead of zero value, we have to give NSIntegerMin
    roomThatLostVisibility.RSSIValue = NSIntegerMin;
    [roomsArray removeObject:roomThatLostVisibility];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GIMBAL_CAHNGE_IN_NO_RECGNIZED_LIST object:nil];
}

- (void)beaconManager:(GMBLBeaconManager *)manager didReceiveBeaconSighting:(GMBLBeaconSighting *)sighting
{
    RoomModel *RSSIValueChangedForRoom = [self roomForBeaconID:sighting.beacon.identifier];
    RSSIValueChangedForRoom.RSSIValue = sighting.RSSI;
    
    NSLog(@"RSSI for %@ is %li", RSSIValueChangedForRoom.nameOfRoom, (long)RSSIValueChangedForRoom.RSSIValue);
}

- (RoomModel *)roomForGimbalID:(NSString *)gimbalID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gimbalID == %@", gimbalID];
    NSArray *filteredArray = [roomsArray filteredArrayUsingPredicate:predicate];
    NSLog(@"No of elements in filtered array is %li", (unsigned long)filteredArray.count);
    
    return [filteredArray firstObject];
}

- (RoomModel *)roomForBeaconID:(NSString *)beaconID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"beaconID == %@", beaconID];
    NSArray *filteredArray = [roomsArray filteredArrayUsingPredicate:predicate];
    NSLog(@"No of elements in filtered array is %li", (unsigned long)filteredArray.count);
    
    return [filteredArray firstObject];
}

@end
