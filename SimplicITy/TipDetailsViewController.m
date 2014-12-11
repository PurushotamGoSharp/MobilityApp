//
//  TipDetailsViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TipDetailsViewController.h"

@interface TipDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIView *viewAtIndex0;
@property (weak, nonatomic) IBOutlet UIView *viewAtIndex1;

@end

@implementation TipDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.parentCategory;
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.index == 0)
    {
        self.viewAtIndex1.hidden = YES;
    }else
    {
        self.viewAtIndex1.hidden = NO;
    }
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
