//
//  DashBoardViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/3/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "DashBoardViewController.h"
#import "MessagesViewController.h"
#import "RaiseATicketViewController.h"
#import "TicketsListViewController.h"
#import "Postman.h"
#import "LocationModel.h"
#import "DBManager.h"
#import "UserInfo.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "BadgeNoManager.h"

#import <MCLocalization/MCLocalization.h>

#define  CALL_IT_DESK_FROM_IPAD @"Calling facility is not available in this device"


@interface DashBoardViewController () <postmanDelegate,DBManagerDelegate,UIActionSheetDelegate>
{
    BOOL navBtnIsOn;
    UIButton *titleButton;
    UIImageView *downArrowImageView;
   UIView *titleView;
    UIImageView *titleImageView;
    NSMutableArray *locationdataArr ;
    LocationModel *selectedLocation;
    DBManager *dbManager;
    
    UserInfo *userInfo;
    NSString *callingNotavl;
    NSString *Alert;
    Postman *postMan;
    BadgeNoManager *badge;
    NSString *syncdatamessage;
}

@property (weak, nonatomic) IBOutlet UIButton *navtitleBtnoutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *profileViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardOrder;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardMessage;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardCallHelpDesk;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardTips;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardSetting;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardTicket;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardPersonName;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardPersonCode;
@property (weak, nonatomic) IBOutlet UILabel *dashMyTicketsLabel;
@property (weak, nonatomic) IBOutlet UILabel *dashMyOrdersLabel;
@property (weak, nonatomic) IBOutlet UILabel *dashWebClipLabel;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardPersonAddress;
@property (weak, nonatomic) IBOutlet UILabel *emailID;
@property (weak, nonatomic) IBOutlet UILabel *nameOfUserLabel;
@property (weak, nonatomic) IBOutlet UIView *alphaViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *containerViewOutlet;
@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *serviceDesksLbl;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popOverHeightConst;

@property (weak, nonatomic) IBOutlet UIImageView *raiseTicketImageOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *myticketsImageOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *newsImageOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *raiseOrderImageOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *tipsImageOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *myOrderImageOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *phoneImageOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *serviceImageOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *settingImageOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *badgeIcon;
@property (weak, nonatomic) IBOutlet UILabel *badgeLable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upgradeLblVertConst;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upgradeLblConstrain;
@end

@implementation DashBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];
    
   
    self.navtitleBtnoutlet.selected = NO;
    self.profileViewTopConstraint.constant = -107;
    if (![AFNetworkReachabilityManager sharedManager].reachable)
    {
        UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:STRING_FOR_LANGUAGE(@"Language.Alert") message:STRING_FOR_LANGUAGE(@"Sync.Data") delegate:nil cancelButtonTitle:OK_FOR_ALERT otherButtonTitles: nil];
        [noNetworkAlert show];
    }
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDateBadgeCount) name:@"NewsBadgeCount" object:nil];
    

    titleButton = [[UIButton alloc] init];
    
    [titleButton setImage:[UIImage imageNamed:@"DashBoardNavBarPersonImage"] forState:(UIControlStateNormal)];

    [titleButton addTarget:self action:@selector(navTitleBtnPressed:) forControlEvents:(UIControlEventTouchUpInside)];
    [titleButton setTitleColor:([UIColor whiteColor]) forState:(UIControlStateNormal)];
    titleButton.titleLabel.textColor = [UIColor whiteColor];
    [titleButton setTitle:@"Test" forState:(UIControlStateNormal)];
    titleButton.titleLabel.font = [self customFont:20 ofName:MuseoSans_700];
//    titleButton.frame = CGRectMake(titleImageView.frame.size.width+5, 0, 0, 0);
    titleButton.frame = CGRectMake(0, 5, 0, 0);

    [titleButton sizeToFit];
    
//    CGFloat widthOfView = titleButton.frame.size.width + titleImageView.frame.origin.x +30;
    CGFloat widthOfView = titleButton.frame.size.width ;

    titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthOfView, 40)];
    [titleView addSubview:titleButton];
