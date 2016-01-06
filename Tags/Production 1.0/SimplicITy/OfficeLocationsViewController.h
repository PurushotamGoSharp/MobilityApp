//
//  OfficeLocationsViewController.h
//  SimplicITy
//
//  Created by Varghese Simon on 4/1/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "CustomColoredViewController.h"

@protocol OfficeLocationDelegate <NSObject>

- (void)selectedOfficeIs:(NSString *)location;
@end

@interface OfficeLocationsViewController : CustomColoredViewController

@property (strong, nonatomic) NSArray *officesArray;
@property (weak,nonatomic)id<OfficeLocationDelegate> delegate;


@end
