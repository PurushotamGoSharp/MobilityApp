//
//  RequestModel.h
//  SimplicITy
//
//  Created by Varghese Simon on 1/13/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestModel : NSObject

@property (strong, nonatomic) NSString *requestType;
@property (assign, nonatomic) NSInteger requestImpact;
@property (strong, nonatomic) NSString *requestServiceCode;
@property (strong, nonatomic) NSString *requestDetails;

@property (assign, nonatomic) NSInteger requestSyncFlag;

@end
