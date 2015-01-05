//
//  CustomURLCache.m
//  SimplicITy
//
//  Created by Varghese Simon on 1/2/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "CustomURLCache.h"

NSString * const EXPIRES_KEY = @"cache date";
int const CACHE_EXPIRES = -10;

@implementation CustomURLCache

+ (void)activate
{
    CustomURLCache *urlCache = [[CustomURLCache alloc] initWithMemoryCapacity:(4*1024*1024)
                                                                 diskCapacity:(20*1024*1024)
                                                                     diskPath:nil] ;
    [NSURLCache setSharedURLCache:urlCache];
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    NSCachedURLResponse * cachedResponse = [super cachedResponseForRequest:request];
    
    if (cachedResponse)
    {
        NSDate* cacheDate = [[cachedResponse userInfo] objectForKey:EXPIRES_KEY];
        
        if ([cacheDate timeIntervalSinceNow] < CACHE_EXPIRES)
        {
            [self removeCachedResponseForRequest:request];
            cachedResponse = nil;
        }
    }
    
    return cachedResponse;
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    NSMutableDictionary *userInfo = cachedResponse.userInfo ? [cachedResponse.userInfo mutableCopy] : [NSMutableDictionary dictionary];
    
    [userInfo setObject:[NSDate date] forKey:EXPIRES_KEY];
    
    NSCachedURLResponse *newCachedResponse = [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:cachedResponse.data userInfo:userInfo storagePolicy:cachedResponse.storagePolicy];
    
    [super storeCachedResponse:newCachedResponse forRequest:request];
}

@end