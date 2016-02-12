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
#import "BadgeNoManager.h"
#import "UserInfo.h"
@interface NewsCategoryFetcher () <postmanDelegate,DBManagerDelegate>

@end

@implementation NewsCategoryFetcher
{
    Postman *postMan;
    NSString *URLString;
    NSString *databasePath;
    sqlite3 *database;
    DBManager *dbManager, *dbManagerForBadgeCount;
    
    NSInteger badgeForCurrentCategory, countForUnviewedNews;
    
    NSInteger _sinceID;
    void (^_completionHandler)(UIBackgroundFetchResult) ;
    
    NSInteger noOfCallsMade;
    NSString *langCode;
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
    langCode=[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLanguageCode"];
   
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
    NSString *parameter = [NSString stringWithFormat:@"{\"request\":{\"LanguageCode\":\"%@\",\"Since_Id\":\"%li\"}}",langCode,(long)sinceID];
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

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    noOfCallsMade--;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadedNewsUnSuccesfully" object:nil];
    
    
    if (noOfCallsMade == 0)
    {
        if (_completionHandler != nil)
        {
            _completionHandler(UIBackgroundFetchResultNoData);
        }
    }
    
    NSLog(@"error %@",error);
}


- (void)parseResponseData:(NSData*)response andGetImages:(BOOL)download
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSArray *arr = json[@"aaData"][@"GenericSearchViewModels"];
    NSMutableArray *newsCategoryArr = [[NSMutableArray alloc] init];

    for (NSDictionary *adict in arr)
    {
        //We should not check staus because client requirement is that, visibility of 'news' should not be managed by server admin. If we chwck status and admin changes status of category, news under that category will become hidden
        
//        if ([adict[@"Status"] boolValue])
//        {
            NewsCategoryModel *newsCategory = [[NewsCategoryModel alloc] init];
            newsCategory.categoryCode = adict[@"ParentCode"];//For news category, Parent Code is wat we need to support language. So we are saving parent code as CategoryCode;
            newsCategory.categoryName = adict[@"Name"];
            newsCategory.categoryDocCode = adict[@"DocumentCode"];
            newsCategory.badgeCount = [adict[@"NewsCount"] integerValue];
//            newsCategory.parentCode = adict[@"ParentCode"];
        
            if (download)
            {
                NSString *imageUrl = [NSString stringWithFormat:RENDER_DOC_API, adict[@"DocumentCode"]];
                noOfCallsMade++;
                [postMan get:imageUrl];
            }
            NSLog(@"%li", newsCategory.badgeCount);
            if (newsCategory.badgeCount > 0)
            {
                noOfCallsMade++;
                [self getNewsForCategoryCode:newsCategory.categoryCode withSince:_sinceID];
            }
            
            [newsCategoryArr addObject:newsCategory];
//        }
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
    
// We will be updating badge only after we download news, so badgeCount on newsCaregory API is not reqiured
    
    for (NewsCategoryModel *aModel in categories)
    {
//        NSInteger badgeCount = aModel.badgeCount  + [self badgeCountFor:aModel.categoryCode];
        NSInteger badgeCount = [self badgeCountFor:aModel.categoryCode];
        aModel.badgeCount = badgeCount;
    }
    
//    [dbManager dropTable:@"categories"];
    
    NSString *creatQuery = [NSString stringWithFormat:@"create table if not exists categories (name text, code text PRIMARY KEY, docCode text, badgeCount text)"];
    [dbManager createTableForQuery:creatQuery];
    
    for (NewsCategoryModel *aModel in categories)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO categories (name, code, docCode, badgeCount) values ('%@','%@','%@', '%li')",aModel.categoryName, aModel.categoryCode,aModel.categoryDocCode,(long)aModel.badgeCount];
        [dbManager saveDataToDBForQuery:insertSQL];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewsBadgeCount" object:nil];
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
    if ([dbManager isEqual:manager])
    {
        if (sqlite3_step(statment)== SQLITE_ROW)
        {
            NSString *badgeCountFromDB = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 0)];
            badgeForCurrentCategory = [badgeCountFromDB integerValue];
        }
    }else if ([dbManagerForBadgeCount isEqual:manager])
    {
        countForUnviewedNews = 0;
        while (sqlite3_step(statment) == SQLITE_ROW)
        {
            countForUnviewedNews++;
        }
        
        NSLog(@"UnViewCount %li",(long)countForUnviewedNews );
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



- (void)getNewsForCategoryCode:(NSString *)parentCode withSince:(NSInteger)sinceID
{
    NSString *parameterStringforNews = [NSString stringWithFormat:@"{\"request\":{\"NewsCategoryCode\":\"%@\",\"Since_Id\":\"%li\",\"Status\":\"Pushed\"}}",parentCode, (long)sinceID];
    [postMan post:NEWS_API withParameters:parameterStringforNews];
}

- (void)parseResponseDataForNews:(NSData*)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSArray *arr = json[@"aaData"][@"News"];
    
    NSString *parentCategory;
    NSMutableArray *newsArray = [[NSMutableArray alloc] init];
    
    if (arr.count == 0)
    {
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadedNewsUnSuccesfully" object:nil];
    }
    
    for (NSDictionary *adict in arr)
    {
        if ([adict[@"Status"] boolValue])
        {
            NSString *JSONString = adict[@"JSON"];
            NSDictionary *dictFromJSON = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            
            if ([dictFromJSON[@"Status"] isEqualToString:@"Pushed"] && ([self checkWhetherTagsExist:dictFromJSON[@"Tags"]] && [self checkWhetherAliasExist:dictFromJSON[@"Alias"]]))
            {
                NewsContentModel *newsContent = [[NewsContentModel alloc]init];
                newsContent.ID = [adict[@"ID"] integerValue];
                newsContent.newsCode =adict[@"Code"];
                
                newsContent.subject = dictFromJSON[@"Title"];
                newsContent.newsDetails =dictFromJSON[@"Content"];
                newsContent.htmlcontant = dictFromJSON[@"FormattedMessage"];
                
                newsContent.recivedDate = [NSDate date];
                newsContent.viewed = NO;
                
                if ([adict[@"ParentCode"] isKindOfClass:[NSNull class]])
                {
                    parentCategory = adict[@"NewsCategoryCode"];

                }else
                {
                    parentCategory = adict[@"ParentCode"];
                }
                newsContent.parentCategory = parentCategory;//this also should be Language paernt code of Category
                newsContent.languageParentCode = parentCategory;

                [newsArray addObject:newsContent];
            }
        }
    }
    
    [self saveNewsDetails:newsArray forParent:parentCategory];
    
    if (dbManagerForBadgeCount == nil)
    {
        dbManagerForBadgeCount = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManagerForBadgeCount.delegate=self;
    }
    
    //To update the parent badge no by geting unread messages in news table
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM n_%@ WHERE viewedFlag = 0",parentCategory];
    [dbManagerForBadgeCount getDataForQuery:query];
    
    BadgeNoManager *badge = [[BadgeNoManager alloc] init];
    [badge updateBadgeNoFor:parentCategory withNo:countForUnviewedNews];
    countForUnviewedNews = 0;
}

