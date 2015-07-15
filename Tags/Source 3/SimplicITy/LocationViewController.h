//
//  LocationViewController.h
//  SimplicITy
//
//  Created by Vmoksha on 11/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationSettingdelegate <NSObject>

-(void)selectedLocationIs:(NSString *)location;

@end

@interface LocationViewController : CustomColoredViewController

@property (weak,nonatomic)id<LocationSettingdelegate> delegate;


@end