//    [titleView addSubview:titleImageView];
    
    downArrowImageView = [[UIImageView alloc] initWithImage:([UIImage imageNamed:@"DashBoardDropDownBarImage"])];
    downArrowImageView.frame = CGRectMake(0, 0, 36, 3);
    downArrowImageView.center = CGPointMake(titleView.center.x, titleView.center.y + 18);
    [titleView addSubview:downArrowImageView];
    
    downArrowImageView.hidden = NO;
    
    self.navigationItem.titleView = titleView;
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
    {
        self.dashBoardMessage.font=[self customFont:14 ofName:MuseoSans_300];
        self.dashBoardCallHelpDesk.font=[self customFont:14 ofName:MuseoSans_300];
        self.dashBoardOrder.font=[self customFont:14 ofName:MuseoSans_300];
        self.dashBoardSetting.font=[self customFont:14 ofName:MuseoSans_300];
        self.dashBoardTicket.font=[self customFont:14 ofName:MuseoSans_300];
        self.dashBoardTips.font=[self customFont:14 ofName:MuseoSans_300];
        self.dashMyTicketsLabel.font=[self customFont:14 ofName:MuseoSans_300];
        self.dashMyOrdersLabel.font=[self customFont:14 ofName:MuseoSans_300];
        self.dashWebClipLabel.font=[self customFont:14 ofName:MuseoSans_300];
        
        self.dashBoardPersonName.font=[self customFont:16 ofName:MuseoSans_300];
        self.dashBoardPersonAddress.font=[self customFont:16 ofName:MuseoSans_300];
        self.dashBoardPersonCode.font=[self customFont:14 ofName:MuseoSans_300];
    }else
    {
        self.dashBoardMessage.font=[self customFont:20 ofName:MuseoSans_300];
        self.dashBoardCallHelpDesk.font=[self customFont:20 ofName:MuseoSans_300];
        self.dashBoardOrder.font=[self customFont:20 ofName:MuseoSans_300];
        self.dashBoardSetting.font=[self customFont:20 ofName:MuseoSans_300];
        self.dashBoardTicket.font=[self customFont:20 ofName:MuseoSans_300];
        self.dashBoardTips.font=[self customFont:20 ofName:MuseoSans_300];
        self.dashMyTicketsLabel.font=[self customFont:20 ofName:MuseoSans_300];
        self.dashMyOrdersLabel.font=[self customFont:20 ofName:MuseoSans_300];
        self.dashWebClipLabel.font=[self customFont:20 ofName:MuseoSans_300];
        
        self.nameOfUserLabel.font=[self customFont:20 ofName:MuseoSans_300];
        self.dashBoardPersonAddress.font=[self customFont:20 ofName:MuseoSans_300];
        self.dashBoardPersonCode.font=[self customFont:18 ofName:MuseoSans_300];
    }
    
    if ([UIScreen mainScreen].bounds.size.height < 667)
    {
        self.upgradeLblVertConst.constant = 25;
    }
    self.serviceDesksLbl.font = [self customFont:18 ofName:MuseoSans_700];
    
    userInfo = [UserInfo sharedUserInfo];
    selectedLocation = [[LocationModel alloc] init];
    [self setupLocation];
    self.badgeIcon.image = [[UIImage imageNamed:@"BadgeIcon"] resizableImageWithCapInsets:(UIEdgeInsetsMake(0, 10, 0, 10))];
    
    
}

-(void)localize
{
       
        syncdatamessage =  INTERNET_IS_REQUIRED_TO_SYNC_DATA;
        self.dashBoardMessage.text = [MCLocalization stringForKey:@"News"];
        self.dashBoardOrder.text = [MCLocalization stringForKey:@"Book.Room"];
        self.dashMyOrdersLabel.text = [MCLocalization stringForKey:@"Password.Expiry"];
        self.dashBoardSetting.text = [MCLocalization stringForKey:@"Upgrade.Device"];
        self.dashBoardTicket.text = [MCLocalization stringForKey:@"IT.SOS"];
        self.dashBoardTips.text = [MCLocalization stringForKey:@"Tips"];
        self.dashMyTicketsLabel.text = [MCLocalization stringForKey:@"My.tickets"];
        self.dashWebClipLabel.text = [MCLocalization stringForKey:@"Apps"];
        self.dashBoardCallHelpDesk.text = [MCLocalization stringForKey:@"Call.Desk"];
       callingNotavl = STRING_FOR_LANGUAGE(@"Calling.Facility");
       Alert = STRING_FOR_LANGUAGE(@"Language.Alert");
    
}

//-(UIImage*)imageResizing:(UIImage*)image
//{
//
//    CGRect cropRect = CGRectMake(0, 0, 128, 128);
//    UIGraphicsBeginImageContext(cropRect.size);
//    [image drawInRect:cropRect];
//    UIImage *newCropedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newCropedImage;
//}

