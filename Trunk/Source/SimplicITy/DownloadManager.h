//
//  DownloadManager.h
//  SimplicITy
//
//  Created by Varghese Simon on 2/6/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadManager : NSObject

+ (instancetype)sharedDownloadManager;
- (void)downloadFromURLString:(NSString *)URLString;

@end
