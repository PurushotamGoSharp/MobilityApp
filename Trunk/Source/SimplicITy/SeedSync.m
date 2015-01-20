//
//  SeedSync.m
//  SimplicITy
//
//  Created by Varghese Simon on 1/9/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "SeedSync.h"

@implementation SeedSync

+ (instancetype)sharedSync
{
    static SeedSync *_shareSync = nil;
    static dispatch_once_t onceTocken;
    
    dispatch_once(&onceTocken, ^{
        
        _shareSync = [[SeedSync alloc] init];
        
    });
    
    return _shareSync;
}

- (instancetype)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

@end
