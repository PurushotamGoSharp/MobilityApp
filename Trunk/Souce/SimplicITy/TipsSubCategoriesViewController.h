//
//  TipsSubCategoriesViewController.h
//  SimplicITy
//
//  Created by Varghese Simon on 12/10/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TipsSubCategoriesViewController;

@protocol TipsSubCategoriesViewControllerDelegate <NSObject>

- (void)tipsSub:(TipsSubCategoriesViewController *)tipsSub selectedIndex:(NSInteger)selectedIndex;


@end

@interface TipsSubCategoriesViewController : CustomColoredViewController

@property (weak, nonatomic) id <TipsSubCategoriesViewControllerDelegate>delegate;

@property (strong, nonatomic) NSString *parentCategory;
@property (strong, nonatomic) NSString *parentCode;
@property (strong, nonatomic) NSArray *listOfTips;


@property(assign, nonatomic) NSInteger curentpageNum;

@end
