//
//  ThemesViewController.h
//  SimplicITy
//
//  Created by Vmoksha on 17/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ThemeSettingDelegate <NSObject>

-(void)selectedThemeIs:(NSString *)theme;

@end

@interface ThemesViewController : CustomColoredViewController

@property (weak,nonatomic)id<ThemeSettingDelegate> delegate;


@end
