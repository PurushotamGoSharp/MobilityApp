//
//  ADExpirationDateFetcher.h
//  SimplicITy
//
//  Created by Varghese Simon on 4/9/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADExpirationDateFetcher : NSObject

- (void)getExpirationDateWithSuccess:(void (^)(NSInteger noOfDayLeft))success;
- (void)getExpirationDateForURL:(NSString *)urlString withSuccess:(void (^)(NSInteger))success;
@end