- (void)saveNewsDetails:(NSArray *)newsArray forParent:(NSString *)parentCategoryCode
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManager.delegate = self;
    }
    
    //Table names cannot begin with a number.Hence we are adding n_
    
    NSString *creatQuery = [NSString stringWithFormat:@"create table if not exists n_%@ (IDOfNews integer PRIMARY KEY, subject text, newsDetails text, htmlContent text, newsCode text, date text, viewedFlag integer)",parentCategoryCode];
    [dbManager createTableForQuery:creatQuery];
    
    NSDateFormatter *converter = [[NSDateFormatter alloc] init];
    [converter setDateFormat:@"yyyy MM dd HH mm ss"];
    
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
        
        NSMutableString *html = [amodel.htmlcontant mutableCopy];
        rangeofString.location = 0;
        rangeofString.length = html.length;
        [html replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
        
        //Table names cannot begin with a number.Hence we are adding n_
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO n_%@ (IDOfNews, subject, newsDetails, htmlContent, newsCode,date,viewedFlag) values (%li,'%@','%@','%@','%@','%@',%i)",parentCategoryCode, (long)amodel.ID, newsSubjectString, newsDetailsString, html, amodel.newsCode,
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

- (BOOL)checkWhetherTagsExist:(NSArray *)tags
{
    NSArray *deviceTags = [UserInfo sharedUserInfo].tags;

    if (tags == nil || tags.count == 0) //If admin didnt selected any tags, response is giving nil
    {
        return YES;
        
    }else if ([tags isKindOfClass:[NSArray class]])
    {
        for (NSString *aTag in tags)
        {
            if ([deviceTags containsObject:aTag]) return YES;
            
            NSLog(@"Tag %@ not existing",aTag);
        }
        
    }else if ([tags isKindOfClass:[NSString class]])
    {
        NSString *aTag = (NSString *) tags;
        return [deviceTags containsObject:aTag];
    }
    
    return NO;
}

- (BOOL)checkWhetherAliasExist:(NSString *)string {
    
    if (string.length == 0) {
        return YES;
    }
    
    NSArray *arrayOfAliases = [string componentsSeparatedByString:@";"];
    NSString *aliase = [UserInfo sharedUserInfo].alias;
    
    return [arrayOfAliases containsObject:aliase];
}

- (void)getLatestNewsIDWithCompletionner:(void (^)(BOOL success, NSInteger latestID))completionHandler
{
    [postMan get:LATEST_NEW_ID_API success:^(AFHTTPRequestOperation *operation, id responseObject) {
        /*{
         "aaData": {
         "Id": 6130,
         "Success": true
         }
         }*/
        NSDictionary *dict = responseObject[@"aaData"];
        if ([dict[@"Success"] boolValue])
        {
            NSInteger latestID = [dict[@"Id"] integerValue];
            completionHandler(YES, latestID);
        }else
        {
            completionHandler(NO, 0);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(NO, 0);
    }];
}

@end
