//
//  FileLoadViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 2/6/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "FileLoadViewController.h"

@interface FileLoadViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation FileLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *encodedString=[self.pathOfFile stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"Encoded string %@",encodedString);
    
    NSURL *url = [NSURL URLWithString:encodedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error %@", error);
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
