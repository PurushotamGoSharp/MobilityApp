//
//  LocationViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 11/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *arrOfLocationData;
    UILabel *titleLable;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arrOfLocationData = @[@"Belgium",@"India",@"US",@"Japan",@"Bulgaria",@"France",@"Germany"];

}
- (IBAction)CalcelBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)doneBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *selectedLocation = arrOfLocationData[[self.tableView indexPathForSelectedRow].row];
    [self.delegate selectedLocationIs:selectedLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrOfLocationData count];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  
    titleLable = (UILabel *)[cell viewWithTag:100];
    titleLable.text = arrOfLocationData[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
#pragma mark UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
