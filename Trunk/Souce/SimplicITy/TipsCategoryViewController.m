//
//  TipsCategoryViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/4/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TipsCategoryViewController.h"
//#import "TipsSubCategoriesViewController.h"
#import <sqlite3.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "DBManager.h"
#import "TipDetailsViewController.h"
#import "TipsGroupModel.h"

@interface TipsCategoryViewController () <UITableViewDataSource, UITableViewDelegate, postmanDelegate,DBManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConst;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation TipsCategoryViewController
{
    UIBarButtonItem *backButton;
    Postman *postMan;
    
    NSMutableArray *tipscategoryArray, *tipsCategoryCodeArray;
    
    NSArray *combinedDicts; //contains dicts with code and tips category.
    
    NSString *URLString;
    
    NSString *databasePath;
    sqlite3 *database;
    
    NSMutableDictionary *codeAndResponse;
    DBManager *dbManager;
    
    UIButton *back;
    BOOL loadData;
    NSString *langKey;
    NSString *parameter;
   // __weak IBOutlet UILabel *TipsCategory;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
   
    
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];

//    back.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//    back.frame = CGRectMake(0, 0,80, 30);

    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.navigationController.navigationBarHidden = NO;
    loadData = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
   langKey=[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLanguageCode"];
    NSLog(@"the value of key is %@",langKey);
    [super viewWillAppear:animated];
//    
    URLString = TIPS_CATEGORY_API;
    parameter =[NSString stringWithFormat:@"{\"request\":{\"LanguageCode\":\"%@\"}}",langKey];
//
    postMan = [[Postman alloc] init];
    postMan.delegate = self;

    if ([AFNetworkReachabilityManager sharedManager].isReachable && loadData)
    {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"tipsgroup"])
        {
            [self tryToUpdateCategories];
        }else
        {
            [self getData];
        }
    }
    else
    {
        [self getData];
    }

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];
}
-(void)localize
{
 [back setTitle:STRING_FOR_LANGUAGE(@"Home") forState:UIControlStateNormal];
    self.title = STRING_FOR_LANGUAGE(@"Tips");
    [back sizeToFit];
}




- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    loadData = YES;
}

- (void)backBtnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tryToUpdateCategories
{
    URLString = TIPS_CATEGORY_API;
//    NSString *parameterString;
   // parameterString = @"{\"request\":{\"LanguageCode\":\"%@\",}}";
    parameter =[NSString stringWithFormat:@"{\"request\":{\"LanguageCode\":\"%@\"}}",langKey];


    [postMan post:URLString withParameters:parameter];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark: UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tipscategoryArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    
    TipsGroupModel *tipsModel = tipscategoryArray[indexPath.row];
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    label.text = tipsModel.tipsGroupName;
    label.font=[self customFont:16 ofName:MuseoSans_700];
    [label sizeToFit];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
    imageView.image = [self getimageForDocCode:tipsModel.tipsGroupDocCode];
    
    UIView *containerView = [cell viewWithTag:102];
    containerView.layer.cornerRadius = 15;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSString *)codeForTipCategory:(NSString *)category
{
    for (NSDictionary *aDict in combinedDicts)
    {
        if ([aDict[@"Name"] isEqualToString:category])
        {
            return aDict[@"Code"];
        }
    }
    
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"tipsCatToDetailsSegue"])
    {
        TipDetailsViewController *tipDetailVC = (TipDetailsViewController *)segue.destinationViewController;
        TipsGroupModel *selectedTipsGroup = tipscategoryArray[[self.tableView indexPathForSelectedRow].row];
        tipDetailVC.parentCategory = selectedTipsGroup.tipsGroupName;
        tipDetailVC.parentCode = selectedTipsGroup.parentCode;
    }
}

#pragma mark
#pragma mark: postmanDelegate

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    if ([urlString isEqualToString:TIPS_CATEGORY_API])
    {
        [self parseResponseData:response andGetImages:YES];
        NSString *apiKey = [NSString stringWithFormat:@"%@-%@", urlString, parameter];
        [self saveTipsCategory:response forURL:apiKey];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tipsgroup"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else
    {
        [self createImages:response forUrl:urlString];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"document"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)parseResponseData:(NSData *)response andGetImages:(BOOL)download
{
    codeAndResponse = [[NSMutableDictionary alloc] init];
    tipscategoryArray = [[NSMutableArray alloc] init];

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    combinedDicts = json[@"aaData"][@"GenericSearchViewModels"];
    for (NSDictionary *aDict in combinedDicts)
    {
        if ([aDict[@"Status"] boolValue])
        {
            TipsGroupModel *tipsGroup = [[TipsGroupModel alloc] init];
            tipsGroup.tipsGroupName = aDict[@"Name"];
            tipsGroup.tipsGroupDocCode = aDict[@"DocumentCode"];
            tipsGroup.tipsGroupCode = aDict[@"Code"];
            tipsGroup.tipsLangCode = aDict [@"LanguageCode"];
            tipsGroup.parentCode = aDict [@"ParentCode"];

//            [[NSUserDefaults standardUserDefaults]setObject:tipsGroup.tipsGroupCode forKey:LANGUAGE_CODE];
//            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (download || [[NSUserDefaults standardUserDefaults] boolForKey:@"document"])
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                NSString *imageUrl = [NSString stringWithFormat:RENDER_DOC_API, aDict[@"DocumentCode"]];
                [postMan get:imageUrl];
            }
            [tipscategoryArray addObject:tipsGroup];
        }
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tipsGroupName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    tipscategoryArray = [[tipscategoryArray sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];

    [self.tableView reloadData];
    [self adjustTableViewHeigth];
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (NSString *)parentCodeForResponse:(NSData *)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    
    NSArray *subCatagoryArray = json[@"aaData"][@"Tips"];
    
    NSDictionary *aTip = [subCatagoryArray lastObject];
    
    return aTip[@"TipsGroupCode"];
}

- (void)saveTipsCategory:(NSData *)response forURL:(NSString *)APILink
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    [dbManager dropTable:@"tipCategory"];
    NSString *createQuery = @"create table if not exists tipCategory (API text PRIMARY KEY, data text)";
    [dbManager createTableForQuery:createQuery];
    
    NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSRange rangeofString;
    rangeofString.location = 0;
    rangeofString.length = stringFromData.length;
    [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
    
    NSString *apiKey = [NSString stringWithFormat:@"%@-%@", URLString, parameter];

    NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  tipCategory (API,data) values ('%@', '%@')", apiKey,stringFromData];

    [dbManager saveDataToDBForQuery:insertSQL];
}

- (void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *apiKey1 = [NSString stringWithFormat:@"%@-%@", URLString, parameter];
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM tipCategory WHERE API = '%@'", apiKey1];
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noNetworkAlert show];
        }
        
        [self tryToUpdateCategories];
    }
}

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    if (sqlite3_step(statment) == SQLITE_ROW)
    {
        NSString *string = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        [self parseResponseData:data andGetImages:NO];
    }else
    {
        [self tryToUpdateCategories];
    }
}

- (void)VCIsGoingToDisappear
{
    loadData = NO;
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
    
    [self.tableView reloadData];
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

- (void)adjustTableViewHeigth
{
    NSInteger noOfCells = [tipscategoryArray count];
    CGFloat cellHeigth = [self.tableView rowHeight];
    
    CGFloat heigthOfTableView = cellHeigth*noOfCells;
    
    heigthOfTableView = MIN(heigthOfTableView, self.containerView.frame.size.height);
    
    self.tableViewHeightConst.constant = heigthOfTableView;
    [self.containerView layoutIfNeeded];
}

@end