-(void)upDateBadgeCount
{
    if (badge == nil)
    {
        badge = [[BadgeNoManager alloc] init];
    }
    
    NSInteger badgeNum = [badge totalNoBadges];
    if (badgeNum == 0)
    {
        self.badgeLable.hidden = YES;
        self.badgeIcon.hidden = YES;
    }else
    {
        self.badgeLable.hidden = NO;
        self.badgeIcon.hidden = NO;
        self.badgeLable.text = [NSString stringWithFormat:@"%li",(long)badgeNum];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.profileViewOutlet.backgroundColor = [self subViewsColours];
    [self updateProfileView];
    
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"office"])
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            NSString *parameter =  @"{\"request\":{\"Name\":\"\"}}";
            [postMan post:SEARCH_OFFICE_API withParameters:parameter];
        }
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"country"])
        {
            [self tryToGetITServicePhoneNum];
        }
        

    }
    
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:BACKGROUND_THEME_VALUE])
    {
        case 0:
            self.containerViewOutlet.backgroundColor = [UIColor colorWithRed:.7 green:.92 blue:.96 alpha:1];
            break;
        case 1:
            self.containerViewOutlet.backgroundColor = [UIColor colorWithRed:.86 green:.91 blue:.79 alpha:1];
            break;
        case 2:
            self.containerViewOutlet.backgroundColor = [UIColor colorWithRed:.97 green:.84 blue:.76 alpha:1];
            break;
        case 3:
            self.containerViewOutlet.backgroundColor = [UIColor colorWithRed:.93 green:.71 blue:.79 alpha:1];
            break;

        default:
            break;
    }
    [self upDateBadgeCount];
}


- (void)setupLocation
{
    if ([userInfo getServerConfig] != nil)
    {
        NSString *selectedLocationCode = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_LOCATION_CODE];
        
        if (![selectedLocationCode isEqualToString:userInfo.location])
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:SELECTED_OFFICE_NAME];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:SELECTED_OFFICE_MAILID];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:userInfo.location forKey:SELECTED_LOCATION_CODE];
        
        [self getDataForCountryCode:userInfo.location];
        
        [[NSUserDefaults standardUserDefaults] setObject:selectedLocation.countryName forKey:SELECTED_LOCATION_NAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"IND" forKey:SELECTED_LOCATION_CODE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self getDataForCountryCode:@"IND"];
        
        [[NSUserDefaults standardUserDefaults] setObject:selectedLocation.countryName forKey:SELECTED_LOCATION_NAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)updateProfileView
{
    if ([userInfo getServerConfig] != nil)
    {
        NSString *cropID = userInfo.cropID;
        NSString *firstName = userInfo.firstName;
        NSString *lastName = userInfo.lastName;
        NSString *location = userInfo.location;
        NSString *emailIDValue = userInfo.emailIDValue;
        
        NSString *nameOfPerson;
        
        self.dashBoardPersonCode.text = cropID;
        
        if (firstName)
        {
            [titleButton setTitle:firstName forState:(UIControlStateNormal)];
            [titleButton sizeToFit];
            
//            CGFloat widthOfView = titleButton.frame.size.width + titleImageView.frame.origin.x +30;
//            CGFloat widthOfView = titleButton.frame.size.width;
//
//            titleView.frame = CGRectMake(0, 0, widthOfView, 40);
//            downArrowImageView.center = CGPointMake(titleView.center.x , titleView.center.y + 18);
        }
        
        if (firstName || lastName)
        {
            if (firstName)
            {
                nameOfPerson = [firstName stringByAppendingString:[NSString stringWithFormat:@" %@",lastName]];
                
            }else if (lastName)
            {
                nameOfPerson = lastName;
            }
            
            self.nameOfUserLabel.text = nameOfPerson;
        }
        
        [self getDataForCountryCode:location];
        
        self.dashBoardPersonAddress.text = selectedLocation.countryName?:location;
        self.emailID.text = emailIDValue;
        
//        if (selectedLocation.countryName)
//        {
//            [self setupLocation];
//        }
    }
}

