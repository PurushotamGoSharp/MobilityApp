//
//  Postman.h
//  EuLux
//
//  Created by Varghese Simon on 3/3/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "AFNetworking.h"
#import <Foundation/Foundation.h>

@class Postman;
@protocol postmanDelegate <NSObject>

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response;
- (void)postman:(Postman *)postman gotFailure:(NSError *)error;

@end
@interface Postman : NSObject

@property (weak, nonatomic)id <postmanDelegate> delegate;

- (void)post:(NSString *)URLString withParameters:(NSString *)parameter;

- (void)get:(NSString *)URLString ;

@end

