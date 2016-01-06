//
//  TicketsListCell.h
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestModel.h"
#import "TicketListModel.h"
@interface TicketsListCell : UITableViewCell

@property (nonatomic, strong) RequestModel *requestModel;

@property (nonatomic ,strong) TicketListModel *ticketListModel;

@end
