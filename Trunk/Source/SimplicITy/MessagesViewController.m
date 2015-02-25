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

@interface MessagesViewController () <UITableViewDataSource,UITableViewDelegate,postmanDelegate,DBManagerDelegate>
{
    NSArray *arrOfTableData, *arrOfTimeLable, *arrOfSubjects, *arrOfBody, *arrOfimageName, *arrOfcurTime;
    NSMutableArray *arrOfModleData , *newsDetailsArr;
    UIBarButtonItem *backButton;
    
    Postman *postMan;
    NSString *URLString;
    
    NSString *databasePath;
    sqlite3 *database;
    DBManager *dbManager;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;
@property (strong ,nonatomic)UIRefreshControl *refreshControl;


@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    arrOfTableData = @[@"Web server will be down tomorrow", @"Updated dress code rules",@"Employee Awareness program is to be conducted on Dec 21"];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];

    back.imageEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0);
    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    back.frame = CGRectMake(0, 0,80, 40);
    
    //    back imageEdgeInsets = UIEdgeInsetsMake(<#CGFloat top#>, CGFloat left, <#CGFloat bottom#>, <#CGFloat right#>);

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

    
    
    
    
    arrOfTableData = @[@"Infra",@"Payroll",@"Helpdesk",@"HR policy: ",@"HR: Holiday Celebration: ",@"IS: Maintenance Activity"];
    
    arrOfSubjects = @[@"This mail is being sent to all employees on behalf of ISMS Team",@"Greetings from UCB Payroll Help Desk",@"SVN Credentials",@"Employee Awareness: “Official Dress Code”",@"Merry Christmas & A Happy New Year 2015!!!",@"IS Maintenance Activity on 26.07.2014"];
    
    arrOfcurTime = @[@"Thu, Dec 11, 2014",@"Mon Dec 8, 2014",@"Thu Nov 27, 2014",@"Mon Nov 17, 2014",@"Fri Dec 12, 2014",@"Fri Jul 25, 2014"];

    
    arrOfBody = @[@"Dear all, \nThis email is the second part of an Employee Awareness Program about Information Security in preparation for our ISO 27001 External Audit. Please read carefully some important Employee responsibilities and organization policies. The Ucb Security Policy, Confidentiality, Access and Physical security policies have been sent in yesterday’s email.",@"We are happy to inform you that UCB Payroll Help Desk is available online and here is useful information on how to access and utilize the facility",@"Hi,\n Please find your SVN Credentials below",@"Dear All,\nThis is to inform all the employees that the policy on “Official Dress Code” under Dress Code is being revised effective on Mon December 01, 2014.Dress code for external customer meetings will be Business Formals (to create the winning impression!!!). Business Formals will include - salwar suits and sarees, western formal skirts / trousers for ladies. Full/ half sleeved light-coloured shirts with tie and (jacket / coat optional) formal trousers for gentlemen. Footwear must be formal leather-shoes for men.Monday and Tuesday are considered as Business days and dress code will be Business formals. Business formals will include salwar suits and western skirts / trousers for ladies. Full/ half sleeved shirts tucked in and trousers for gentlemen. For men footwear must be formal shoes.",@"Dear All,\nMay this Christmas and New Year sparkle and shine. May all your wishes and dreams come true and may you feel this happiness all year round.So let’s get into Christmassy mood!!!Events:Cubical decoration – theme Christmas!Fun filled gamesSecret Santa Lucky Draw Venue: VM Cafeteria 4th floor Date & Time: 23rd Dec, 2014 @ 3PM Dress Code: Red & White\n\nThanks.\nHuman Resource",@"Dear All,\nThis is to inform you that there will be a fluctuation in the network connectivity due to maintenance activity on 26.07.2014 from 10:30 AM to 04:00 PM Services affected: Network, Network Shared Folders, Internet and VOIP services you to schedule your activities accordingly. Please contact helpdesk for any queries.\n\nThanks\n IS Team"];
    
    
    
    arrOfTimeLable = @[@"12 h",@"3 d",@"14 d",@"17 d",@"20 d",@"21 d",@"20 d"];
    
    arrOfimageName = @[@"MessageClosed"];
    
    arrOfModleData = [[NSMutableArray alloc] init];
    
    for (int i =0; i< arrOfTableData.count; i++)
    {
        messageModle *aMessage = [[messageModle alloc] init];
        aMessage.name = arrOfTableData[i];
        aMessage.subject = arrOfSubjects[i];
        aMessage.body = arrOfBody[i];
        aMessage.time = arrOfcurTime[i];
        [arrOfModleData addObject:aMessage];
    }
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.refreshControl.backgroundColor = [self subViewsColours];
    
    URLString = NEWS_API;
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    
    newsDetailsArr = [[NSMutableArray alloc] init];

    
    if (![AFNetworkReachabilityManager sharedManager].reachable)
    {
        [self getData];
    }else
    {
        [self tryToUpdate];
    }

    
}

-(void)tryToUpdate
{
    NSString *categoryCode = self.categoryModel.categoryCode;
    
    NSString *parameterStringforNews = [NSString stringWithFormat:@"{\"request\":{\"LanguageCode\":\"en\",\"NewsCategoryCode\":\"%@\",\"Since_Id\":\"\"}}",categoryCode];
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
            
            newsContent.recivedDate = [NSDate date];
            newsContent.viewed = NO;
//            NSLog(@"Content of News %@", newsContent.newsDetails );
            
            [newsDetailsArr addObject:newsContent];
            
        }
        
    }
    
