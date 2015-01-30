//
//  AboutViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 27/01/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "AboutViewController.h"
#import "DBManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RateView.h"

@interface AboutViewController () <postmanDelegate, DBManagerDelegate>
{
    UIBarButtonItem *backButton;
    NSString *URLString;
    Postman *postMan;
    DBManager *dbManager;
    
    NSString *aboutDescription;
    NSString *ucbLogoDocCode;
    NSString *vmokshaLogoDocCode;
}

@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UIImageView *leftSideImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightSideImageView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UILabel *aboutUsLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionHeightConst;
@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    [back setTitle:@"Home" forState:UIControlStateNormal];
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];
    
    back.imageEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    back.frame = CGRectMake(0, 0,80, 30);
    
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
    URLString = ABOUT_DETAILS_API;
    
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"webclip"])
        {
            [self tryUpdateAboutDeatils];
            
        }else
        {
            [self  getData];
        }
    }
    else
    {
        [self  getData];
    }
    
    self.rateView.notSelectedImage = [UIImage imageNamed:@"starEmpty.png"];
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"starFull.png"];
    self.rateView.rating = 0;
    self.rateView.editable = NO;
    self.rateView.maxRating = 5;
    
    self.descriptionTextView.editable = YES;
    [self.descriptionTextView setFont:[self customFont:14 ofName:MuseoSans_300]];
    self.descriptionTextView.editable = NO;

    self.rateButton.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];
    self.averageLabel.font = [self customFont:16 ofName:MuseoSans_700];
    self.aboutUsLabel.font = [self customFont:16 ofName:MuseoSans_700];
    
    self.rateButton.layer.cornerRadius = 10;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateUI];
    
    [self.rateButton setBackgroundColor:[self barColorForIndex:[[NSUserDefaults standardUserDefaults] integerForKey:BACKGROUND_THEME_VALUE]]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)backBtnAction
{
    [self.tabBarController setSelectedIndex:0];
}

- (void)tryUpdateAboutDeatils
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [postMan get:URLString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI
{
    self.rateView.rating = 5;
    
//    self.leftSideImageView.image = [self getimageForDocCode:ucbLogoDocCode];
//    self.rightSideImageView.image = [self getimageForDocCode:vmokshaLogoDocCode];
//
    NSString *testString = @"This mobile app was developed in a partnership between Vmoksha Technologies and the UCB Mobility Team.  If you have an idea for a new app, or questions about app development, please contact the UCB Mobility Team at mobility.apple@ucb.com and we will schedule a meeting to understand your needs.  For more information, see www.vmokshagroup.com.";
    self.descriptionTextView.text = testString;
    
    
    CGSize expectedSize = [testString boundingRectWithSize:(CGSizeMake(self.descriptionTextView.frame.size.width, 10000))
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName: self.descriptionTextView.font}
                                           context:nil].size;
    
    self.descriptionHeightConst.constant = expectedSize.height + 20;
    [self.view layoutIfNeeded];
    
}


- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    [self updateUI];
}
#pragma mark
#pragma mark postmanDelegate

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if ([urlString isEqualToString:ABOUT_DETAILS_API])
    {
        [self parseResponsedata:response andgetImages:YES];
        
        [self saveAboutDetailsData:response forURL:urlString];
        
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"webclip"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else
    {
        [self createImages:response forUrl:urlString];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"document"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self updateUI];
}

- (void)parseResponsedata:(NSData *)response andgetImages:(BOOL)download
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSArray *arr = json[@"aaData"][@"AboutUs"];
    
    for (NSDictionary *aDict in arr)
    {
        NSString *language = aDict[@"Language"];
        if (![language isEqualToString:@"English"])
        {
            continue;
        }
        
        if ([aDict[@"Status"] boolValue])
        {
            if (download || [[NSUserDefaults standardUserDefaults] boolForKey:@"document"])
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                ucbLogoDocCode = aDict[@"UCBLogo_DocumentCode"];
                NSString *imageUrl = [NSString stringWithFormat:RENDER_DOC_API, ucbLogoDocCode];
                [postMan get:imageUrl];
                
                vmokshaLogoDocCode = aDict[@"VmokshaLogo_DocumentCode"];
                imageUrl = [NSString stringWithFormat:RENDER_DOC_API, vmokshaLogoDocCode];
                [postMan get:imageUrl];
            }
        }
    }
    
    [self updateUI];
}

- (void)saveAboutDetailsData:(NSData *)response forURL:(NSString *)APILink
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *createQuery = @"create table if not exists aboutDetails (API text PRIMARY KEY, data text)";
    [dbManager createTableForQuery:createQuery];
    
    NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSRange rangeofString;
    rangeofString.location = 0;
    rangeofString.length = stringFromData.length;
    [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
    
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  aboutDetails (API,data) values ('%@', '%@')", APILink,stringFromData];
    
    [dbManager saveDataToDBForQuery:insertSQL];
}

- (void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM aboutDetails WHERE API = '%@'", URLString];
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noNetworkAlert show];
        }
        
        [self tryUpdateAboutDeatils];
    }
}


- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    if (sqlite3_step(statment) == SQLITE_ROW)
    {
        NSString *string = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        [self parseResponsedata:data andgetImages:NO];
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
    
    [self updateUI];
}

- (UIImage *)getimageForDocCode:(NSString *)docCode
{
    NSString *pathToDoc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [pathToDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.png", docCode]];
    
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    
    if (imageData)
    {
        UIImage *tempImage = [UIImage imageWithData:imageData];
        UIImage *image = [UIImage imageWithCGImage:tempImage.CGImage scale:2 orientation:tempImage.imageOrientation] ;
        
        return image;
    }
    
    return nil;
}

@end
