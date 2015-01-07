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

@interface TipsCategoryViewController () <UITableViewDataSource, UITableViewDelegate, postmanDelegate>
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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    URLString = @"http://simplicitytst.ripple-io.in/Search/TipsGroup";

    [self getData];

}

- (void)backBtnAction
{
    [self.tabBarController setSelectedIndex:0];
}

- (void)tryToUpdateCategories
{
    URLString = @"http://simplicitytst.ripple-io.in/Search/TipsGroup";

//    if (![AFNetworkReachabilityManager sharedManager].reachable)
//    {
//        [self getData];
//        return;
//    }
    
    NSString *parameterString;
    parameterString = @"{\"request\":{\"Name\":\"\",\"GenericSearchViewModel\":{\"Name\":\"\"}}}";
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    [postMan post:URLString withParameters:parameterString];
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
        
    }
}

#pragma mark
#pragma mark: postmanDelegate

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    if ([urlString isEqualToString:@"http://simplicitytst.ripple-io.in/Search/TipsGroup"])
    {
        
        [self parseResponseData:response andUpdateSubCategories:YES];
        [self saveTipsCategory:response forURL:urlString];
    }else
    {
        NSString *parentCode = [self parentCodeForResponse:response];
        NSLog(@"%@",[self parentCodeForResponse:response]);
        
        codeAndResponse[parentCode] = response;
        
        [self saveTipsCategory:response forURL:urlString];
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
            
            if (update)
            {
                NSString *tipscategoryCode = aDict[@"Code"];
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                NSString *subCategoryURL = [NSString stringWithFormat:@"http://simplicitytst.ripple-io.in/%@/Tips", tipscategoryCode];
                [postMan get:subCategoryURL];
            }
        }
    }
    
    [self.tableView reloadData];
}


- (void)postman:(Postman *)postman gotFailure:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
    NSString *docsDir;
    NSArray *dirPaths;
    
    sqlite3_stmt *statement ;

    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"Tips.db"]];
    
    NSLog(@"Data Base Path %@",databasePath);
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if (![filemgr fileExistsAtPath: databasePath ])
    {
        if (sqlite3_open(dbpath, &database)== SQLITE_OK)
        {
            sqlite3_close(database);
        }
    }
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        
        //                const char *sql_stmt = "create table if not exists answer (regno integer primary key, name text, department text, year text)";
        
        const char *sql_stmt = "create table if not exists tipCategory (API text PRIMARY KEY, data text)";
        
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
            != SQLITE_OK)
        {
            NSLog(@"Failed to create table");
        }
        sqlite3_close(database);
    }
    else {
        NSLog(@"Failed to open/create database");
    }
    const char *dbPath = [databasePath UTF8String];
    
    if (sqlite3_open(dbPath, &database) == SQLITE_OK)
    {
        NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        //        NSLog(@"%@", stringFromData);
        NSRange rangeofString;
        rangeofString.location = 0;
        rangeofString.length = stringFromData.length;
        [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  tipCategory (API,data) values ('%@', '%@')", APILink,stringFromData];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"saved Sucessfully");
        }
        else
        {
            NSLog(@"Not saved ");
        }
    }
}

- (void)getData
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"Tips.db"]];
    
    NSLog(@"Data Base Path %@",databasePath);
    const char *dbPathUTF8 = [ databasePath UTF8String];

    
    if (sqlite3_open(dbPathUTF8, &database) == SQLITE_OK)
    {
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM tipCategory WHERE API = '%@'", URLString];
        const char *queryUTF = [queryString UTF8String];
        
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(database, queryUTF, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *string = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                
                NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

                [self parseResponseData:data andUpdateSubCategories:NO];
            }
            else
            {
                [self tryToUpdateCategories];
            }
            sqlite3_finalize(statement);
        }else
        {
            [self tryToUpdateCategories];
        }
        
        sqlite3_close(database);
    }else
    {
        NSLog(@"Unable to open db");
    }
}

@end
