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
#import "UserInfo.h"


@interface ok2updateViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webViewOutlet;
@end

@implementation ok2updateViewController
{
    
    NSDictionary *paramDict;
    
    NSString *targetURLString;
    NSString *targetURL;
    UIBarButtonItem *backButton;
    UIButton *back;
    BOOL showAlready;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    

//    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//    [center addObserver:self selector:@selector(defaultsChanged) name:NSUserDefaultsDidChangeNotification object:nil];
    
    self.webViewOutlet.delegate = self;
    
    back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    
    
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];
    
//    back.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//    back.frame = CGRectMake(0, 0,80, 30);
    
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
//    NSString *plistFilePath = [NSString stringWithString:[[NSBundle mainBundle] pathForResource:@"Parameters" ofType:@"plist"]];
//    paramDict = [[NSDictionary alloc] initWithContentsOfFile:plistFilePath];
    
    //parameters = [NSArray arrayWithArray:[paramDict objectForKey:@"Root"]];
    
    
    NSString *currIosVersion = [[NSString alloc] initWithString:[[UIDevice currentDevice] systemVersion]];;
    NSString *model = [[NSString alloc] initWithString:[[UIDevice currentDevice] model]];
    
    UserInfo *userInfo =[UserInfo sharedUserInfo];
    
    NSString *loc = userInfo.location;
    NSString *baseURL = userInfo.oKToUpdate;
    //the location (region) is set at the app parameter level so iOS updates can be segmented by region or location
//    loc = [[NSString alloc] initWithFormat:@"%@", [paramDict objectForKey:@"app_region"]];
    
    targetURL = [[NSString alloc] initWithFormat:@"%@?l=%@&i=%@&m=%@", baseURL, loc, currIosVersion,model];
    targetURL = [targetURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",targetURL);
    [self refreshBrowser];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];


}




-(void)localize
{
self.title = STRING_FOR_LANGUAGE(@"Device.Upgrade");
    [back setTitle:STRING_FOR_LANGUAGE(@"Home") forState:UIControlStateNormal];
    [back sizeToFit];
}






- (void)backBtnAction
{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)defaultsChanged
{
    [self refreshBrowser];
}

- (void)refreshBrowser
{
    //Verify if targetURL was set by MDM

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
    if (!showAlready)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:ERROR_FOR_ALERT
                                                      message:STRING_FOR_LANGUAGE(@"Contact.Administrator")
                                                     delegate:self
                                            cancelButtonTitle:OK_FOR_ALERT
                                            otherButtonTitles:nil];
        
        [alert show];
        
        showAlready = YES;
    }

    
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
