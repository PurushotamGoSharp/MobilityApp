//
//  MessagesViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 03/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "MessagesViewController.h"
#import "MessageDetailViewController.h"
#import "messageModle.h"
#import "DashBoardViewController.h"
#import <sqlite3.h>
#import "DBManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NewsContentModel.h"
#import "BadgeNoManager.h"
#import "NewsCategoryFetcher.h"

@interface MessagesViewController () <UITableViewDataSource,UITableViewDelegate,postmanDelegate,DBManagerDelegate,UIWebViewDelegate>
{
    NSMutableArray  *newsDetailsArr;
    UIBarButtonItem *backButton;
    
    Postman *postMan;
    NSString *URLString;
    
    NSString *databasePath;
    sqlite3 *database;
    DBManager *dbManager, *dbManagerForGetUnViewed;
    
    NewsCategoryFetcher *categoryFetcher;
    UIButton *back;
    NSInteger countForUnviewedNews;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;
@property (strong ,nonatomic)UIRefreshControl *refreshControl;


@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    arrOfTableData = @[@"Web server will be down tomorrow", @"Updated dress code rules",@"Employee Awareness program is to be conducted on Dec 21"];
   
    back = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
   
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];

//    back.imageEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0);
//    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//    back.frame = CGRectMake(0, 0,80, 40);

    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
 
    self.title = self.categoryModel.categoryName;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [self subViewsColours];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(pull)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableViewOutlet  addSubview:self.refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNewsList)
                                                 name:@"DownloadedNewsSuccesfully"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNewsListForfailure)
                                                 name:@"DownloadedNewsUnSuccesfully"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];


}

-(void)localize
{
 [back setTitle:STRING_FOR_LANGUAGE(@"Back.Survey") forState:UIControlStateNormal];
    [back sizeToFit];
}






//- (BOOL)hidesBottomBarWhenPushed {
//    return YES;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.refreshControl.backgroundColor = [self subViewsColours];
    
    URLString = NEWS_API;
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    
    newsDetailsArr = [[NSMutableArray alloc] init];
    
//    if (![AFNetworkReachabilityManager sharedManager].reachable || self.categoryModel.badgeCount == 0)
//    {
//        [self getData];
//    }
//    else
//    {
//        [self tryToUpdate];
//    }
    
    [self getData];
    [self.tableViewOutlet reloadData];
}

- (void)updateNewsList
{
    [self getData];
    [self.tableViewOutlet reloadData];
    [self.refreshControl endRefreshing];
    
    
    if (dbManagerForGetUnViewed == nil)
    {
        dbManagerForGetUnViewed = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManagerForGetUnViewed.delegate = self;
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM n_%@ WHERE viewedFlag = 0",self.categoryModel.categoryCode];
    [dbManagerForGetUnViewed getDataForQuery:query];

}

- (void)updateNewsListForfailure
{
    [self.refreshControl endRefreshing];
}

- (void)tryToUpdate
{
    NSString *categoryCode = self.categoryModel.categoryCode;
    
    NSInteger sincID =[[NSUserDefaults standardUserDefaults]integerForKey:@"SinceID"];
    
    NSString *parameterStringforNews = [NSString stringWithFormat:@"{\"request\":{\"LanguageCode\":\"en\",\"NewsCategoryCode\":\"%@\",\"Since_Id\":\"%li\"}}",categoryCode,(long)sincID];
    [postMan post:URLString withParameters:parameterStringforNews];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

}

-(void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self parseResponseDataForNews:response];
}

