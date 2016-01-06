//
//  TicketListModel.h
//  SimplicITy
//
//  Created by Vmoksha on 16/04/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TicketListModel : NSObject

@property (nonatomic,strong)NSString *serviceName;
@property (nonatomic,strong)NSString *agentname;
@property (nonatomic,strong)NSString *impact;
@property (nonatomic,strong)NSString *incedentNumber;
@property (nonatomic,strong)NSString *status;
@property (nonatomic,strong)NSString *details;


@end
