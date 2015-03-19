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

@interface SplashDelayViewController ()<SeedSyncDelegate>
{
    NSMutableArray *seedDataArrAPI, *seedDataArrDB;
    NSMutableDictionary *seedDataDictFromAPI, *seeddataDictFromDB;
    
    NSString *URLString;
//    DBManager *dbManager;
    SeedSync *seedSyncer;
    NewsCategoryFetcher *categoryFetcher;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultChanged)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];

    [self updateTagsAndAlias];
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
        [self performSegueWithIdentifier:@"SplashToLoginVC_Segue" sender:nil];
    }
}

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
    
    [self performSegueWithIdentifier:@"SplashToLoginVC_Segue" sender:nil];
}

- (void)seedSyncFinishedWithFailure:(SeedSync *)seedSync
{
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

@end
