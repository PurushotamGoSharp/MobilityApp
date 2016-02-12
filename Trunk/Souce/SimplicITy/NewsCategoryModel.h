//
//  NewsCategoryModel.h
//  SimplicITy
//
//  Created by Vmoksha on 19/02/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsCategoryModel : NSObject

@property (strong,nonatomic)NSString *categoryCode;
@property (strong,nonatomic)NSString *categoryName;
@property (strong,nonatomic)NSArray *newsArr;
@property (strong,nonatomic)NSString *categoryDocCode;
@property (assign,nonatomic)NSInteger badgeCount;
//@property(nonatomic,strong)NSString *parentCode;
@end
