//
//  NewsCategoryFetcher.m
//  SimplicITy
//
//  Created by Vmoksha on 24/02/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "NewsCategoryFetcher.h"
#import "NewsCategoryModel.h"
#import "NewsContentModel.h"
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
    
    NSInteger _sinceID;
    void (^_completionHandler)(UIBackgroundFetchResult) ;
    
    NSInteger noOfCallsMade;
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

- (void)initiateNewsCategoryAPIFor:(NSInteger)sinceID fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler andDownloadImages:(BOOL)downloadImages
{
    noOfCallsMade = 0;
    _sinceID = sinceID;
    _completionHandler = completionHandler;
    [self tryToUpdateNewsCategories:sinceID];
}

- (void)tryToUpdateNewsCategories:(NSInteger)sinceID
{
    URLString = NEWS_CATEGORY_API;
    
    NSString *parameter = [NSString stringWithFormat:@"{\"request\":{\"Name\":\"\",\"Since_Id\":\"%li\"}}",(long)sinceID];
    noOfCallsMade++;
    [postMan post:URLString withParameters:parameter];
}

#pragma mark
#pragma mark: postmanDelegate

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    noOfCallsMade--;

    if ([urlString isEqualToString:NEWS_CATEGORY_API])
    {
        [self parseResponseData:response andGetImages:YES];
        
    }else if ([urlString isEqualToString:NEWS_API])
    {
        [self parseResponseDataForNews:response];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadedNewsSuccesfully" object:nil];
        
        if (noOfCallsMade == 0)
        {
            if (_completionHandler != nil)
            {
                _completionHandler(UIBackgroundFetchResultNoData);
            }
        }

    }else
    {
        [self createImages:response forUrl:urlString];
        
        if (noOfCallsMade == 0)
        {
            if (_completionHandler != nil)
            {
                _completionHandler(UIBackgroundFetchResultNoData);
            }
        }
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
                noOfCallsMade++;
                [postMan get:imageUrl];
            }
            
            if (newsCategory.badgeCount > 0)
            {
                noOfCallsMade++;
                [self getNewsForCategoryCode:newsCategory.categoryCode withSince:_sinceID];
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

- (void)parseResponseDataForNews:(NSData*)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSArray *arr = json[@"aaData"][@"News"];
    
    NSString *parentCategory;
    NSMutableArray *newsArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *adict in arr)
    {
        if ([adict[@"Status"] boolValue])
        {
            NewsContentModel *newsContent = [[NewsContentModel alloc]init];
            newsContent.ID = [adict[@"ID"] integerValue];
            newsContent.newsCode =adict[@"Code"];
            parentCategory = adict[@"NewsCategoryCode"];;

            NSString *JSONString = adict[@"JSON"];
            NSDictionary *dictFromJSON = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            
            newsContent.subject = dictFromJSON[@"Title"];
            newsContent.newsDetails =dictFromJSON[@"Content"];
            
            newsContent.recivedDate = [NSDate date];
            newsContent.viewed = NO;
            newsContent.parentCategory = dictFromJSON[@"NewsCategoryCode"];
            [newsArray addObject:newsContent];
        }
    }
    
    [self saveNewsDetails:newsArray forParent:parentCategory];
}

- (void)saveNewsDetails:(NSArray *)newsArray forParent:(NSString *)parentCategoryCode
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManager.delegate = self;
    }
    
//Table names cannot begin with a number.Hence we are adding n_
    
    NSString *creatQuery = [NSString stringWithFormat:@"create table if not exists n_%@ (IDOfNews integer PRIMARY KEY, subject text, newsDetails text, newsCode text, date text, viewedFlag integer)",parentCategoryCode];
    [dbManager createTableForQuery:creatQuery];
    
    NSDateFormatter *converter = [[NSDateFormatter alloc] init];
    [converter setDateFormat:@"yyyy MM dd hh mm ss a"];
    
    for (NewsContentModel *amodel in newsArray)
    {
        NSMutableString *newsDetailsString = [amodel.newsDetails mutableCopy];
        NSRange rangeofString;
        rangeofString.location = 0;
        rangeofString.length = newsDetailsString.length;
        [newsDetailsString replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
        
        NSMutableString *newsSubjectString = [amodel.subject mutableCopy];
        rangeofString.location = 0;
        rangeofString.length = newsSubjectString.length;
        [newsSubjectString replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
        
//Table names cannot begin with a number.Hence we are adding n_
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO n_%@ (IDOfNews, subject, newsDetails, newsCode,date,viewedFlag) values (%li,'%@','%@','%@','%@',%i)",parentCategoryCode, (long)amodel.ID, newsSubjectString, newsDetailsString, amodel.newsCode,
                         [converter stringFromDate:amodel.recivedDate], amodel.viewed];
        [dbManager saveDataToDBForQuery:sql];
        NSInteger currentSinceID = [[NSUserDefaults standardUserDefaults] integerForKey:@"SinceID"];
        
        if (amodel.ID > currentSinceID)
        {
            [[NSUserDefaults standardUserDefaults] setInteger:amodel.ID forKey:@"SinceID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)getNewsForCategoryCode:(NSString *)categoryCode withSince:(NSInteger)sinceID
{
    NSString *parameterStringforNews = [NSString stringWithFormat:@"{\"request\":{\"LanguageCode\":\"en\",\"NewsCategoryCode\":\"%@\",\"Since_Id\":\"%li\"}}",categoryCode, (long)sinceID];
    [postMan post:NEWS_API withParameters:parameterStringforNews];
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    noOfCallsMade--;
    
    if (noOfCallsMade == 0)
    {
        if (_completionHandler != nil)
        {
            _completionHandler(UIBackgroundFetchResultNoData);
        }
    }
    
    NSLog(@"error %@",error);
}

@end
