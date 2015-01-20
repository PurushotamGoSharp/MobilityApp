//
//  TipDetailsViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TipDetailsViewController.h"

@interface TipDetailsViewController ()

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

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    [self.webView loadHTMLString:self.tipModel.answer baseURL:nil];
    NSLog(@"Html %@",self.tipModel.answer);
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
