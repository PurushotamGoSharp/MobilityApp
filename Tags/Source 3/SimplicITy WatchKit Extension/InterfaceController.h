//
//  InterfaceController.h
//  SimplicITy WatchKit Extension
//
//  Created by Vmoksha on 10/08/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *passwordProgress;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *pExpireLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *pDaysLabel;

@property(nonatomic,strong)NSArray *animationarry;

@end
