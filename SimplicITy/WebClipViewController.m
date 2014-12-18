//
//  WebClipViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/4/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "WebClipViewController.h"

@interface WebClipViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *tableViewData;
}

@end

@implementation WebClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tableViewData = @[@"Reset Lync Password",@"Reset SAP Password"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    return [tableViewData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *titlelable = (UILabel *)[cell viewWithTag:200];
    titlelable.text = tableViewData[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://products.office.com/en/lync/"]];
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
