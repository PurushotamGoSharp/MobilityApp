//
//  SendRequestsManager.h
//  SimplicITy
//
//  Created by Varghese Simon on 1/22/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestModel.h"

@class SendRequestsManager;
@protocol TicketListsDelegate <NSObject>

-(void)ticketLists:(SendRequestsManager*)ticketList gotSucess:(NSData*)response;
-(void)ticketListsFailed:(SendRequestsManager*)ticketList;

@end

@interface SendRequestsManager : NSObject

@property (weak, nonatomic)id <TicketListsDelegate> delegate;

+ (instancetype)sharedManager;
- (void)sendRequestsToServer;
- (void)authenticateServer;
- (void)sendRequestSyncronouslyForRequest:(RequestModel *)requestModel blockUI:(BOOL)blockUI;


-(void)getListOfTickets:(NSString*)URL;

@end
