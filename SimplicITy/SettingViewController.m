//
//  SettingViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 10/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
   NSArray *arrOfData, *arrOfLanguageData, *arrOfLocationData;
}
@property (weak, nonatomic) IBOutlet UIPickerView *pickerViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *alphaViewOutlet;
@property (weak, nonatomic) IBOutlet UIButton *changeLangOutlet;
@property (weak, nonatomic) IBOutlet UIButton *changeLocationOutlet;
@property (weak, nonatomic) IBOutlet UIView *containerViewOutlet;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.alphaViewOutlet.hidden= YES;
    self.containerViewOutlet.hidden= YES;
    arrOfLanguageData = @[@"Dutch",@"German",@"English",@"Franch",@"German",@"Spanish",@"Japanese"];
    arrOfLocationData = @[@"Belgium",@"India",@"US",@"Japan",@"Bulgaria",@"France",@"Germany"];
    self.containerViewOutlet.layer.cornerRadius =5;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (IBAction)changeLanguageBtnPressed:(id)sender
{
    arrOfData = arrOfLanguageData;
    [UIView animateWithDuration:.3 animations:^{
        self.alphaViewOutlet.alpha=0.3;
        self.containerViewOutlet.alpha=1;
        
    } completion:^(BOOL finished)
     {
         self.alphaViewOutlet.hidden= NO;
         self.containerViewOutlet.hidden= NO;
         [self.pickerViewOutlet reloadAllComponents];
     }];

}
- (IBAction)changeLocationBtnPressed:(id)sender
{
    arrOfData = arrOfLocationData;
    
    [UIView animateWithDuration:.3 animations:^{
        self.alphaViewOutlet.alpha=0.3;
        self.containerViewOutlet.alpha=1;
        
    } completion:^(BOOL finished)
     {
         self.alphaViewOutlet.hidden= NO;
         self.containerViewOutlet.hidden= NO;
         [self.pickerViewOutlet reloadAllComponents];
     }];

}
- (IBAction)doneBtnPressed:(id)sender
{
 
    [UIView animateWithDuration:.3 animations:^{
        self.alphaViewOutlet.alpha=0;
        self.containerViewOutlet.alpha=0;

    } completion:^(BOOL finished)
    {
        self.alphaViewOutlet.hidden= YES;
        self.containerViewOutlet.hidden= YES;
    }];
}

#pragma mark UIPickerViewDataSource methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrOfData count];
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return arrOfData[row];
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
