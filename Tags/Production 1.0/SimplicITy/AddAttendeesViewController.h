//
//  AddAttendeesViewController.h
//  SimplicITy
//
//  Created by Varghese Simon on 4/13/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomColoredViewController.h"

@protocol  AddAttendeesDelegate <NSObject>

- (void)addAntendees:(NSArray *)attendees;

@end

@interface AddAttendeesViewController : CustomColoredViewController

@property (weak, nonatomic) id <AddAttendeesDelegate> delegate;

@end