//    NSDictionary *aNewDict = [arr firstObject];
//    NewsCategoryModel *parentCategory = [self categorymodelForCode:aNewDict[@"NewsCategoryCode"]];
//    parentCategory.newsArr = newsDetailsArr;
//    
//    [self saveNewsDetails:parentCategory];
    [self saveNewsDetails];

    [self.tableViewOutlet reloadData];

}

-(void) postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

}

-(void)saveNewsDetails
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManager.delegate = self;
    }
    
    NSString *creatQuery = [NSString stringWithFormat:@"create table if not exists %@ (IDOfNews integer PRIMARY KEY, subject text, newsDetails text, newsCode text, date text, viewedFlag integer)",self.categoryModel.categoryCode];
    [dbManager createTableForQuery:creatQuery];
    
    NSDateFormatter *converter = [[NSDateFormatter alloc] init];
    [converter setDateFormat:@"yyyy MM dd hh mm ss a"];
    
    for (NewsContentModel *amodel in newsDetailsArr)
    {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (IDOfNews, subject, newsDetails, newsCode,date,viewedFlag) values (%i,'%@',%@,'%@','%@',%i)",self.categoryModel.categoryCode, amodel.ID, amodel.subject, amodel.newsDetails,amodel.newsCode,
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

-(void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
        dbManager.delegate=self;
    }
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM %@",self.categoryModel.categoryCode];
    
    
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noNetworkAlert show];
        }
        
        [self tryToUpdate];
    }
}

-(void) DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    [newsDetailsArr removeAllObjects];
    
    while (sqlite3_step(statment)== SQLITE_ROW)
    {
        
        NSInteger ID = sqlite3_column_int(statment, 0);
        NSString *subject = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];

        NSString *newsDetail = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 2)];
        NSString *newsCode = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 3)];
        NSString *date = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 4)];
        NSInteger viewedFlag = sqlite3_column_int(statment, 5);
        
        
        
//        NewsCategoryModel *categoryModel = [[NewsCategoryModel alloc] init];
//        categoryModel.categoryName = categoryName;
//        categoryModel.categoryCode = categoryCode;
//        categoryModel.categoryDocCode = categoryDocCode;
        
        NewsContentModel *model = [[NewsContentModel alloc] init];
        model.ID = ID;
        model.subject = subject;
        model.newsDetails = newsDetail;
        model.newsCode = newsCode;
        
        NSDateFormatter *converter = [[NSDateFormatter alloc] init];
        [converter setDateFormat:@"yyyy MM dd hh mm ss a"];
        model.recivedDate = [converter dateFromString:date];
        
        model.viewed = viewedFlag;
        
        [newsDetailsArr addObject:model];
        
    }
    
    
}

-(void)backBtnAction
{
//    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)pull
{

    [NSThread sleepForTimeInterval:1];
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}

- (void)reloadData
{
    // Reload table data
    [self.tableViewOutlet reloadData];
    

    // End the refreshing
    if (self.refreshControl) {

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        [self.refreshControl endRefreshing];
    }
}


 -(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:@"message_segue"])
//    {
//        NSIndexPath *indexPath = [self.tableViewOutlet indexPathForSelectedRow];
//        MessageDetailViewController *messageDeteilVC = segue.destinationViewController;
//        messageModle *message = arrOfModleData[indexPath.row];
//        messageDeteilVC.mesgModel = message;
//    }

    NSIndexPath *indexPath = [self.tableViewOutlet indexPathForSelectedRow];
    MessageDetailViewController *messageDeteilVC = segue.destinationViewController;
    NewsContentModel *contentModel = newsDetailsArr[indexPath.row];
    
    messageDeteilVC.categoryName = self.categoryModel.categoryName;
    messageDeteilVC.newsContent = contentModel;
    
//    messageDeteilVC.newsDetail = contentModel.newsDetails;

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
//    titleLable.text = arrOfTableData[indexPath.row];
    
    NewsContentModel *newsContentModel = newsDetailsArr[indexPath.row];
    titleLable.text = newsContentModel.subject;
    
    titleLable.font=[self customFont:18 ofName:MuseoSans_700];
    
    UILabel *bodyTitleLable = (UILabel *)[cell viewWithTag:400];
    bodyTitleLable.text = newsContentModel.newsDetails;
    bodyTitleLable.font=[self customFont:14 ofName:MuseoSans_300];
    
    NSDate *curentDate = [NSDate date];
    NSDateFormatter *converter = [[NSDateFormatter alloc] init];

    
    
    if ([newsContentModel.recivedDate isEqualToDate:curentDate] )
    {
        [converter setDateFormat:@"hh mm ss a"];
        
    }else
    {
        [converter setDateFormat:@"dd MM"];

    }
    
    
    UILabel *timeTitleLable = (UILabel *)[cell viewWithTag:200];
    timeTitleLable.text = [converter stringFromDate:newsContentModel.recivedDate];
//
//    UILabel *subjectTitleLable = (UILabel *)[cell viewWithTag:300];
//    subjectTitleLable.text = arrOfSubjects[indexPath.row];
//    subjectTitleLable.font= [self customFont:20 ofName:MuseoSans_300];
//    
//    
//    
//    

//
//    
//    
//    UIImageView *mailImageView = (UIImageView *)[cell viewWithTag:500];
//
//    if (indexPath.row < self.emailreadNum)
//    {
//        mailImageView.image = [UIImage imageNamed:arrOfimageName[0]];
//    }else
//    {
//        
//    }


    return cell;
}

#pragma mark UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
//    if ([segue.identifier isEqualToString:@"message_segue"])

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (indexPath.row == 0)
//    {
//        [self performSegueWithIdentifier:@"message_segue" sender:nil];
//    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
