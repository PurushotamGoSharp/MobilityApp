//
//  BadgeNoManager.m
//  SimplicITy
//
//  Created by Varghese Simon on 2/26/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "BadgeNoManager.h"
#import "DBManager.h"
#import "NewsCategoryModel.h"

@interface BadgeNoManager () <DBManagerDelegate>

@end

@implementation BadgeNoManager
{
    DBManager *dbManager;
    NSMutableArray *newsCategoryArr;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    newsCategoryArr = [[NSMutableArray alloc] init];
}

- (void)getDataFromDB
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManager.delegate=self;
    }
    NSString *queryString = @"SELECT * FROM categories";
    [dbManager getDataForQuery:queryString];
}

- (NSInteger)noBadgesFor:(NSString *)categroyCode afterUpdating:(BOOL)update
{
    if (update || [newsCategoryArr count] == 0)
    {
        [self getDataFromDB];
    }
    for (NewsCategoryModel *category in newsCategoryArr)
    {
        if ([category.categoryCode isEqualToString:categroyCode])
        {
            return category.badgeCount;
        }
    }
    return 0;
}

- (void)decreaseBadgeNoFor:(NSString *)categoryCode withNo:(NSInteger)noToReduce
{
    [self getDataFromDB];
    NSInteger currentBadgeNo = [self noBadgesFor:categoryCode afterUpdating:NO];
    currentBadgeNo -= noToReduce;
    currentBadgeNo = MAX(0, currentBadgeNo);
    NSString *query =  [NSString stringWithFormat:@"UPDATE categories set badgeCount='%li' WHERE code = '%@'", (long)currentBadgeNo, categoryCode];
    [dbManager saveDataToDBForQuery:query];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewsBadgeCount" object:nil];

}

- (void)decrementBadgeNoFor:(NSString *)categoryCode
{
    [self decreaseBadgeNoFor:categoryCode withNo:1];
}

- (void)incrementBadgeNoFor:(NSString *)categoryCode withNo:(NSInteger)noToIncrease
{
    [self getDataFromDB];
    NSInteger currentBadgeNo = [self noBadgesFor:categoryCode afterUpdating:NO];
    currentBadgeNo += noToIncrease;
    currentBadgeNo = MAX(0, currentBadgeNo);
    NSString *query =  [NSString stringWithFormat:@"UPDATE categories set badgeCount='%li' WHERE code = '%@'", (long)currentBadgeNo, categoryCode];
    [dbManager saveDataToDBForQuery:query];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewsBadgeCount" object:nil];
    
}

- (void)updateBadgeNoFor:(NSString *)categoryCode withNo:(NSInteger)badgeNo
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManager.delegate=self;
    }
    NSInteger currentBadgeNo;
    
    currentBadgeNo = badgeNo;
    currentBadgeNo = MAX(0, currentBadgeNo);
    NSString *query =  [NSString stringWithFormat:@"UPDATE categories set badgeCount='%li' WHERE code = '%@'", (long)currentBadgeNo, categoryCode];
    [dbManager saveDataToDBForQuery:query];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewsBadgeCount" object:nil];
}

- (NSInteger)totalNoBadges
{
    [self getDataFromDB];
    NSInteger totalNobadges = 0;
    for (NewsCategoryModel *category in newsCategoryArr)
    {
        totalNobadges += category.badgeCount;
    }
    return totalNobadges;
}

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    [newsCategoryArr removeAllObjects];
    
    while (sqlite3_step(statment)== SQLITE_ROW)
    {
        NSString *categoryCode = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        NSString *badge = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 3)];
        
        NewsCategoryModel *categoryModel = [[NewsCategoryModel alloc] init];
        categoryModel.categoryCode = categoryCode;
        categoryModel.badgeCount = [badge integerValue];
        
        [newsCategoryArr addObject:categoryModel];
    }
}

@end
