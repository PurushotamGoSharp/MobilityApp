//
//  SendRequestsManager.h
//  SimplicITy
//
//  Created by Varghese Simon on 1/22/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestModel.h"

@interface SendRequestsManager : NSObject

+ (instancetype)sharedManager;
- (void)sendRequestsToServer;
- (void)authenticateServer;
- (void)sendRequestSyncronouslyForRequest:(RequestModel *)requestModel;

@end
