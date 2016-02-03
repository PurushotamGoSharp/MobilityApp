//
//  TipsGroupModel.h
//  SimplicITy
//
//  Created by Varghese Simon on 1/29/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TipsGroupModel : NSObject

@property (strong, nonatomic) NSString *tipsGroupName;
@property (strong, nonatomic) NSString *tipsGroupDocCode;
@property (strong, nonatomic) NSString *tipsGroupCode;
@property (strong,nonatomic) NSString *tipsLangCode;
@property (strong,nonatomic) NSString *parentCode;

@end
