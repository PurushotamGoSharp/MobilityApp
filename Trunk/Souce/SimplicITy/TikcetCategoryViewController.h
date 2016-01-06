//
//  TikcetCategoryViewController.h
//  SimplicITy
//
//  Created by Varghese Simon on 12/15/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "CustomColoredViewController.h"
#import "CategoryModel.h"


@protocol TicketCategoryDelegate <NSObject>

- (void)selectedCategory:(CategoryModel *)category;

@end

@interface TikcetCategoryViewController : CustomColoredViewController

@property (strong, nonatomic)NSString *orderItemDiffer;
@property (strong,nonatomic)NSArray *categoryArray;
@property (strong,nonatomic)CategoryModel *selectedCategory;

@property (weak, nonatomic) id <TicketCategoryDelegate> delegate;

@end
