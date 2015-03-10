//
//  UserInfo.h
//  SimplicITy
//
//  Created by Varghese Simon on 1/19/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *fullName;

@property (strong, nonatomic) NSString *cropID;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *emailIDValue;

@property (strong, nonatomic) NSString *serialNo;

@property (strong, nonatomic) NSArray *tags;
@property (strong, nonatomic) NSString *alias;

+ (instancetype)sharedUserInfo;
- (NSDictionary *)getServerConfig;

@end
