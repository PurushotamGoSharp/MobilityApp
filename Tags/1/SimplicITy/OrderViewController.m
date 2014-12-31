//
//  OrderViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 04/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "OrderViewController.h"

@interface OrderViewController ()
{
    NSArray *arrOfPickerViewData;

    __weak IBOutlet UILabel *requester;

    __weak IBOutlet UILabel *requesterName;

    __weak IBOutlet UILabel *impactofOrede;

    __weak IBOutlet UILabel *low;
    __weak IBOutlet UILabel *medium;

    __weak IBOutlet UILabel *high;

    __weak IBOutlet UILabel *critical;
}

@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   arrOfPickerViewData = @[@"Wireless mouse",@"Headphone",@"Laptop Charger",@"iOS device"];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIPickerViewDataSource methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrOfPickerViewData count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return arrOfPickerViewData[row];
}
- (IBAction)imapctValueChanged:(UISlider *)sender
{
    sender.value = roundf(sender.value);
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
