//
//  UserInfo.m
//  SimplicITy
//
//  Created by Varghese Simon on 1/19/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
{
    NSDictionary *serverConfig;
    
}

static NSString * const kConfigurationKey = @"com.apple.configuration.managed";

+ (instancetype)sharedUserInfo
{
    static UserInfo *_shareUserInfo = nil;
    static dispatch_once_t onceTocken;
    
    dispatch_once(&onceTocken, ^{
        
        _shareUserInfo = [[UserInfo alloc] init];
        
    });
    
    return _shareUserInfo;
}

- (instancetype)init
{
    if (self = [super init])
    {
        serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfigurationKey];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDefaultdValueChanged)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    
    return self;
}

- (NSDictionary *)getServerConfig
{
    if (!serverConfig)
    {
        serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfigurationKey];
    }
    
    return serverConfig;
}

- (NSString *)firstName
{
    return [self getServerConfig][@"firstName"];
}

- (NSString *)lastName
{
    return [self getServerConfig][@"lastName"];
}

- (NSString *)cropID
{
    return [self getServerConfig][@"corpID"];
}

- (NSString *)location
{
    return [self getServerConfig][@"location"];
}

- (NSString *)emailIDValue
{
    return [self getServerConfig][@"mail"];
}

- (NSString *)fullName
{
    NSString *nameOfPerson;
    
    if (self.firstName && self.lastName)
    {
        nameOfPerson = [self.firstName stringByAppendingString:[NSString stringWithFormat:@" %@",self.lastName]];
    } else if (self.firstName)
    {
        nameOfPerson = self.firstName;
        
    }else if (self.lastName)
    {
        nameOfPerson = self.lastName;
    }
    
    return nameOfPerson;
}

- (void)userDefaultdValueChanged
{
    serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfigurationKey];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

@end