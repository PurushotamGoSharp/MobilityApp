//
//  MessageTileViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 09/01/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "MessageTileViewController.h"
#import "MessagesViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NewsCategoryModel.h"
#import <sqlite3.h>
#import "DBManager.h"
#import "NewsContentModel.h"

#import "NewsCategoryFetcher.h"


@interface MessageTileViewController ()<UITabBarControllerDelegate,UITableViewDataSource, UITableViewDelegate,postmanDelegate,DBManagerDelegate>
{
    NSArray *arrOfData, *arrOfImages,*arrayOfBadgeNUm;
     UIBarButtonItem *backButton;
    
    Postman *postMan;
    NSString *URLString;
    
    NSInteger countForNoOfCategories;
    
    NSMutableArray *newsCategoryArr;
    UIButton *back;
    NSString *databasePath;
    sqlite3 *database;
    DBManager *dbManager, *dbManagerForNOOfCategories;
    NewsCategoryFetcher *fetcher;
//    NSMutableArray *newsCategoryNameArr, *newsCategoryCodeArr, *newsIDArr, *newsCodeArr, *newsDetailsArr;

}
@property (weak, nonatomic) IBOutlet UITableView *tableViewoutlet;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeightConst;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *noMessageLabel;

@end

@implementation MessageTileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   back = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];

//    back.imageEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
//    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//    back.frame = CGRectMake(0, 0,80, 30);
    
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:@"NewCategoryGotSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:@"NewsBadgeCount" object:nil];


    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];

}

-(void)localize
{
    [back setTitle:STRING_FOR_LANGUAGE(@"Home") forState:UIControlStateNormal];
    [back sizeToFit];
    self.title = STRING_FOR_LANGUAGE(@"News");
    self.noMessageLabel.text = STRING_FOR_LANGUAGE(@"No.News");

}





- (void)updateData
{
    [self getData];
    [self.tableViewoutlet reloadData];
    [self adjustTableViewHeigth];
    
    if (newsCategoryArr.count > 0)
    {
        self.noMessageLabel.hidden = YES;
    }
}

- (void)backBtnAction
{
      [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    newsCategoryArr =   [[NSMutableArray alloc] init];
    
//    if (![AFNetworkReachabilityManager sharedManager].reachable)
//    {
//        [self getData];
//    }else
//    {
////        [self tryToUpdateNewsCategories];
//        
//        fetcher = [[NewsCategoryFetcher alloc] init];
//        
//        NSInteger sincID = [[NSUserDefaults standardUserDefaults]integerForKey:@"SinceID"];
//        sincID = 4;
//        [fetcher initiateNewsCategoryAPIFor:sincID];
//        
//    }
    
    [self getData];
    [self.tableViewoutlet reloadData];
    [self adjustTableViewHeigth];
    
    if (newsCategoryArr.count > 0)
    {
        self.noMessageLabel.hidden = YES;
    }
}

- (void)tryToUpdateNewsCategories
{
    URLString = NEWS_CATEGORY_API;
    NSString *parameterString;
    
    parameterString = @"{\"request\":{\"Name\":\"\",\"GenericSearchViewModel\":{\"Name\":\"\"}}}";
    [postMan post:URLString withParameters:parameterString];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark
#pragma mark: postmanDelegate

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

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
    
    for (NSDictionary *adict in arr)
    {
        if ([adict[@"Status"] boolValue])
        {
            NewsCategoryModel *newsCategory = [[NewsCategoryModel alloc] init];
            newsCategory.categoryCode = adict[@"Code"];
            newsCategory.categoryName = adict[@"Name"];
            newsCategory.categoryDocCode = adict[@"DocumentCode"];
            
            if (download)
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                NSString *imageUrl = [NSString stringWithFormat:RENDER_DOC_API, adict[@"DocumentCode"]];
                [postMan get:imageUrl];
            }
            
             [newsCategoryArr addObject:newsCategory];
        }
    }
    
    [self saveCategoies:newsCategoryArr];
    
    [self.tableViewoutlet reloadData];
    [self adjustTableViewHeigth];

}

