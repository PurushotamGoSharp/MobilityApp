//
//  TipDetailsViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TipDetailsViewController.h"

@interface TipDetailsViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TipDetailsViewController
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.tipModel.question;
    
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSArray *cachedirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachedirs lastObject];
    NSLog(@"Cache path = %@", cachePath);
    
    CGFloat widthOfWebView = [UIScreen mainScreen].bounds.size.width - 20;
    NSString *sring = [NSString stringWithFormat:@"<div style=\"width: %fpx; word-wrap: break-word\"> %@ </div>",widthOfWebView,self.tipModel.answer];
    [self.webView loadHTMLString:sring baseURL:[NSURL URLWithString:cachePath]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            
            NSLog(@"UIInterfaceOrientationPortrait");
            //load the portrait view
            NSArray *cachedirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachePath = [cachedirs lastObject];

            CGFloat widthOfWebView = [UIScreen mainScreen].bounds.size.width - 20;
            NSString *sring = [NSString stringWithFormat:@"<div style=\"width: %fpx; word-wrap: break-word\"> %@ </div>",widthOfWebView,self.tipModel.answer];
            [self.webView loadHTMLString:sring baseURL:[NSURL URLWithString:cachePath]];
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            //load the landscape view
            NSLog(@"UIInterfaceOrientationLandscapeLeft");
            NSArray *cachedirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachePath = [cachedirs lastObject];
            
            CGFloat widthOfWebView = [UIScreen mainScreen].bounds.size.width - 20;
            NSString *sring = [NSString stringWithFormat:@"<div style=\"width: %fpx; word-wrap: break-word\"> %@ </div>",widthOfWebView,self.tipModel.answer];
            [self.webView loadHTMLString:sring baseURL:[NSURL URLWithString:cachePath]];

        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSString *javascript = @"var style = document.createElement(\"style\"); document.head.appendChild(style); style.innerHTML = \"html{-webkit-text-size-adjust: 100%;} body {-webkit-text-size-adjust:100%;}\";var viewPortTag=document.createElement('meta');viewPortTag.id=\"viewport\";viewPortTag.name = \"viewport\";viewPortTag.content = \"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\";document.getElementsByTagName('head')[0].appendChild(viewPortTag);";
    
    [webView stringByEvaluatingJavaScriptFromString:javascript];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *javascript = @"var style = document.createElement(\"style\"); document.head.appendChild(style); style.innerHTML = \"html{-webkit-text-size-adjust: 100%;} body {-webkit-text-size-adjust:100%;}\";var viewPortTag=document.createElement('meta');viewPortTag.id=\"viewport\";viewPortTag.name = \"viewport\";viewPortTag.content = \"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\";document.getElementsByTagName('head')[0].appendChild(viewPortTag);";
    [webView stringByEvaluatingJavaScriptFromString:javascript];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
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
