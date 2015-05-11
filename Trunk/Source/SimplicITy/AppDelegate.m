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
//#import <Gimbal/Gimbal.h>
#import "RoomRecognizer.h"

#define ENABLE_PUSH_NOTIFICATION YES

@interface AppDelegate () <UAPushNotificationDelegate, postmanDelegate>

@end

@implementation AppDelegate
{
    Postman *postMan;
    RoomRecognizer *recognizer;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.window makeKeyAndVisible];
    [SendRequestsManager sharedManager];
    
    [UAirship setLogLevel:UALogLevelTrace];
    UAConfig *config = [UAConfig defaultConfig];
    [UAirship takeOff:config];
    UA_LDEBUG(@"Config:\n%@", [config description]);
    
//    [Gimbal setAPIKey:@"47be3299-7a5c-41df-8320-a97519a45ede" options:nil];
//    [GMBLPlaceManager startMonitoring];
    
    recognizer = [RoomRecognizer sharedRecognizer];

    
    // Set the icon badge to zero on startup (optional)
    [UAPush shared].userNotificationTypes = (UIUserNotificationTypeAlert |
                                             UIUserNotificationTypeBadge |
                                             UIUserNotificationTypeSound);
    
    [UAPush shared].userPushNotificationsEnabled = ENABLE_PUSH_NOTIFICATION;
    [UAPush shared].pushNotificationDelegate = self;
    
    [[UITableViewCell appearance] setBackgroundColor:[UIColor clearColor]];
    
    
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor]}
                                             forState:UIControlStateSelected];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSFontAttributeName : [UIFont fontWithName:@"MuseoSans-700" size:20]}];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSFontAttributeName : [UIFont fontWithName:@"MuseoSans-700" size:16]}
                                                forState:(UIControlStateNormal)];
    
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:BACKGROUND_THEME_VALUE])
    {
        case 0:
            [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:.13 green:.31 blue:.46 alpha:1]];
            [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:.13 green:.31 blue:.46 alpha:1]];
            break;
            
        case 1:
            [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:.55 green:.7 blue:.31 alpha:1]];
            [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:.55 green:.7 blue:.31 alpha:1]];
            break;
            
        case 2:
            [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:.9 green:.45 blue:.23 alpha:1]];
            [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:.9 green:.45 blue:.23 alpha:1]];
            break;
            
        case 3:
            [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:.76 green:.06 blue:.29 alpha:1]];
            [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:.76 green:.06 blue:.29 alpha:1]];
            break;
            

        default:
            break;
    }
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:10 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    [self getEWSRequestURL];
    
    NSDictionary *userInfo = [launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (userInfo != nil)
    {
        [self getNotification:userInfo];
    }
    return YES;
}

- (void)getEWSRequestURL
{
    if (postMan == nil)
    {
        postMan = [[Postman alloc] init];
        postMan.delegate = self;
    }
    
    [postMan get:EWS_REQUSET_URL_API];
}

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSString *ewsURL = json[@"aaData"][@"ExchangeServerUrl"];
    
    if (ewsURL)
    {
        [[NSUserDefaults standardUserDefaults] setObject:ewsURL forKey:EWS_REQUSET_URL_KEY];
    }
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    
}

- (void)getNotification:(NSDictionary *)appInfo
{
    NSString *alert = appInfo[@"aps"][@"alert"];
    
     UIAlertView *alertForNotification =  [[UIAlertView alloc] initWithTitle:@"Notification" message:alert delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertForNotification show];

}
- (void)setTabsWithColorIndex:(NSInteger)colorIndex
{
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    UA_LTRACE(@"Application registered for remote notifications with device token: %@", deviceToken);
    
    [[UAPush shared] appRegisteredForRemoteNotificationsWithDeviceToken:deviceToken];
    NSString *deviceTokenString = [UAPush shared].deviceToken;
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString forKey:@"DeviceToken"];
    [[NSUserDefaults standardUserDefaults]synchronize];
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UA_LINFO(@"Received remote notification (in appDelegate): %@", userInfo);
    [[UAPush shared] resetBadge];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    UA_LINFO(@"Received remote notification (in appDelegate): %@", userInfo);
    
    [self gotNotificatonWithUserInfo:userInfo fetchCompletionHandler:completionHandler];
    
    if (application.applicationState != UIApplicationStateBackground) {
        [[UAPush shared] resetBadge];
    }
}

- (void)gotNotificatonWithUserInfo:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if ([userInfo[@"func"] isEqualToString:@"News"])
    {
        NSInteger currentSinceID = [[NSUserDefaults standardUserDefaults]integerForKey:@"SinceID"];
        if (currentSinceID == 0)
        {
            currentSinceID = [userInfo[@"id"] integerValue] - 1;
            
//            //For the very first time (server itself is fresh) 'id' in the push notification will be '1'. So 'sinceId' created will be ZERO. For sinceID = ZERO, server wont give in response. So we have to check for that condition and we need to Call API with 'sinceID= ""'.
//            if (currentSinceID == 0)
//            {
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RecivedVeryFirstNews"];
//            }
        }
        [self getNewsCategoryFor:currentSinceID fetchCompletionHandler:completionHandler];
    }else
    {
        [self getNotification:userInfo];
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)getNewsCategoryFor:(NSInteger)sinceID fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (!self.fetcher)
    {
        self.fetcher = [[NewsCategoryFetcher alloc] init];
    }
    
    [self.fetcher initiateNewsCategoryAPIFor:sinceID fetchCompletionHandler:completionHandler andDownloadImages:YES];
}

@end
