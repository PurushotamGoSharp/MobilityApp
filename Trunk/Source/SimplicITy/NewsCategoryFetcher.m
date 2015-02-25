//
//  NewsCategoryFetcher.m
//  SimplicITy
//
//  Created by Vmoksha on 24/02/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "NewsCategoryFetcher.h"
#import "NewsCategoryModel.h"
#import <sqlite3.h>
#import "DBManager.h"


@interface NewsCategoryFetcher () <postmanDelegate,DBManagerDelegate>

@end

@implementation NewsCategoryFetcher
{
    Postman *postMan;
    NSString *URLString;
    NSString *databasePath;
    sqlite3 *database;
    DBManager *dbManager;
    
    NSInteger badgeForCurrentCategory;
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
    URLString = TIPS_CATEGORY_API;
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
}

- (void)initiateNewsCategoryAPIFor:(NSInteger)sinceID
{
    [self tryToUpdateNewsCategories:sinceID];
}

- (void)tryToUpdateNewsCategories:(NSInteger)sinceID
{
    URLString = NEWS_CATEGORY_API;
    
    NSString *parameter = [NSString stringWithFormat:@"{\"request\":{\"Name\":\"\",\"Since_Id\":\"%li\"}}",(long)sinceID];
    [postMan post:URLString withParameters:parameter];
}

#pragma mark
#pragma mark: postmanDelegate

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    if ([urlString isEqualToString:NEWS_CATEGORY_API])
    {
        [self parseResponseData:response andGetImages:YES];
    }else
    {
        [self createImages:response forUrl:urlString];
    }
}

- (void)parseResponseData:(NSData*)response andGetImages:(BOOL)download
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    
    NSArray *arr = json[@"aaData"][@"GenericSearchViewModels"];
    
    NSMutableArray *newsCategoryArr = [[NSMutableArray alloc] init];

    for (NSDictionary *adict in arr)
    {
        if ([adict[@"Status"] boolValue])
        {
            NewsCategoryModel *newsCategory = [[NewsCategoryModel alloc] init];
            newsCategory.categoryCode = adict[@"Code"];
            newsCategory.categoryName = adict[@"Name"];
            newsCategory.categoryDocCode = adict[@"DocumentCode"];
            newsCategory.badgeCount = [adict[@"NewsCount"] integerValue];
            
            if (download)
            {
                NSString *imageUrl = [NSString stringWithFormat:RENDER_DOC_API, adict[@"DocumentCode"]];
                [postMan get:imageUrl];
            }
            [newsCategoryArr addObject:newsCategory];
        }
    }
    
    [self saveCategoies:newsCategoryArr];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewCategoryGotSuccess" object:nil];
}

- (void)saveCategoies:(NSArray *)categories
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManager.delegate = self;
    }
    
    for (NewsCategoryModel *aModel in categories)
    {
        NSInteger badgeCount = aModel.badgeCount  + [self badgeCountFor:aModel.categoryCode];
        aModel.badgeCount = badgeCount;
    }
    
    [dbManager dropTable:@"categories"];
    NSString *creatQuery = [NSString stringWithFormat:@"create table if not exists categories (name text, code text PRIMARY KEY, docCode text, badgeCount text)"];
    [dbManager createTableForQuery:creatQuery];
    
    for (NewsCategoryModel *aModel in categories)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO categories (name, code, docCode, badgeCount) values ('%@','%@','%@', '%li')",aModel.categoryName, aModel.categoryCode,aModel.categoryDocCode,(long)aModel.badgeCount];
        [dbManager saveDataToDBForQuery:insertSQL];
    }
}

- (NSInteger)badgeCountFor:(NSString*)categoryCode
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManager.delegate=self;
    }
    
    badgeForCurrentCategory = 0;

    NSString  *sql = [NSString stringWithFormat:@"SELECT badgeCount FROM categories WHERE code == '%@'",categoryCode];
    [dbManager getDataForQuery:sql];
    
    return badgeForCurrentCategory;
}

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    if (sqlite3_step(statment)== SQLITE_ROW)
    {
        NSString *badgeCountFromDB = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 0)];
        badgeForCurrentCategory = [badgeCountFromDB integerValue];
    }
}

- (void)createImages:(NSData *)response forUrl:(NSString *)url
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    
    if (![json[@"aaData"][@"Success"] boolValue])
    {
        return;
    }
    NSString *imageAsBlob = json[@"aaData"][@"Base64Model"][@"Image"];
    //    NSLog(@"%@",imageAsBlob);
    NSString *pathToDoc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSData *imageDataForFromBase64 = [[NSData alloc] initWithBase64EncodedString:imageAsBlob options:kNilOptions];
    UIImage *image = [UIImage imageWithData:imageDataForFromBase64];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *pathToImage;
    
    //    NSMutableString *webClipFileName = [[NSMutableString alloc] init];
    //    webClipFileName = @""
    NSRange rangeOfFileName;
    rangeOfFileName.length = url.length;
    rangeOfFileName.location = 0;
    
    NSMutableString *stringToRemove = [RENDER_DOC_API mutableCopy];
    NSRange rangeOfBaseURL;
    rangeOfBaseURL.length = stringToRemove.length;
    rangeOfBaseURL.location = 0;
    [stringToRemove replaceOccurrencesOfString:@"%@" withString:@"" options:NSCaseInsensitiveSearch range:rangeOfBaseURL];
    
    NSLog(@"Base URL = %@", stringToRemove);
    NSMutableString *docCode = [url mutableCopy];
    [docCode replaceOccurrencesOfString:stringToRemove
                             withString:@""
                                options:NSCaseInsensitiveSearch
                                  range:rangeOfFileName];
    
    pathToImage = [NSString stringWithFormat:@"%@/%@@2x.png", pathToDoc, docCode];
    NSLog(@"%@", pathToImage);
    [imageData writeToFile:pathToImage atomically:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewCategoryGotSuccess" object:nil];
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    NSLog(@"error %@",error);
}

@end
