//
//  ToolsViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/4/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "ToolsViewController.h"

@interface ToolsViewController ()
{
    NSArray *arrayOfImages, *arrayOfDatas;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ToolsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrayOfDatas = @[ @"Lync Connection Checker", @"Web Clips", @"Password Expiration Date", @"Survey"];
        
    arrayOfImages = @[[UIImage imageNamed:@"LyncToolsIcon"], [UIImage imageNamed:@"WebClipToolImage"], [UIImage imageNamed:@"PasswordResetToolImage"], [UIImage imageNamed:@"SurveyToolIcon"]];
    
    self.title = @"Tools";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([self.tableView indexPathForSelectedRow].row == 3)
//    {
//        UIViewController *cont =
//    }
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayOfDatas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    label.text = arrayOfDatas[indexPath.row];
    
    UIImageView *imageCVIew = (UIImageView *)[cell viewWithTag:101];
    imageCVIew.image = arrayOfImages[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"ToolToLyncTestSegue" sender:nil];
    }else if (indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"toolsToWebClipVCSegue" sender:nil];
    }else if (indexPath.row == 3)
    {
        [self performSegueWithIdentifier:@"toolsToSurveySegue" sender:nil];
    }else if (indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"ToolsADExpSegue" sender:nil];
    }



}

@end
