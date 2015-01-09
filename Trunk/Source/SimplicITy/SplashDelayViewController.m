//
//  SplashDelayViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 08/01/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "SplashDelayViewController.h"
#import "Postman.h"
#import "SeedModel.h"
#import <sqlite3.h>
#import "DBManager.h"

@interface SplashDelayViewController ()<postmanDelegate,DBManagerDelegate>
{
    NSMutableArray *seedDataArrAPI, *seedDataArrDB;
    NSMutableDictionary *seedDataDictFromAPI, *seeddataDictFromDB;
    
    NSString *URLString;
    NSString *databasePath;
    sqlite3 *database;
    DBManager *dbManager;
}

@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageOutlet;

@end

@implementation SplashDelayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.backGroundImageOutlet.image = @"LyncImage";
    
    self.backGroundImageOutlet.image = [UIImage imageNamed:@"LaunchImage"];
    
    URLString = @"http://simplicitytst.ripple-io.in/Seed";
    
    
//    if ([AFNetworkReachabilityManager sharedManager].isReachable)
//    {
//            [self tryToUpdateSeedData];
//        NSLog(@"Rechable");
//    }
//    else
//    {
//        NSLog(@"Not rechable");
//
//        [self getData];
//    }

    [self tryToUpdateSeedData];
    
    
//    [self performSegueWithIdentifier:@"SplashToLoginVC_Segue" sender:nil];


}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;

}


-(void)tryToUpdateSeedData
{
    URLString = @"http://simplicitytst.ripple-io.in/Seed";
    
    Postman *postMan = [[Postman alloc] init];
    postMan.delegate = self;
    [postMan get:URLString];
}

#pragma mark
#pragma mark postmanDelegate
-(void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [self parseSeedata:response];
    [self saveSeeddata:response forUrl:urlString];
    
    [self performSegueWithIdentifier:@"SplashToLoginVC_Segue" sender:nil];

}

-(void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    
}

-(void)parseSeedata:(NSData *)response
{
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    
    NSArray *arr= json[@"aaData"][@"seedmaster"];
    
    seedDataArrAPI = [[NSMutableArray alloc] init];
    seedDataDictFromAPI = [[NSMutableDictionary alloc] init];
    for (NSDictionary *aDict in arr)
    {
        SeedModel *seed = [[SeedModel alloc] init];
        seed.name = aDict[@"Name"];
        seed.upDateCount = [aDict[@"Value"] intValue];
        [seedDataArrAPI addObject:seed];
        
        NSNumber *value = [NSNumber numberWithInteger:seed.upDateCount];
        
        
        [seedDataDictFromAPI setObject:value  forKey:seed.name];
        
    }
    NSLog( @"Seed data from API's are %@ ",seedDataDictFromAPI);
    
    [self getData];
    
}

-(void)saveSeeddata:(NSData *)response forUrl:(NSString *)APILink
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *createQuery = @"create table if not exists seed (name text PRIMARY KEY, upDateCount integer)";
    [dbManager createTableForQuery:createQuery];
    
    NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSRange rangeofString;
    rangeofString.location = 0;
    rangeofString.length = stringFromData.length;
    [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
    
    for (SeedModel *aSeed in seedDataArrAPI) {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  seed (name,upDateCount) values ('%@', '%i')", aSeed.name,aSeed.upDateCount];
        
        [dbManager saveDataToDBForQuery:insertSQL];
    }
    

}

- (void)getData
{
    
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
//    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM seed WHERE API = '%@'", URLString];
    
    NSString *queryString = @"SELECT * FROM seed";
    if (![dbManager getDataForQuery:queryString])
    {
        
    }
    
    NSArray *arrkeys = [seedDataDictFromAPI allKeys];
    
    for (NSString *newkey in arrkeys)
    {
        if ([seedDataDictFromAPI[newkey] integerValue] > [seeddataDictFromDB[newkey] integerValue])
        {
            NSLog(@"Set Flags for %@" , newkey);
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:newkey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

-(void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    seedDataArrDB = [[NSMutableArray alloc] init ];
    seeddataDictFromDB = [[NSMutableDictionary alloc] init];
    
    while (sqlite3_step(statment) == SQLITE_ROW)
    {
        SeedModel *anSeed = [[SeedModel alloc] init];
        anSeed.name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 0)];
        anSeed.upDateCount = sqlite3_column_int(statment, 1);
        [seedDataArrDB addObject:anSeed];
        
        NSNumber *value = [NSNumber numberWithInt:anSeed.upDateCount];
        
        [seeddataDictFromDB setObject:value forKey:anSeed.name];
    }
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
