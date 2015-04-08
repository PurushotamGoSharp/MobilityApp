//
//  LanguageViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 11/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "LanguageViewController.h"
#import "Postman.h"
#import "LanguageModel.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DBManager.h"
#import <sqlite3.h>


@interface LanguageViewController ()<UITableViewDataSource,UITableViewDelegate,postmanDelegate,DBManagerDelegate>
{
    NSArray  *arrOfLanguageData;
    UILabel *titleLable;
    NSIndexPath* lastIndexPath;
    NSInteger selectedRow;
    NSMutableArray *languagesArrOfData;
    Postman *postMan;
    DBManager *dbManager;
    sqlite3 *database;



    __weak IBOutlet UIBarButtonItem *languageCancleButton;
    __weak IBOutlet UIBarButtonItem *languageDoneButton;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arrOfLanguageData = @[@"English"];

    postMan = [[Postman alloc] init];
    postMan.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSInteger selectedindex = [[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedLanguage"];
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedindex inSection:0];
    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:(UITableViewScrollPositionNone)];
    
    if ([AFNetworkReachabilityManager sharedManager].isReachable )
    {
        [self tryToUpdateLanguages];
    }else
    {
        [self getData];
    }
}
- (void) tryToUpdateLanguages
{
    NSString *parameters = @"{\"request\":{\"Name\":\"\",\"GenericSearchViewModel\":{\"Name\":\"\"}}}";
    [postMan post:SEARCH_LANGUAGE_API withParameters:parameters];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}



- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [self parseResponseData:response];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self saveLanguageData:response];

}

- (void)parseResponseData:(NSData*)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSArray *arr = json[@"aaData"][@"GenericSearchViewModels"];
    NSLog(@"Languages %@",json);
    languagesArrOfData = [[NSMutableArray alloc] init];
    for (NSDictionary *aDict in arr)
    {
        if ([aDict[@"Status"] boolValue] ) {
            LanguageModel *aLanguage = [[LanguageModel alloc] init];
            aLanguage.ID = [aDict[@"Id"] integerValue];
            aLanguage.code = aDict[@"Code"];
            aLanguage.name = aDict[@"Name"];
            [languagesArrOfData addObject:aLanguage];
        }
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [languagesArrOfData sortUsingDescriptors:@[sortDescriptor]];
    
    [self.tableView reloadData];
}
-(void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)saveLanguageData:(NSData*)response
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate = self;
    }
    
    NSString *query = @"create table if not exists languages (API text PRIMARY KEY, data text)";
    [dbManager createTableForQuery:query];
    
    NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSRange rangeofString;
    rangeofString.location = 0;
    rangeofString.length = stringFromData.length;
    [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
    
     NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  languages (API,data) values ('%@', '%@')", SEARCH_LANGUAGE_API,stringFromData];
    [dbManager saveDataToDBForQuery:insertSQL];
}


- (void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate = self;
    }
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM languages WHERE API = '%@'",SEARCH_LANGUAGE_API];
    if (![dbManager getDataForQuery:queryString])
    {
        [self tryToUpdateLanguages];
    }
}

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    if (sqlite3_step(statment) == SQLITE_ROW)
    {
        NSString *string = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        [self parseResponseData:data];
    }
}
- (IBAction)cancelBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    LanguageModel *selectedlanguage = languagesArrOfData[[self.tableView indexPathForSelectedRow].row];
    
    [[NSUserDefaults standardUserDefaults] setObject:selectedlanguage.name forKey:@"SelectedLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.delegate selectedLanguageis:selectedlanguage];
}

#pragma mark UITableViewDataSource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [languagesArrOfData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    LanguageModel *alanguage = languagesArrOfData[indexPath.row];
    
    titleLable = (UILabel *)[cell viewWithTag:100];
    titleLable.text = alanguage.name;
    titleLable.highlightedTextColor = [UIColor whiteColor];
   
    titleLable.font=[self customFont:16 ofName:MuseoSans_700];
    
//    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [self barColorForIndex:selectedRow];
    [cell setSelectedBackgroundView:bgColorView];

    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    
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
