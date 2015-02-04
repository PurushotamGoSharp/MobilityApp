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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.backGroundImageOutlet.image = @"LyncImage";
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].bounds.size.height == 568)
        {
            self.backGroundImageOutlet.image = [UIImage imageNamed:@"LaunchImage-568h@2x.png"];
        }else if ([UIScreen mainScreen].bounds.size.height == 667)
        {
            self.backGroundImageOutlet.image = [UIImage imageNamed:@"LaunchImage-800-667h@2x.png"];
            
        }else
        {
            self.backGroundImageOutlet.image = [UIImage imageNamed:@"LaunchImage"];
        }
    }else
    {
        self.backGroundImageOutlet.image = [UIImage imageNamed:@"LanchImage_ipad_Portrate.png"];

    }
    URLString = SEED_API;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            
        }else
        {
            self.backGroundImageOutlet.image = [UIImage imageNamed:@"LanchImage_ipad_Landscape.png"];
            
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)orientationChanged:(NSNotification *)notification{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(checkRechability) withObject:nil afterDelay:1];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            //load the portrait view
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            //load the landscape view
            
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                
            }else
            {
                self.backGroundImageOutlet.image = [UIImage imageNamed:@"LanchImage_ipad_Landscape.png"];

            }
            
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
    
}

- (void)checkRechability
{
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        [self tryToUpdateSeedData];
        NSLog(@"Rechable");
    }
    else
    {
        NSLog(@"Not rechable");
        [self performSegueWithIdentifier:@"SplashToLoginVC_Segue" sender:nil];

//        UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [noNetworkAlert show];
    }
}
- (void)tryToUpdateSeedData
{
    URLString = SEED_API;
    
    Postman *postMan = [[Postman alloc] init];
    postMan.delegate = self;
    [postMan get:URLString];
}

#pragma mark
#pragma mark postmanDelegate
- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [self parseSeedata:response];
    [self saveSeeddata:response forUrl:urlString];
    
    [self performSegueWithIdentifier:@"SplashToLoginVC_Segue" sender:nil];

}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [self performSegueWithIdentifier:@"SplashToLoginVC_Segue" sender:nil];
}

- (void)parseSeedata:(NSData *)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    
    NSArray *arr= json[@"aaData"][@"seedmaster"];
    
    seedDataArrAPI = [[NSMutableArray alloc] init];
    seedDataDictFromAPI = [[NSMutableDictionary alloc] init];
    for (NSDictionary *aDict in arr)
    {
        SeedModel *seed = [[SeedModel alloc] init];
        seed.name = aDict[@"Name"];
        seed.type = aDict[@"Type"];
        seed.upDateCount = [aDict[@"Value"] intValue];
        [seedDataArrAPI addObject:seed];
        
        NSNumber *value = [NSNumber numberWithInteger:seed.upDateCount];
        
        
        [seedDataDictFromAPI setObject:value  forKey:seed.name];
        
    }
    
    NSLog( @"Seed data from API's are %@ ",seedDataDictFromAPI);
    
    [self getData];
}

- (void)saveSeeddata:(NSData *)response forUrl:(NSString *)APILink
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
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noNetworkAlert show];
        }
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

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITabBarController *tabBarController = segue.destinationViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:BACKGROUND_THEME_VALUE];
    [self setTabImageForColorIndex:index onTabBar:tabBar];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [self colorForIndex:index],NSFontAttributeName : [UIFont fontWithName:@"MuseoSans-300" size:12]} forState:(UIControlStateNormal)];
}

- (void)setTabImageForColorIndex:(NSInteger)colorIndex onTabBar:(UITabBar *)tabBar;
{
    NSInteger imageIndex = colorIndex+1; //Image name say Commercial-01.png, staring index is 1.
    
    NSString *imageName0 = [NSString stringWithFormat:@"Dwelling-0%li.png", (long)imageIndex];
    NSString *imageName1 = [NSString stringWithFormat:@"Message-0%li.png", (long)imageIndex];
    NSString *imageName2 = [NSString stringWithFormat:@"TipsIcon-0%li.png", (long)imageIndex];
    NSString *imageName3 = [NSString stringWithFormat:@"Spanner-0%li.png", (long)imageIndex];
    NSString *imageName4 = [NSString stringWithFormat:@"Commercial-0%li.png", (long)imageIndex];
    
    
    
    UITabBarItem *tabBarItem = tabBar.items[0];
    tabBarItem.image = [[UIImage imageNamed:imageName0] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem = tabBar.items[1];
    tabBarItem.image = [[UIImage imageNamed:imageName1] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem = tabBar.items[2];
    tabBarItem.image = [[UIImage imageNamed:imageName2] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem = tabBar.items[3];
    tabBarItem.image = [[UIImage imageNamed:imageName3] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem = tabBar.items[4];
    tabBarItem.image = [[UIImage imageNamed:imageName4] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIColor *)colorForIndex:(NSInteger)colorIndex
{
    switch (colorIndex)
    {
        case 0:
            return [UIColor colorWithRed:.1 green:.16 blue:.2 alpha:1];
            break;
            
        case 1:
            return [UIColor colorWithRed:.4 green:.11 blue:.2 alpha:1];
            break;
            
        case 2:
            return [UIColor colorWithRed:.15 green:.18 blue:.09 alpha:1];
            break;
            
        case 3:
            return [UIColor colorWithRed:.35 green:.2 blue:.13 alpha:1];
            break;
            
        default:
            break;
    }
    
    return nil;
}



@end