- (void)parseResponseDataForNews:(NSData*)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    
    NSArray *arr = json[@"aaData"][@"News"];
    
    //    NSLog(@"json data %@",json);
    
    
    for (NSDictionary *adict in arr)
    {
        if ([adict[@"Status"] boolValue])
        {
            NewsContentModel *newsContent = [[NewsContentModel alloc]init];
            newsContent.ID = [adict[@"ID"] integerValue];
            newsContent.newsCode =adict[@"Code"];
            
            NSString *JSONString = adict[@"JSON"];
            NSDictionary *dictFromJSON = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            
            newsContent.subject = dictFromJSON[@"Title"];
            newsContent.newsDetails =dictFromJSON[@"Content"];
            newsContent.htmlcontant = dictFromJSON[@"FormattedMessage"];
            
            newsContent.recivedDate = [NSDate date];
            newsContent.viewed = NO;
//            NSLog(@"Content of News %@", newsContent.newsDetails );
            
            [newsDetailsArr addObject:newsContent];
        }
    }
    [self saveNewsDetails];

    [self getData];
    [self.tableViewOutlet reloadData];
}

- (void) postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

}

- (void)saveNewsDetails
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManager.delegate = self;
    }
    
    NSString *creatQuery = [NSString stringWithFormat:@"create table if not exists %@ (IDOfNews integer PRIMARY KEY, subject text, newsDetails text, htmlContent text, newsCode text, date text, viewedFlag integer)",self.categoryModel.categoryCode];
    [dbManager createTableForQuery:creatQuery];
    
    NSDateFormatter *converter = [[NSDateFormatter alloc] init];
    [converter setDateFormat:@"yyyy MM dd HH mm ss"];
    
    for (NewsContentModel *amodel in newsDetailsArr)
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
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (IDOfNews, subject, newsDetails, htmlContent, newsCode,date,viewedFlag) values (%li,'%@','%@', '%@','%@','%@',%i)",self.categoryModel.categoryCode, (long)amodel.ID, newsSubjectString, newsDetailsString, html, amodel.newsCode,
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

- (void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManager.delegate=self;
    }
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM n_%@ ORDER BY date DESC",self.categoryModel.categoryCode];
    
    
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noNetworkAlert show];
        }else
        {
//            [self tryToUpdate];
        }
    }
}

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    
    if (manager == dbManager)
    {
        [newsDetailsArr removeAllObjects];
        while (sqlite3_step(statment)== SQLITE_ROW)
        {
            NSInteger ID = sqlite3_column_int(statment, 0);
            NSString *subject = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
            NSString *newsDetail = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 2)];
            NSString *html = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 3)];

            NSString *newsCode = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 4)];
            NSString *date = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 5)];
            NSInteger viewedFlag = sqlite3_column_int(statment, 6);
            
            NewsContentModel *model = [[NewsContentModel alloc] init];
            model.ID = ID;
            model.subject = subject;
            model.newsDetails = newsDetail;
            model.htmlcontant = html;
            model.newsCode = newsCode;
            
            NSDateFormatter *converter = [[NSDateFormatter alloc] init];
            [converter setDateFormat:@"yyyy MM dd HH mm ss"];
            model.recivedDate = [converter dateFromString:date];
            
            model.viewed = viewedFlag;
            model.parentCategory = self.categoryModel.categoryCode;
            [newsDetailsArr addObject:model];
        }
    }
    else if (manager == dbManagerForGetUnViewed)
    {
        countForUnviewedNews = 0;
        while (sqlite3_step(statment) == SQLITE_ROW)
        {
            countForUnviewedNews++;
        }
        
        NSLog(@"UnViewCount %li",(long)countForUnviewedNews );
//To update the paernt badge no by geting unread messages in news table
        
        BadgeNoManager *badge = [[BadgeNoManager alloc] init];
        [badge updateBadgeNoFor:self.categoryModel.categoryCode withNo:countForUnviewedNews];
    }
}

