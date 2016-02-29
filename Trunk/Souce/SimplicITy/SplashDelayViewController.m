//
//  SplashDelayViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 08/01/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "SplashDelayViewController.h"
#import "SeedSync.h"
#import "NewsCategoryFetcher.h"
#import "UAPush.h"
#import "UserInfo.h"
#import "ADExpirationDateFetcher.h"
#import "Postman.h"
#import "LanguageChangerClass.h"
#import <MCLocalization/MCLocalization.h>


@interface SplashDelayViewController ()<SeedSyncDelegate,postmanDelegate,languageChangeProtocol>
{
    NSMutableArray *seedDataArrAPI, *seedDataArrDB;
    NSMutableDictionary *seedDataDictFromAPI, *seeddataDictFromDB;
    
    NSString *URLString;
//    DBManager *dbManager;
    SeedSync *seedSyncer;
    NewsCategoryFetcher *categoryFetcher;
    LanguageChangerClass *langChanger;

}

@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageOutlet;

@end

@implementation SplashDelayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (langChanger == nil) {
        langChanger =[[LanguageChangerClass alloc]init];
    }
    langChanger.delegate = self;
   
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].bounds.size.height == 568)
        {
            self.backGroundImageOutlet.image = [UIImage imageNamed:@"LaunchImage-568h@2x.png"];
        }
        
        else if ([UIScreen mainScreen].bounds.size.height == 667)
        {
            self.backGroundImageOutlet.image = [UIImage imageNamed:@"LaunchImage-800-667h@2x.png"];
        }else if ([UIScreen mainScreen].bounds.size.height == 736)
        {
            self.backGroundImageOutlet.image = [UIImage imageNamed:@"Splash-Screen-1536.png"];
        }else
        {
            self.backGroundImageOutlet.image = [UIImage imageNamed:@"LaunchImage"];
        }
    }else
    {
        self.backGroundImageOutlet.image = [UIImage imageNamed:@"LanchImage_ipad_Portrate.png"];
    }
    
    URLString = SEED_API;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultChanged)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    [self updateTagsAndAlias];
    ADExpirationDateFetcher *dateFetcher = [[ADExpirationDateFetcher alloc] init];
    [dateFetcher getExpirationDateWithSuccess:^(NSInteger noOfDayLeft)
     {
    }];
    
    BOOL updatedSyncID = [[NSUserDefaults standardUserDefaults] boolForKey:@"updatedSyncID"];
    if (!updatedSyncID)
    {
        if (categoryFetcher == nil)
        {
            categoryFetcher = [[NewsCategoryFetcher alloc] init];
        }
        
        [categoryFetcher getLatestNewsIDWithCompletionner:^(BOOL success, NSInteger latestID) {
            if (success)
            {
                NSInteger currentID = [[NSUserDefaults standardUserDefaults] integerForKey:@"SinceID"];
                if (currentID == 0)
                {
                    [[NSUserDefaults standardUserDefaults] setInteger:latestID forKey:@"SinceID"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"updatedSyncID"];
            }
        }];
    }

}

//-(void)localize
//{
//        UITabBar *tabBar = self.tabBarController.tabBar;
//        UITabBarItem *tabBarItem = tabBar.items[0];
//        tabBarItem.title = STRING_FOR_LANGUAGE(@"Home");
//        tabBarItem = tabBar.items[1];
//        tabBarItem.title = STRING_FOR_LANGUAGE(@"Setting.Setting");
//        tabBarItem = tabBar.items[2];
//        tabBarItem.title = STRING_FOR_LANGUAGE(@"Tools");
//        tabBarItem = tabBar.items[3];
//        tabBarItem.title = STRING_FOR_LANGUAGE(@"About");
//}


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

- (void)orientationChanged:(NSNotification *)notification
{
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
        if (seedSyncer == nil)
        {
            seedSyncer = [[SeedSync alloc] init];
            seedSyncer.delegate = self;
        }
        
        [seedSyncer initiateSeedAPI];
        NSLog(@"Rechable");
    }
    else
    {
        NSLog(@"Not rechable");
        [langChanger readLanguageFileFromDocumentDirectory:NO];
        [self performSegueWithIdentifier:@"SplashToLoginVC_Segue" sender:nil];
    }
}


//-(void)parseResponse:(NSData*)response
//{
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
//    
//    NSArray *arr = json[@"aaData"][@"UILabels"];
//    
//    NSMutableDictionary *aaData = [[NSMutableDictionary alloc] init];
//
//    for (NSDictionary *adict in arr)
//    {
//        NSString *key = adict[@"UserFriendlyCode"];
//        NSString *value = adict[@"Name"];
//        
//        NSMutableDictionary  *adictnory = [NSMutableDictionary dictionaryWithObject:value forKey:key];
//        [aaData addEntriesFromDictionary:adictnory];
//    }
//    
//    NSLog(@"english language %@",aaData);
//    
//    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"en.json"];
//    NSLog(@"file Path = %@",filePath);
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aaData options:0 error:&error];
//    [jsonData writeToFile:filePath atomically:YES];
//}


//- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
//{
//    [self parseResponse:response];
//}
//
//-(void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
//{
//    
//}
//
#pragma mark
#pragma mark SeedSyncDelegate
- (void)seedSyncFinishedSuccessful:(SeedSync *)seedSync
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"news"])
    {
        NSInteger sinceID = [[NSUserDefaults standardUserDefaults]integerForKey:@"SinceID"];
//        sinceID = 1;
        if (sinceID > 0)
        {
            categoryFetcher = [[NewsCategoryFetcher alloc] init];
            [categoryFetcher initiateNewsCategoryAPIFor:sinceID
                                 fetchCompletionHandler:nil
                                      andDownloadImages:YES];
        }
    }
    
   
    
    
    NSString *langCode =  [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLanguageCode"];
//    if (langCode == nil)
//    {
//        langCode = @"en";
//    }
    NSString *seedKeyForLang = [NSString stringWithFormat:@"uilabel,%@", langCode];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:seedKeyForLang])
    {
        [langChanger changeLanguageWithCode:langCode];
    }else
    {
        [langChanger readLanguageFileFromDocumentDirectory:NO];
        [self performSegueWithIdentifier:@"SplashToLoginVC_Segue" sender:nil];
    }



}

-(void)successResponseDelegateMethod
{

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    
    //[self loadlanguage];
   
    //[langChanger readLanguageFileFromDocumentDirectory];

    
    [self performSegueWithIdentifier:@"SplashToLoginVC_Segue" sender:nil];

}


-(void)loadlanguage
{
    NSString *langCode =  [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLanguageCode"];
    NSFileManager *fmngr = [[NSFileManager alloc] init];
     self.languageUrlPairs = [[NSMutableDictionary alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // grab all the files in the documents dir
    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent:@"Languages"];
    
    NSArray *allFiles = [fmngr contentsOfDirectoryAtPath:destinationPath error:nil];
    // filter the array for only json files
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *jsonFiles = [allFiles filteredArrayUsingPredicate:fltr];
    NSString *names = nil;
    // use fast enumeration to iterate the array and delete the files
    for (NSString *aJsonFile in jsonFiles)
    {
        NSString *fileNm = [destinationPath stringByAppendingPathComponent:aJsonFile];
        names = [aJsonFile stringByDeletingPathExtension];
        NSURL *filePathUrl = [NSURL fileURLWithPath:fileNm];
        [self.languageUrlPairs setObject:filePathUrl forKey:names];
    }
    
    NSLog(@"Dict %@",[self.languageUrlPairs allKeys]);

    [MCLocalization loadFromLanguageURLPairs:self.languageUrlPairs defaultLanguage:@"en"];
    [MCLocalization sharedInstance].noKeyPlaceholder = @"[No '{key}' in '{language}']";
    [MCLocalization sharedInstance].language = langCode;
}



-(void)failourResponseDelegateMethod
{

}

- (void)seedSyncFinishedWithFailure:(SeedSync *)seedSync
{
    [langChanger readLanguageFileFromDocumentDirectory:NO];
    [self performSegueWithIdentifier:@"SplashToLoginVC_Segue" sender:nil];
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
    NSString *imageName2 = [NSString stringWithFormat:@"Spanner-0%li.png", (long)imageIndex];
    NSString *imageName3 = [NSString stringWithFormat:@"Commercial-0%li.png", (long)imageIndex];

    
    UITabBarItem *tabBarItem = tabBar.items[0];
    tabBarItem.image = [[UIImage imageNamed:imageName0] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem = tabBar.items[1];
    tabBarItem.image = [[UIImage imageNamed:imageName1] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    tabBarItem = tabBar.items[2];
    tabBarItem.image = [[UIImage imageNamed:imageName2] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem = tabBar.items[3];
    tabBarItem.image = [[UIImage imageNamed:imageName3] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

//-(void )localize:(UITabBar*)tabBar
//{
//    UITabBarItem *tabbarItem = tabBar.items[0];
//    tabbarItem.title = [MCLocalization stringForKey:@"Home"];
//    
//    tabbarItem = tabBar.items[1];
//    tabbarItem.title = [MCLocalization stringForKey:@"Settings"];
//    
//    tabbarItem = tabBar.items[2];
//    tabbarItem.title = [MCLocalization stringForKey:@"Tools"];
//    
//    tabbarItem = tabBar.items[3];
//    tabbarItem.title = [MCLocalization stringForKey:@"Upgrade"];
//    
//    tabbarItem = tabBar.items[4];
//    tabbarItem.title = [MCLocalization stringForKey:@"About"];
//}

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

- (void)userDefaultChanged
{
    [self performSelector:@selector(updateTagsAndAlias) withObject:nil afterDelay:1];
}

- (void)updateTagsAndAlias
{
//When ever we update tags and alias nsuerdefault was also updating. so it was forming 
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUserDefaultsDidChangeNotification
                                                  object:nil];

    [UAPush shared].tags = [UserInfo sharedUserInfo].tags;
    [UAPush shared].alias = [UserInfo sharedUserInfo].alias;
    [[UAPush shared] updateRegistration];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultChanged)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
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
