//
//  TikcetCategoryViewController.h
//  SimplicITy
//
//  Created by Varghese Simon on 12/15/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "CustomColoredViewController.h"

@protocol TicketCategoryDelegate <NSObject>

- (void)selectedTicket:(NSString *)tickt;
-(void)selectedTips:(NSString *)tip;

@end

@interface TikcetCategoryViewController : CustomColoredViewController

@property (strong, nonatomic)NSString *orderItemDiffer;

@property (weak, nonatomic) id <TicketCategoryDelegate> delegate;

@end
