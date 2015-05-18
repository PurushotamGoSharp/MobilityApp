//
//  ok2updateViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 13/04/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "ok2updateViewController.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>


@interface ok2updateViewController ()<UIWebViewDelegate>

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
    
    self.title = @"Updates";
    self.webViewOutlet.delegate = self;
    
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
    [self refreshBrowser];
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
