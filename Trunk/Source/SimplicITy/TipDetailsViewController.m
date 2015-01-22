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
    
    NSString *sring = [NSString stringWithFormat:@"<div style=\"width: 320px; word-wrap: break-word\"> %@ </div>",self.tipModel.answer];
    [self.webView loadHTMLString:sring baseURL:[NSURL URLWithString:cachePath]];
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
