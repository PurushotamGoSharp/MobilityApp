//
//  RoomRecognizer.m
//  SimplicITy
//
//  Created by Varghese Simon on 3/25/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "RoomRecognizer.h"
#import "RoomModel.h"
#import "KontaktSDK.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "RoomBeacon.h"

#define KONTAKT_DEVICE_API @"https://api.kontakt.io/device"
#define KONTAKT_PROXIMITY_UUID @"f7826da6-4fa2-4e98-8024-bc5b71e0893e"
#define KONTAKT_API_KEY @"AWGfUCgJvdPNoaoCIeFEFXRgNcmVFifR"

@interface RoomRecognizer () <KTKLocationManagerDelegate, postmanDelegate>

//@property (nonatomic) GMBLPlaceManager *placeManager;
//@property (nonatomic) GMBLBeaconManager *beaconManager;

@end

@implementation RoomRecognizer
{
    NSMutableArray *roomsArray;
    KTKLocationManager *locationManager;
    Postman *postman;
    
    NSMutableArray *beaconsArray;
    
    BOOL isMonitoring;
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
    beaconsArray = [[NSMutableArray alloc] init];

//    self.placeManager = [GMBLPlaceManager new];
//    self.placeManager.delegate = self;
//    [GMBLPlaceManager startMonitoring];
    
//    self.beaconManager = [GMBLBeaconManager new];
//    self.beaconManager.delegate = self;
//    [self.beaconManager startListening];
    
    postman = [[Postman alloc] init];
    postman.delegate = self;
    
    locationManager = [[KTKLocationManager alloc] init];
    locationManager.delegate = self;
    
    KTKRegion *region =[[KTKRegion alloc] init];
    region.uuid = @"f7826da6-4fa2-4e98-8024-bc5b71e0893e"; // kontakt.io proximity UUID
    
    [locationManager setRegions:@[region]];
}

- (void)startRecognize
{
//    if (isMonitoring == NO)
//    {
        [locationManager startMonitoringBeacons];
        isMonitoring = YES;
//    }
}

- (void)stopRecognize
{
    [locationManager stopMonitoringBeacons];
    isMonitoring = NO;
}

- (NSArray *)recognizedRooms
{
    return roomsArray;
}

- (void)locationManager:(KTKLocationManager *)locationManager didChangeState:(KTKLocationManagerState)state withError:(NSError *)error
{
    if (state == KTKLocationManagerStateFailed)
    {
        NSLog(@"Something went wrong with your Location Services settings. Check OS settings.");
    }
}

- (void)locationManager:(KTKLocationManager *)locationManager didEnterRegion:(KTKRegion *)region
{
    NSLog(@"Enter region %@", region.uuid);
}

- (void)locationManager:(KTKLocationManager *)locationManager didExitRegion:(KTKRegion *)region
{
    NSLog(@"Exit region %@", region.uuid);
}

- (void)locationManager:(KTKLocationManager *)locationManager didRangeBeacons:(NSArray *)beacons
{
    NSLog(@"Ranged beacons count: %lu", (unsigned long)[beacons count]);
    
    for (CLBeacon *beacon in beacons)
    {
        RoomBeacon *aBeacon = [self beaconForMajor:[beacon.major integerValue] andMinor:[beacon.minor integerValue]];
        
        if (!aBeacon) //This beacon is NEW in the list. So call the API
        {
            aBeacon = [[RoomBeacon alloc] init];
            if (aBeacon.updating) continue;
            
            //Call the API to get details about the Beacon;
            aBeacon.majorID = [beacon.major integerValue];
            aBeacon.minorID = [beacon.minor integerValue];
            aBeacon.RSSIValue = beacon.rssi;
            aBeacon.updating = YES;
            [beaconsArray addObject:aBeacon];
            
            [self callAPIForBeacon:aBeacon];
        }else
        {
            aBeacon.RSSIValue = beacon.rssi;
            
            for (RoomModel *roomModel in aBeacon.roomsAssociated)
            {
                roomModel.RSSIValue = aBeacon.RSSIValue;
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GIMBAL_CAHNGE_IN_NO_RECGNIZED_LIST object:nil];
}

- (void)callAPIForBeacon:(RoomBeacon *)aBeacon
{
    NSString *URLString = [NSString stringWithFormat:@"%@?proximity=%@&major=%li&minor=%li",KONTAKT_DEVICE_API, KONTAKT_PROXIMITY_UUID, (long)aBeacon.majorID, (long)aBeacon.minorID];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:KONTAKT_API_KEY forHTTPHeaderField:@"Api-Key"];
    [requestSerializer setValue:@"application/vnd.com.kontakt+json;version=5" forHTTPHeaderField:@"Accept"];
    
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.com.kontakt+json"];
    
    [manager GET:URLString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             NSLog(@"opreation result + %@", [operation responseString]);
             
             aBeacon.uniqueID = responseObject[@"uniqueId"];
             [self updateEmailIdForRoom:aBeacon];
             aBeacon.updating = NO;
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             aBeacon.updating = NO;
             NSLog(@"%@", error);
         }];
}

- (void)updateEmailIdForRoom:(RoomBeacon *)aBeacon
{
    NSString *parameterSTring = [NSString stringWithFormat:@"{\"request\":{\"DeviceId\":\"%@\"}}", aBeacon.uniqueID];
    
    [postman post:GET_DETAILS_BEACON_API
   withParameters:parameterSTring
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSLog(@"Sucess %@", [operation responseString]);
              
              if (responseObject[@"aaData"][@"Success"])
              {
                  NSArray *arrayOfBeacons = responseObject[@"aaData"][@"Beacons"];
                  if (arrayOfBeacons.count > 0)
                  {
                      NSString *emailIDs = [arrayOfBeacons firstObject][@"EmailId"];
                      NSArray *arrayOfEmailIDs = [emailIDs componentsSeparatedByString:@","];
                      
                      if (aBeacon.roomsAssociated == nil)
                      {
                          aBeacon.roomsAssociated = [[NSMutableArray alloc] init];
                      }
                      
                      for (NSString *anEmailID in arrayOfEmailIDs)
                      {
                          RoomModel *anModel = [[RoomModel alloc] init];
                          anModel.emailIDOfRoom = anEmailID;
                          anModel.majorID = aBeacon.majorID;
                          anModel.minorID = aBeacon.minorID;
                          anModel.RSSIValue = aBeacon.RSSIValue;
                          
                          [roomsArray addObject:anModel];
                          [aBeacon.roomsAssociated addObject:anModel];
                      }
//                      roomModel.emailIDOfRoom = [arrayOfBeacons firstObject][@"EmailId"];
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              
              
          }];
}

- (RoomModel *)roomForMajor:(NSInteger)major andMinor:(NSInteger )minor
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"majorID = %@ && minorID = %@", @(major), @(minor)];
    NSArray *filteredArray = [roomsArray filteredArrayUsingPredicate:predicate];
    NSLog(@"No of elements in filtered array is %li", (unsigned long)filteredArray.count);
    
    return [filteredArray firstObject];
}

- (RoomBeacon *)beaconForMajor:(NSInteger)major andMinor:(NSInteger )minor
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"majorID = %@ && minorID = %@", @(major), @(minor)];
    NSArray *filteredArray = [beaconsArray filteredArrayUsingPredicate:predicate];
    NSLog(@"No of elements in filtered array is %li", (unsigned long)filteredArray.count);
    
    return [filteredArray firstObject];
}

@end