- (void)backBtnAction
{
//    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pull
{
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)reloadData
{
    // Reload table data
//    [self.tableViewOutlet reloadData];

    // End the refreshing
    if (self.refreshControl)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
         NSInteger sincID =[[NSUserDefaults standardUserDefaults]integerForKey:@"SinceID"];
        
        if (categoryFetcher == nil)
        {
            categoryFetcher = [[NewsCategoryFetcher alloc] init];
        }
        
        [categoryFetcher getNewsForCategoryCode:self.categoryModel.categoryCode withSince:sincID];
        
        

    }
}


 -(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableViewOutlet indexPathForSelectedRow];
    MessageDetailViewController *messageDeteilVC = segue.destinationViewController;
    NewsContentModel *contentModel = newsDetailsArr[indexPath.row];
    
    messageDeteilVC.categoryName = self.categoryModel.categoryName;
    messageDeteilVC.newsContent = contentModel;
    
}

#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [newsDetailsArr count];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UILabel *titleLable = (UILabel *)[cell viewWithTag:300];
    
    NewsContentModel *newsContentModel = newsDetailsArr[indexPath.row];
    titleLable.text = newsContentModel.subject;
    
    

    UIWebView *titleOfWebView = (UIWebView *)[cell viewWithTag:400];
    
    UIImageView *messageimage = (UIImageView *)[cell viewWithTag:500];
    if (newsContentModel.viewed)
    {
        messageimage.image = [UIImage imageNamed:@"MessageOpen"];
        titleLable.font=[self customFont:18 ofName:MuseoSans_100];
    }else
    {
        messageimage.image = [UIImage imageNamed:@"MessageClosed"];
        titleLable.font=[self customFont:18 ofName:MuseoSans_700];

    }
    
    [titleOfWebView  loadHTMLString:[NSString stringWithFormat:@"<div id ='foo'  style='font-size:14px; font-family:MuseoSans-300; color:#808080';>%@<div>",newsContentModel.newsDetails] baseURL:nil];
    
    NSDateComponents *componentsFoCurrentDate = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger currentDay = [componentsFoCurrentDate day];
    
    
     NSDateComponents *componentsofDate = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:newsContentModel.recivedDate];
    NSInteger revivedDay = [componentsofDate day];

     NSDateFormatter *converter = [[NSDateFormatter alloc] init];
    if (currentDay == revivedDay)
    {
         [converter setDateFormat:@"h:mm a"];
    }
    else
    {
        [converter setDateFormat:@"dd/MM/yyyy"];
    }

    UILabel *timeTitleLable = (UILabel *)[cell viewWithTag:200];
    timeTitleLable.text = [converter stringFromDate:newsContentModel.recivedDate];
    timeTitleLable.font=[self customFont:14 ofName:MuseoSans_100];


    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
//        if (dbManager == nil)
//        {
//            dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
//            dbManager.delegate=self;
//        }
        NewsContentModel *newsModel = newsDetailsArr[indexPath.row];
        
        NSString *queryFordelete = [NSString stringWithFormat:@"DELETE FROM n_%@ WHERE IDOfNews = %li",self.categoryModel.categoryCode,(long)newsModel.ID];
        
        [dbManager deleteRowForQuery:queryFordelete];
        
        BadgeNoManager *badgemanager = [[BadgeNoManager alloc] init];
        [badgemanager decrementBadgeNoFor:newsModel.parentCategory];
        
        [newsDetailsArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    [tableView endUpdates];
//    [tableView reloadData];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *javascript = @"var style = document.createElement(\"style\"); document.head.appendChild(style); style.innerHTML = \"html{-webkit-text-size-adjust: 100%;} body {-webkit-text-size-adjust:100%;}\";var viewPortTag=document.createElement('meta');viewPortTag.id=\"viewport\";viewPortTag.name = \"viewport\";viewPortTag.content = \"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\";document.getElementsByTagName('head')[0].appendChild(viewPortTag);";
    [webView stringByEvaluatingJavaScriptFromString:javascript];
    
    [webView.scrollView setContentSize: CGSizeMake(webView.frame.size.width, webView.scrollView.contentSize.height)];
    [webView.scrollView setShowsVerticalScrollIndicator:NO];
}


#pragma mark UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
