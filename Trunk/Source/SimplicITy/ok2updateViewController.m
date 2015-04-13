//
//  ok2updateViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 13/04/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "ok2updateViewController.h"
#import "AppDelegate.h"


@interface ok2updateViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webViewOutlet;
@end

@implementation ok2updateViewController
{
    NSDictionary *paramDict;
    
    NSString *targetURLString;
    NSString *targetURL;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(defaultsChanged) name:NSUserDefaultsDidChangeNotification object:nil];
    
    
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    appDelegate.inboxSampleViewController = self;
//    
//    self.version.text = [NSString stringWithFormat:@"UAInbox Version: %@", [UAirshipVersion get]];
//    
//    self.navigationItem.rightBarButtonItem
//    = [[UIBarButtonItem alloc] initWithTitle:@"Inbox" style:UIBarButtonItemStylePlain target:self action:@selector(mail:)];
//    
//    // For UINavigationController UI
//    [UAInboxNavUI shared].popoverButton = self.navigationItem.rightBarButtonItem;
    
    NSString *plistFilePath = [NSString stringWithString:[[NSBundle mainBundle] pathForResource:@"Parameters" ofType:@"plist"]];
    paramDict = [[NSDictionary alloc] initWithContentsOfFile:plistFilePath];
    
    //parameters = [NSArray arrayWithArray:[paramDict objectForKey:@"Root"]];
    
    
    NSString *currIosVersion = [[NSString alloc] initWithString:[[UIDevice currentDevice] systemVersion]];;
    NSString *model = [[NSString alloc] initWithString:[[UIDevice currentDevice] model]];
    
    
    
    NSString *loc;
    //the location (region) is set at the app parameter level so iOS updates can be segmented by region or location
    loc = [[NSString alloc] initWithFormat:@"%@", [paramDict objectForKey:@"app_region"]];
    
    targetURL = [[NSString alloc] initWithFormat:@"%@?l=%@&i=%@&m=%@", [paramDict objectForKey:@"ios_check_url"], loc, currIosVersion,model];
    NSLog(@"%@",targetURL);
}

- (void)defaultsChanged {
    [self refreshBrowser];
}

- (void)refreshBrowser {
    //Verify if targetURL was set by MDM
    static NSString * const kConfigurationKey = @"com.apple.configuration.managed";
    NSDictionary *serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfigurationKey];
    static NSString * const kConfigurationTargetURLKey = @"targetURL";
    targetURLString = serverConfig[kConfigurationTargetURLKey];
    NSLog(@"%@",targetURLString);
    if ([targetURLString length] > 0) {
        targetURL = [[NSString alloc] initWithFormat:@"%@", targetURLString];
        NSLog(@"%@",targetURL);
    }
    NSURL *url = [NSURL URLWithString:targetURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [self.webViewOutlet loadRequest:requestObj];
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
