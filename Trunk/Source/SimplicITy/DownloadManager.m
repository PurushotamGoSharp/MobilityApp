//
//  DownloadManager.m
//  SimplicITy
//
//  Created by Varghese Simon on 2/6/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "DownloadManager.h"
#import <AFNetworking/AFNetworking.h>

@implementation DownloadManager
{
    
}

+ (instancetype)sharedDownloadManager
{
    static DownloadManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _sharedManager = [[DownloadManager alloc] init];
        
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    
}

@end