- (void)tryToGetITServicePhoneNum
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@",BASE_URL,@"Countries"];
    NSString *parameter =  @"{\"request\":{\"Name\":\"\"}}";
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [postMan post:URLString withParameters:parameter];
}

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    if ([urlString isEqualToString:[NSString stringWithFormat:@"%@%@",BASE_URL,@"Countries"]])
    {
        [self parseResponseData:response];
        [self saveLocationdata:response forUrl:urlString];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"country"];
        
        //    if ([[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_LOCATION_NAME]  == nil)
        //    {
        [self setupLocation];
        //    }
        [self updateProfileView];
        
    }else if ([urlString isEqualToString:SEARCH_OFFICE_API])
    {
        [self saveOfficeAddress:response forUrl:SEARCH_OFFICE_API];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"office"];

    }

}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)parseResponseData:(NSData *)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSArray *arr = json[@"aaData"][@"GenericSearchViewModels"];
    locationdataArr = [[NSMutableArray alloc] init];
    
    for (NSDictionary *aDict in arr)
    {
        if ([aDict[@"Status"]boolValue])
        {
            LocationModel *locationdata = [[LocationModel alloc] init];
            locationdata.code = aDict[@"Code"];
            locationdata.countryCode = aDict[@"CountryCode"];
            locationdata.countryName = aDict[@"Name"];
            NSString *JSONString = aDict[@"ServiceDeskNumber"];
            
            locationdata.serviceDeskNumber = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding]
                                                                             options:kNilOptions
                                                                               error:nil];
            [locationdataArr addObject:locationdata];
        }
    }
    
    [self.tableViewOutlet reloadData];
    [self adjustHeightOfPopOverView];
}

- (void)saveLocationdata:(NSData *)response forUrl:(NSString *)APILink
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *createQuery = @"create table if not exists location (countryCode text PRIMARY KEY, serviceDeskNumber text,countryName text, code text)";
    [dbManager createTableForQuery:createQuery];
    
    NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSRange rangeofString;
    rangeofString.location = 0;
    rangeofString.length = stringFromData.length;
    [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
    
    for (LocationModel *alocation in locationdataArr)
    {
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:alocation.serviceDeskNumber
                                                           options:kNilOptions
                                                             error:nil];
        NSString *serviceDeskNoJSON = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  location (countryCode,serviceDeskNumber,countryName,code) values ('%@', '%@','%@', '%@')", alocation.countryCode, serviceDeskNoJSON, alocation.countryName, alocation.code];
        
        //                NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  location (countryCode,serviceDeskNumber,countryName,code) values ('%@', '%@','%@', '%@')", alocation.countryCode, alocation.serviceDeskNumber, alocation.countryName, alocation.code];
        
        [dbManager saveDataToDBForQuery:insertSQL];
    }
}

- (void)saveOfficeAddress:(NSData *)response  forUrl:(NSString *)APILink
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate = self;
    }
    
    NSString *createQuery = @"create table if not exists officeLocations (API text PRIMARY KEY, data text)";
    [dbManager createTableForQuery:createQuery];
    
    NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSRange rangeofString;
    rangeofString.location = 0;
    rangeofString.length = stringFromData.length;
    [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
    
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  officeLocations (API,data) values ('%@', '%@')", APILink,stringFromData];
    
    [dbManager saveDataToDBForQuery:insertSQL];
}

- (BOOL)getDataForCountryCode:(NSString *)countryCode
{
    countryCode = [countryCode uppercaseString];
    
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM location WHERE countryCode = '%@'", countryCode];
    
    //    NSString *queryString = @"SELECT * FROM location WHERE countryCode = '%@'";
    
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:OK_FOR_ALERT otherButtonTitles: nil];
            [noNetworkAlert show];
            
            return NO;
        }else
        {
            return NO;
        }
    }
    return YES;
}

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    locationdataArr = [[NSMutableArray alloc] init];
    
    if (sqlite3_step(statment) == SQLITE_ROW)
    {
        selectedLocation.countryCode = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 0)];
        
        NSString *JSONString = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        selectedLocation.serviceDeskNumber = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding]
                                                                             options:kNilOptions
                                                                               error:nil];
        //        selectedLocation.serviceDeskNumber = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        
        selectedLocation.countryName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 2)];
        selectedLocation.code = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 3)];
        
        [locationdataArr addObject:selectedLocation];
    }
    
    [self.tableViewOutlet reloadData];
    [self adjustHeightOfPopOverView];
    
}