- (void)parseResponseDataForNews:(NSData*)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
 
    NSArray *arr = json[@"aaData"][@"News"];
    
//    NSLog(@"json data %@",json);
    
    
    NSMutableArray *newsDetailsArr = [[NSMutableArray alloc] init];
    
    for (NSDictionary *adict in arr)
    {
        if ([adict[@"Status"] boolValue])
        {
            NewsContentModel *newsContent = [[NewsContentModel alloc]init];
            newsContent.ID = [adict[@"ID"] integerValue];
            newsContent.newsCode =adict[@"Code"];
            newsContent.newsDetails =adict[@"JSON"];
            [newsDetailsArr addObject:newsContent];
        }
    }
    
    NSDictionary *aNewDict = [arr firstObject];
    NewsCategoryModel *parentCategory = [self categorymodelForCode:aNewDict[@"ParentCode"]];
    parentCategory.newsArr = newsDetailsArr;
    
//    [self saveNewsDetails:parentCategory];
}

- (NewsCategoryModel *)categorymodelForCode:(NSString *)categoryCode
{
    for (NewsCategoryModel *aModel  in newsCategoryArr)
    {
        if ([categoryCode isEqualToString:aModel.categoryCode])
        {
            return aModel;
        }
    }
    
    return nil;
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
    
    [self.tableViewoutlet reloadData];
    [self adjustTableViewHeigth];
}

- (UIImage *)getimageForDocCode:(NSString *)docCode
{
    NSString *pathToDoc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [pathToDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.png", docCode]];
    
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    
    if (imageData)
    {
        UIImage *tempImage = [UIImage imageWithData:imageData];
        imageData = nil;
        UIImage *webClipImage = [UIImage imageWithCGImage:tempImage.CGImage scale:2 orientation:tempImage.imageOrientation] ;
        tempImage = nil;
        return webClipImage;
    }
    
    return nil;
}

-(void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSLog(@"error %@",error);
}

- (void)saveCategoies:(NSArray *)categories
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManager.delegate = self;
    }
    
    [dbManager dropTable:@"categories"];
    NSString *creatQuery = [NSString stringWithFormat:@"create table if not exists categories (name text, code text PRIMARY KEY, docCode text)"];
    [dbManager createTableForQuery:creatQuery];
    
    for (NewsCategoryModel *aModel in categories)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO categories (name, code, docCode) values ('%@','%@','%@')",aModel.categoryName, aModel.categoryCode,aModel.categoryDocCode];
        [dbManager saveDataToDBForQuery:insertSQL];
    }
}

-(void)saveNewsDetails:(NewsCategoryModel *)categoryModel
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManager.delegate = self;
    }
    
    NSString *creatQuery = [NSString stringWithFormat:@"create table if not exists %@ (IDOfNews integer PRIMARY KEY, newsDetails text, newsCode text)",categoryModel.categoryCode];
    [dbManager createTableForQuery:creatQuery];
    
    for (NewsContentModel *aNews in categoryModel.newsArr)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO %@ (IDOfNews, newsDetails, newsCode) values (%li,'%@','%@')",categoryModel.categoryCode ,(long)aNews.ID,aNews.newsDetails,aNews.newsCode];
        
        [dbManager saveDataToDBForQuery:insertSQL];
        
        NSInteger currentSinceID = [[NSUserDefaults standardUserDefaults] integerForKey:@"SinceID"];
        
        if (aNews.ID > currentSinceID)
        {
            [[NSUserDefaults standardUserDefaults] setInteger:aNews.ID forKey:@"SinceID"];
        }
    }
}

- (void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManager.delegate=self;
    }

    NSString *queryString = @"SELECT * FROM categories";
    
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noNetworkAlert show];
        }
        
        
    }
}

