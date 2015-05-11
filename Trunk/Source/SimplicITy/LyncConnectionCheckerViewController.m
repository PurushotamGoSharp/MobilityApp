//
//  LyncConnectionCheckerViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/20/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "LyncConnectionCheckerViewController.h"

@interface LyncConnectionCheckerViewController ()

@end

@implementation LyncConnectionCheckerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Lync Connection Checker";
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController popViewControllerAnimated:YES];
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
