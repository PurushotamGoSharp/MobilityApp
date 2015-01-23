//
//  AppDelegate.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/3/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "AppDelegate.h"
#import "UAirship.h"
#import "UAConfig.h"
#import "UAPush.h"
#import "SendRequestsManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [self.window makeKeyAndVisible];
    [SendRequestsManager sharedManager];
    
    [UAirship setLogLevel:UALogLevelTrace];
    
    // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
    // or set runtime properties here.
    UAConfig *config = [UAConfig defaultConfig];
    [UAirship takeOff:config];
    
    // Print out the application configuration for debugging (optional)
    UA_LDEBUG(@"Config:\n%@", [config description]);
    
    // Set the icon badge to zero on startup (optional)
    [[UAPush shared] resetBadge];
    
    [UAPush shared].userNotificationTypes = (UIUserNotificationTypeAlert |
                                             UIUserNotificationTypeBadge |
                                             UIUserNotificationTypeSound);
    
     [UAPush shared].userPushNotificationsEnabled = YES;

    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor]}
                                             forState:UIControlStateSelected];
    

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSFontAttributeName : [UIFont fontWithName:@"MuseoSans-700" size:20]}];
    
    
    
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"BackgroundTheme"])
    {
        case 0:
            [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:.13 green:.31 blue:.46 alpha:1]];
            [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:.13 green:.31 blue:.46 alpha:1]];
            
            
//            [[UITabBar appearance] setSelectedImageTintColor:[UIColor greenColor]];
            
            [UITabBar appearance];

            break;
            
        case 1:
            [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:.9 green:.45 blue:.23 alpha:1]];
            [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:.9 green:.45 blue:.23 alpha:1]];
            break;
            
        case 2:
            [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:.76 green:.06 blue:.29 alpha:1]];
            [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:.76 green:.06 blue:.29 alpha:1]];
            break;
            
        case 3:
            [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:.55 green:.7 blue:.31 alpha:1]];
            [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:.55 green:.7 blue:.31 alpha:1]];
            break;
        default:
            break;
    }
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:10 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    return YES;
}

- (void)setTabsWithColorIndex:(NSInteger)colorIndex
{
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    UA_LTRACE(@"Application registered for remote notifications with device token: %@", deviceToken);
    [[UAPush shared] appRegisteredForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    UA_LINFO(@"Received remote notification (in appDelegate): %@", userInfo);
    
    // Optionally provide a delegate that will be used to handle notifications received while the app is running
    // [UAPush shared].pushNotificationDelegate = your custom push delegate class conforming to the UAPushNotificationDelegate protocol
    
    // Reset the badge after a push received (optional)
    [[UAPush shared] resetBadge];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    UA_LINFO(@"Received remote notification (in appDelegate): %@", userInfo);
    
    // Optionally provide a delegate that will be used to handle notifications received while the app is running
    // [UAPush shared].pushNotificationDelegate = your custom push delegate class conforming to the UAPushNotificationDelegate protocol
    
    // Reset the badge after a push is received in a active or inactive state
    if (application.applicationState != UIApplicationStateBackground) {
        [[UAPush shared] resetBadge];
    }
    
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)failIfSimulator {
    if ([[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location != NSNotFound) {
        UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                            message:@"You will not be able to receive push notifications in the simulator."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        // Let the UI finish launching first so it doesn't complain about the lack of a root view controller
        // Delay execution of the block for 1/2 second.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [someError show];
        });
        
    }
}


@end