- (void)navTitleBtnPressed:(id)sender
{
    NSInteger constrainValue;
    if (!navBtnIsOn)
    {
        constrainValue = 1;
        navBtnIsOn = YES;
    }else
    {
        constrainValue = -107;
        navBtnIsOn = NO;
    }
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.profileViewTopConstraint.constant = constrainValue;
                         [self.view layoutIfNeeded];
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.profileViewTopConstraint.constant = -107;
    navBtnIsOn = NO;
    [self cancelPopUp:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)messageButtonPressed:(UIButton *)sender
{
}

- (IBAction)raiseATicketPressed:(UIButton *)sender
{
    //    [self.tabBarController setSelectedIndex:1];
}

- (IBAction)tipsButtonPressed:(UIButton *)sender
{
}

- (IBAction)myTicketsBtnPressed:(id)sender
{
    //    [self.tabBarController setSelectedIndex:1];
    
}

- (IBAction)myOrderBtnPresed:(id)sender
{
    
}
- (IBAction)upgradeBtnPressed:(id)sender
{
}

- (IBAction)initiateCallForITHelpDesk:(UIButton *)sender
{
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        NSString *countryCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLocationCode"];
        
        if (![self getDataForCountryCode:countryCode])
        {
            if ([AFNetworkReachabilityManager sharedManager].reachable)
            {
                [self tryToGetITServicePhoneNum];
            }
            
            return;
        }
        
        NSLog(@"country %@",selectedLocation.serviceDeskNumber);
        
        if (selectedLocation.serviceDeskNumber.count > 1 )
        {
            self.alphaViewOutlet.hidden = NO;
            self.containerViewOutlet.hidden = NO;
            
            [UIView animateWithDuration:.3 animations:^{
                self.alphaViewOutlet.alpha= .5;
                self.containerViewOutlet.alpha = 1;
            } completion:^(BOOL finished)
             {
                 
             }];
        }else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self phoneNumValidation]]];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Alert message:callingNotavl delegate:self cancelButtonTitle:OK_FOR_ALERT otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [selectedLocation.serviceDeskNumber count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UILabel *name = (UILabel*)[cell viewWithTag:100];
    name.font = [self customFont:14 ofName:MuseoSans_300];
    
    //phoneNum.text = self.serviceDeskDeteils;
    
    NSDictionary *dict = selectedLocation.serviceDeskNumber[indexPath.row];
    
    name.text = dict[@"Name"];
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [UIView animateWithDuration:.3 animations:^{
        self.alphaViewOutlet.alpha= 0;
        self.containerViewOutlet.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.alphaViewOutlet.hidden = YES;
        self.containerViewOutlet.hidden = YES;
    }];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self phoneNumValidation]]];
    
    NSLog(@"%@", [self phoneNumValidation]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString*)phoneNumValidation
{
    NSIndexPath *indexpath = [self.tableViewOutlet indexPathForSelectedRow];
    
    NSDictionary *dict = selectedLocation.serviceDeskNumber[indexpath.row];
    
    NSString *phoneNoFromDict = dict[@"Number"];
    
    
    NSMutableString *phoneNoToCall = [NSMutableString
                                      stringWithCapacity:phoneNoFromDict.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:phoneNoFromDict];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"+0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer])
        {
            [phoneNoToCall appendString:buffer];
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    
    //    NSLog(@"%@", phoneNoToCall); // "123123123"
    phoneNoToCall = [[@"tel://" stringByAppendingString:phoneNoToCall] mutableCopy];
    return phoneNoToCall;
}

- (void)adjustHeightOfPopOverView
{
    if ([selectedLocation.serviceDeskNumber count] > 1)
    {
        CGFloat heightOfTableView = [self.tableViewOutlet contentSize].height;
        heightOfTableView = MIN(300, heightOfTableView);
        
        CGFloat heightOfPopOverView = 30 + heightOfTableView + 30;
        
        self.popOverHeightConst.constant = heightOfPopOverView;
        [self.view layoutIfNeeded];
    }
}

- (IBAction)cancelPopUp:(UIControl *)sender
{
    [UIView animateWithDuration:.3 animations:^{
        self.alphaViewOutlet.alpha= 0;
        self.containerViewOutlet.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.alphaViewOutlet.hidden = YES;
        self.containerViewOutlet.hidden = YES;
    }];
}

//-(NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}
//
//-(BOOL)shouldAutorotate {
//    return NO;
//}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"dashToOrder_segue"])
    {
        RaiseATicketViewController *raiseTicket = segue.destinationViewController;
        raiseTicket.orderDiffer = FLOW_FOR_ORDER;
        
    }if ([segue.identifier isEqualToString:@"DashToMyOrdersSegue"])
    {
        TicketsListViewController *orderList = segue.destinationViewController;
        orderList.orderItemDifferForList = @"orderList";
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
