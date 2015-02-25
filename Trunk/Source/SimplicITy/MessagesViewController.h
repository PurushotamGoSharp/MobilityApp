//
//  MessagesViewController.h
//  SimplicITy
//
//  Created by Vmoksha on 03/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsCategoryModel.h"

@interface MessagesViewController : CustomColoredViewController
{
    
}

@property (nonatomic,strong)NewsCategoryModel *categoryModel;
@property(nonatomic,strong)NSString  *navBarTitleName;
@property(nonatomic,assign) NSInteger emailreadNum;



@end
