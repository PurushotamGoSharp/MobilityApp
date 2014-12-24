//
//  CustomColoredViewController.h
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomColoredViewController : UIViewController
- (NSString *)stingForColorTheme;
- (UIColor *)barColorForIndex:(NSInteger)index;
-(UIColor *)subViewsColours;
-(UIColor *)seperatorColours;


@end