- (void) DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    if ([manager isEqual:dbManager])
    {
        [newsCategoryArr removeAllObjects];
        
        while (sqlite3_step(statment)== SQLITE_ROW)
        {
            NSString *categoryName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 0)];
            NSString *categoryCode = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
            NSString *categoryDocCode = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 2)];
            NSString *badge = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 3)];
            
            NewsCategoryModel *categoryModel = [[NewsCategoryModel alloc] init];
            categoryModel.categoryName = categoryName;
            categoryModel.categoryCode = categoryCode;
            categoryModel.categoryDocCode = categoryDocCode;
            categoryModel.badgeCount = [badge integerValue];
            
            if (dbManagerForNOOfCategories == nil)
            {
                dbManagerForNOOfCategories = [[DBManager alloc] initWithFileName:@"News.db"];;
                dbManagerForNOOfCategories.delegate=self;
            }
            NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM n_%@ ORDER BY date DESC",categoryCode];
            countForNoOfCategories = 0;
            [dbManagerForNOOfCategories getDataForQuery:queryString];
            
            if (countForNoOfCategories != 0)
            {
                [newsCategoryArr addObject:categoryModel];
            }else
            {
//                if ([categoryModel.categoryCode isEqualToString:@"OK2UPDATE"]) {
//                    [newsCategoryArr addObject:categoryModel];
//                }
            }
        }

        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"categoryName" ascending:YES];
        [newsCategoryArr sortUsingDescriptors:@[sortDescriptor]];
        
    }else if ([manager isEqual:dbManagerForNOOfCategories])
    {
        countForNoOfCategories = 0;
        while (sqlite3_step(statment)== SQLITE_ROW)
        {
            countForNoOfCategories++;
        }
    }
    
}

//- (IBAction)btnAction:(id)sender
//{
//    [self performSegueWithIdentifier:@"messagesList_segue" sender:self];
//}


#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (newsCategoryArr.count > 0)
    {
        self.noMessageLabel.hidden = YES;
    }else
    {
        self.noMessageLabel.hidden = NO;
    }
    
    return [newsCategoryArr count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UIView *containerView = (UIView *)[cell viewWithTag:111];
    containerView.layer.cornerRadius = 15;
    containerView.layer.masksToBounds = YES;
    UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
//    titleLable.layer.cornerRadius= 5;
//    titleLable.layer.masksToBounds = YES;
//    titleLable.text = newsCategoryNameArr[indexPath.row];
    titleLable.font=[self customFont:15 ofName:MuseoSans_700];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NewsCategoryModel *newsCategory =newsCategoryArr[indexPath.row];
    titleLable.text = newsCategory.categoryName;
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:200];
    imageView.image = [self getimageForDocCode:newsCategory.categoryDocCode];
    
    UIImageView *badgeView = (UIImageView *)[cell viewWithTag:400];
    badgeView.image = [[UIImage imageNamed:@"BadgeIcon"] resizableImageWithCapInsets:(UIEdgeInsetsMake(0, 10, 0, 10))];
    
    UILabel *lableForBadege = (UILabel*)[cell viewWithTag:500];
    
    if (newsCategory.badgeCount == 0)
    {
        badgeView.hidden = YES;
        lableForBadege.hidden = YES;
    }
    else
    {
        badgeView.hidden = NO;
        lableForBadege.hidden = NO;
        lableForBadege.text = [NSString stringWithFormat:@"%li", (long)newsCategory.badgeCount] ;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
    titleLable.backgroundColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MessagesViewController *messagesVC = (MessagesViewController *) segue.destinationViewController;
    messagesVC.categoryModel = newsCategoryArr[[self.tableViewoutlet indexPathForSelectedRow].row];
    messagesVC.emailreadNum = [arrayOfBadgeNUm[[self.tableViewoutlet indexPathForSelectedRow].row] integerValue];
}

- (void)adjustTableViewHeigth
{
    NSInteger noOfCells = [newsCategoryArr count];
    CGFloat cellHeigth = [self.tableViewoutlet rowHeight];
    
    CGFloat heigthOfTableView = cellHeigth*noOfCells;
    
    heigthOfTableView = MIN(heigthOfTableView, self.containerView.frame.size.height);
    
    self.tableHeightConst.constant = heigthOfTableView;
    [self.containerView layoutIfNeeded];
}

@end
