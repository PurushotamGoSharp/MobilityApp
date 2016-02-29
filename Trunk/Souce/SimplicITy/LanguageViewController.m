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
#import "LanguageChangerClass.h"
#import <MCLocalization/MCLocalization.h>

#import "AppDelegate.h"



@interface LanguageViewController ()<UITableViewDataSource,UITableViewDelegate,postmanDelegate,DBManagerDelegate,languageChangeProtocol>
{
    NSArray  *arrOfLanguageData;
    UILabel *titleLable;
    NSIndexPath* lastIndexPath;
    NSInteger selectedRow;
    NSMutableArray *languagesArrOfData;
    Postman *postMan;
    DBManager *dbManager;
    sqlite3 *database;
    LanguageChangerClass *langChanger;
    NSString *selectedLangCode;
    
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
    langChanger =[[LanguageChangerClass alloc]init];
    postMan.delegate = self;
    langChanger.delegate = self;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    selectedLangCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLanguageCode"];
    //    NSString *selectedLangName = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLanguageName"];
    
    if (selectedLangCode == nil)
    {
        selectedLangCode = @"en";
    }
    
    if ([AFNetworkReachabilityManager sharedManager].isReachable )
    {
        [self tryToUpdateLanguages];
    }else
    {
        [self getData];
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];


}




-(void)localize
{
    
    [self.navigationItem.rightBarButtonItem setTitle:STRING_FOR_LANGUAGE(@"Done")];
    [self.navigationItem.leftBarButtonItem setTitle:STRING_FOR_LANGUAGE(@"Cancel")];
    self.title = STRING_FOR_LANGUAGE(@"Language");
 
}






- (void) tryToUpdateLanguages
{
    NSString *parameters = @"{\"request\":{\"Name\":\"\",\"GenericSearchViewModel\":{\"Name\":\"\"}}}";
    [postMan post:SEARCH_LANGUAGE_API withParameters:parameters];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}


- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    
    if ([urlString isEqualToString:SEARCH_LANGUAGE_API])
    {
        [self parseResponseData:response];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self saveLanguageData:response];
    }else
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSString *langCode =  [self parseLangChangeResponseData:response];
        
        //        [MCLocalization sharedInstance].language = langCode;
    }
    
    
}

-(NSString*)parseLangChangeResponseData:(NSData*)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    
    NSArray *arr = json[@"aaData"][@"UILabels"];
    
    NSMutableDictionary *aaData = [[NSMutableDictionary alloc] init];
    
    NSString *languageCode;
    
    for (NSDictionary *adict in arr)
    {
        NSString *key = adict[@"UserFriendlyCode"];
        NSString *value = adict[@"Name"];
        
        languageCode = adict[@"LanguageCode"];
        
        NSMutableDictionary  *adictnory = [NSMutableDictionary dictionaryWithObject:value forKey:key];
        [aaData addEntriesFromDictionary:adictnory];
    }
    
    NSLog(@"language %@",aaData);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aaData options:0 error:&error];
    
    
    [[NSUserDefaults standardUserDefaults]setObject:languageCode forKey:LANGUAGE_CODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //    [self sample];
    
    NSFileManager *fmngr = [[NSFileManager alloc] init];
    
    AppDelegate *appDel = [UIApplication sharedApplication].delegate;
    
    NSString *filePth = [self getFilePath:languageCode];
    
    if (![fmngr fileExistsAtPath:filePth])
    {
        [jsonData writeToFile:filePth atomically:YES];
        
        NSURL *filePathUrl = [NSURL fileURLWithPath:filePth];
        
        [appDel.languageUrlPairs setObject:filePathUrl forKey:languageCode];
        
        NSLog(@"json files %@",[appDel.languageUrlPairs allKeys]);
        
        //        [MCLocalization loadFromLanguageURLPairs:appDel.languageUrlPairs defaultLanguage:@"en"];
        //        [MCLocalization sharedInstance].noKeyPlaceholder = @"[No '{key}' in '{language}']";
        
    }else
    {
        NSLog(@"File already Exists");
    }
    
    
    //    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
    //    [appDel.languageUrlPairs setObject:filePathUrl forKey:languageCode];
    
    
    return languageCode;
}

- (NSString *)getFilePath:(NSString *)langCode
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.json",langCode];
    
    return [documentsDir stringByAppendingPathComponent:fileName];
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
    
    NSInteger index = 0;
    
    for (LanguageModel *aLanguage in languagesArrOfData)
    {
        if ([aLanguage.code isEqualToString:selectedLangCode])
        {
            selectedRow = index;
        }
        index++;
    }
    [self.tableView reloadData];
    
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:(UITableViewScrollPositionNone)];
}
- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
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
    
    LanguageModel *selectedlanguage = languagesArrOfData[[self.tableView indexPathForSelectedRow].row];
    NSString *currentLang =[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedLanguageCode"];
    
    if ([currentLang isEqualToString:selectedlanguage.code]) {
        [self dismissViewControllerAnimated:YES completion:nil];

    } else {
        [[NSUserDefaults standardUserDefaults] setObject:selectedlanguage.name forKey:@"SelectedLanguageName"];
        [[NSUserDefaults standardUserDefaults] setObject:selectedlanguage.code forKey:@"SelectedLanguageCode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
        NSString *seedKeyForLang = [NSString stringWithFormat:@"uilabel,%@",selectedlanguage.code];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:seedKeyForLang])
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [langChanger changeLanguageWithCode:selectedlanguage.code];
        }else
        {
            [langChanger readLanguageFileFromDocumentDirectory:NO];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
   
    }
    
    
        [self.delegate selectedLanguageis:selectedlanguage];

}

-(void)successResponseDelegateMethod
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
 [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [languagesArrOfData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    
   // LanguageModel *amodel = languagesArrOfData[indexPath.row];
    //[self changeLanguageWithCode:amodel.code];
}

-(void)changeLanguageWithCode:(NSString*)langCode
{
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *url = [NSString stringWithFormat:@"%@de",LANGUAGE_CHANGE_API];
    [postMan get:url];
    
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