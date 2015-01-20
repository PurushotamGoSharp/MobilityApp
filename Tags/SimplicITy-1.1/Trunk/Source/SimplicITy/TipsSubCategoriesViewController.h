//
//  TipsSubCategoriesViewController.h
//  SimplicITy
//
//  Created by Varghese Simon on 12/10/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TipsSubCategoriesViewControllerDelegate <NSObject>

- (void)VCIsGoingToDisappear;


@end

@interface TipsSubCategoriesViewController : CustomColoredViewController

@property (weak, nonatomic) id <TipsSubCategoriesViewControllerDelegate>delegate;

@property (strong, nonatomic) NSString *parentCategory;
@property (strong, nonatomic) NSString *parentCode;
@property (strong, nonatomic) NSData *resposeData;

@end
