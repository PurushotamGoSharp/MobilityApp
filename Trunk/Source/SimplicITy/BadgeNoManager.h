//
//  BadgeNoManager.h
//  SimplicITy
//
//  Created by Varghese Simon on 2/26/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BadgeNoManager : NSObject

- (void)getDataFromDB;

- (NSInteger)noBadgesFor:(NSString *)categroyCode afterUpdating:(BOOL)update;
- (NSInteger)totalNoBadges;

- (void)decrementBadgeNoFor:(NSString *)categoryCode;
- (void)decreaseBadgeNoFor:(NSString *)categoryCode withNo:(NSInteger)noToReduce;

- (void)incrementBadgeNoFor:(NSString *)categoryCode withNo:(NSInteger)noToIncrease;

- (void)updateBadgeNoFor:(NSString *)categoryCode withNo:(NSInteger)badgeNo;

@end
