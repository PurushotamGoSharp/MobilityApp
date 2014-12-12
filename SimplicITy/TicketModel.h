//
//  TicketModel.h
//  SimplicITy
//
//  Created by Varghese Simon on 12/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TicketModel : NSObject

@property (strong, nonatomic) NSString *ticketSubject;
@property (strong, nonatomic) NSString *agentName;
@property (strong, nonatomic) NSString *currentStatus;
@property (strong, nonatomic) UIColor *colorCode;
@property (strong, nonatomic) NSString *timeStamp;

@end
