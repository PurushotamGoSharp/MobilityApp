//
//  LanguageViewController.h
//  SimplicITy
//
//  Created by Vmoksha on 11/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol languagesSettingdelegate <NSObject>

-(void)selectedLanguageis:(NSString *)language;

@end

@interface LanguageViewController : CustomColoredViewController
@property (weak,nonatomic)id<languagesSettingdelegate> delegate;

@end
