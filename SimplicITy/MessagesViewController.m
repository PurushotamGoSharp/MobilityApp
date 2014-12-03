//
//  MessagesViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 03/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "MessagesViewController.h"

@interface MessagesViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *arrOfTableData;
}

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrOfTableData = @[@"Message 1",@"Message 2",@"Message 3",@"Message 4",@"Message 5",@"Message 6",@"Message 7",@"Message 8",@"Message 9"];
}



#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrOfTableData count];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
    titleLable.text = arrOfTableData[indexPath.row];
    return cell;
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
