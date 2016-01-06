//
//  LyncConnectionCheckerViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/20/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "LyncConnectionCheckerViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "UserInfo.h"
#import "MBProgressHUD.h"


@interface LyncConnectionCheckerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *connectionSpeedLbl;
@property (weak, nonatomic) IBOutlet UILabel *downloadLbl;
@property (weak, nonatomic) IBOutlet UILabel *uploadlbl;
@property (weak, nonatomic) IBOutlet UILabel *connectionResultLbl;
@property (weak, nonatomic) IBOutlet UILabel *AudioLbl;
@property (weak, nonatomic) IBOutlet UILabel *videoLbl;
@property (weak, nonatomic) IBOutlet UILabel *screenShareLbl;
@property (weak, nonatomic) IBOutlet UIImageView *uploadImageView;
@property (weak, nonatomic) IBOutlet UIImageView *downloadImgView;

@property (weak, nonatomic) IBOutlet UIView *audioView;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIView *screenShareView;

@end

@implementation LyncConnectionCheckerViewController
{}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Ping My Lync";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
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
