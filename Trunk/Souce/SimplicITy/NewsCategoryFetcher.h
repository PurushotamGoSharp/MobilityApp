//
//  NewsCategoryFetcher.h
//  SimplicITy
//
//  Created by Vmoksha on 24/02/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsCategoryFetcher : NSObject

- (void)initiateNewsCategoryAPIFor:(NSInteger)sinceID fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler andDownloadImages:(BOOL)downloadImages;
- (void)getNewsForCategoryCode:(NSString *)parentCode withSince:(NSInteger)sinceID;

- (void)getLatestNewsIDWithCompletionner:(void (^)(BOOL success, NSInteger latestID))completionHandler;

@end
