//
//  TicketDetailViewController.h
//  SimplicITy
//
//  Created by Varghese Simon on 12/16/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "CustomColoredViewController.h"
#import "TicketModel.h"

@interface TicketDetailViewController : CustomColoredViewController
{
    
}

@property (nonatomic,strong)TicketModel *tickModel;
@property (strong, nonatomic)NSString *orderItemDifferForList;

@end
