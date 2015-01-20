//
//  TipsCategoryViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/4/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TipsCategoryViewController.h"
#import "TipsSubCategoriesViewController.h"
#import <sqlite3.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "DBManager.h"

@interface TipsCategoryViewController () <UITableViewDataSource, UITableViewDelegate, postmanDelegate,DBManagerDelegate, TipsSubCategoriesViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TipsCategoryViewController
{
    UIBarButtonItem *backButton;
    Postman *postMan;
    
    NSMutableArray *tipscategoryArray;
    
    NSArray *combinedDicts; //contains dicts with code and tips category.
    
    NSString *URLString;
    
    NSString *databasePath;
    sqlite3 *database;
    
    NSMutableDictionary *codeAndResponse;
    DBManager *dbManager;
    
    
    BOOL loadData;
   // __weak IBOutlet UILabel *TipsCategory;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    [back setTitle:@"Home" forState:UIControlStateNormal];
    
    back.titleLabel.font = [UIFont systemFontOfSize:17];
    back.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    back.frame = CGRectMake(0, 0,80, 30);

    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.navigationController.navigationBarHidden = NO;
    loadData = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    URLString = TIPS_CATEGORY_API;
    

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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    loadData = YES;
}

- (void)backBtnAction
{
    [self.tabBarController setSelectedIndex:0];
    
}

- (void)tryToUpdateCategories
{
    URLString = TIPS_CATEGORY_API;

//    if (![AFNetworkReachabilityManager sharedManager].reachable)
//    {
//        [self getData];
//        return;
//    }
    NSString *parameterString;
    parameterString = @"{\"request\":{\"Name\":\"\",\"GenericSearchViewModel\":{\"Name\":\"\"}}}";

    [postMan post:URLString withParameters:parameterString];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    label.text = tipscategoryArray[indexPath.row];
    
   
    label.font=[self customFont:16 ofName:MuseoSans_700];
    
    [label sizeToFit];
    [cell layoutIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    if ([segue.identifier isEqualToString:@"TipsCatToSubcatSegue"])
    {
        TipsSubCategoriesViewController *tipsSubVC = (TipsSubCategoriesViewController *)segue.destinationViewController;
        tipsSubVC.parentCategory = tipscategoryArray[[self.tableView indexPathForSelectedRow].row];
        tipsSubVC.parentCode = [self codeForTipCategory:tipsSubVC.parentCategory];
        tipsSubVC.delegate = self;
    }
}

#pragma mark
#pragma mark: postmanDelegate

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    if ([urlString isEqualToString:TIPS_CATEGORY_API])
    {
        
        [self parseResponseData:response andUpdateSubCategories:YES];
        [self saveTipsCategory:response forURL:urlString];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tipsgroup"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else
    {
        NSString *parentCode = [self parentCodeForResponse:response];
        NSLog(@"Parent code %@",parentCode);
        
        if (parentCode)
        {
            codeAndResponse[parentCode] = response;
        }
        
        [self saveTipsCategory:response forURL:urlString];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tips"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)parseResponseData:(NSData *)response andUpdateSubCategories:(BOOL)update
{
    codeAndResponse = [[NSMutableDictionary alloc] init];
    tipscategoryArray = [[NSMutableArray alloc] init];

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    combinedDicts = json[@"aaData"][@"GenericSearchViewModels"];
    for (NSDictionary *aDict in combinedDicts)
    {
        if ([aDict[@"Status"] boolValue])
        {
            [tipscategoryArray addObject:aDict[@"Name"]];
            
            if (update || [[NSUserDefaults standardUserDefaults] boolForKey:@"tips"])
            {
                    NSString *tipscategoryCode = aDict[@"Code"];
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    NSString *subCategoryURL = [NSString stringWithFormat:TIPS_SUBCATEGORY_API, tipscategoryCode];
                    [postMan get:subCategoryURL];
            }
        }
    }
    
    [self.tableView reloadData];
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
    
    NSString *createQuery = @"create table if not exists tipCategory (API text PRIMARY KEY, data text)";
    [dbManager createTableForQuery:createQuery];
    
    NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSRange rangeofString;
    rangeofString.location = 0;
    rangeofString.length = stringFromData.length;
    [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
    
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  tipCategory (API,data) values ('%@', '%@')", APILink,stringFromData];

    [dbManager saveDataToDBForQuery:insertSQL];
    
}

- (void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM tipCategory WHERE API = '%@'", URLString];
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:@"Warning !" message:@"The device is not connected to internet. Please connect the device to sync data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
        
        [self parseResponseData:data andUpdateSubCategories:NO];
    }
}

- (void)VCIsGoingToDisappear
{
    loadData = NO;
}

@end
