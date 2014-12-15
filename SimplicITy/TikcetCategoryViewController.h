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

@end

@interface TikcetCategoryViewController : CustomColoredViewController

@property (weak, nonatomic) id <TicketCategoryDelegate> delegate;

@end
