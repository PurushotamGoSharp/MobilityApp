//
//  AppDelegate.h
//  SimplicITy
//
//  Created by Varghese Simon on 12/3/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsCategoryFetcher.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NewsCategoryFetcher *fetcher;

@property (strong, nonatomic)NSMutableDictionary *languageUrlPairs;

- (void)getEWSRequestURL;

@end
