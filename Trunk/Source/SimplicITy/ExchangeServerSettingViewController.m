//
//  ExchangeServerSettingViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 27/03/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "ExchangeServerSettingViewController.h"
#import "LocationViewController.h"

@interface ExchangeServerSettingViewController ()<UITableViewDataSource,UITableViewDelegate,LocationSettingdelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewOutLet;

@end

@implementation ExchangeServerSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Exchange server setup";
}

#pragma  mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        
        UILabel *rightLable = (UILabel*)[cell viewWithTag:100];
        UILabel *leftLable = (UILabel*)[cell viewWithTag:200];

        rightLable.font = [self customFont:16 ofName:MuseoSans_700];
        leftLable.font = [self customFont:16 ofName:MuseoSans_700];
        
        if (indexPath.row == 0)
        {
            rightLable.text = @"Location";
            leftLable.text = @"Select Location";
            
        }else
        {
            rightLable.text = @"Url";
            leftLable.text = @"http://www.ucb.com/";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
        
        UITextField *textFld = (UITextField*)[cell viewWithTag:100];
        
        textFld.font = [self customFont:16 ofName:MuseoSans_700];
        
        if (indexPath.row == 0)
        {
            textFld.placeholder = @"Username";

        }else
        {
            textFld.placeholder = @"password";
            textFld.secureTextEntry = YES;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            [self performSegueWithIdentifier:@"exchangeTolocation_segue" sender:self];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark SettingDelegates

- (void)selectedLocationIs:(NSString *)location
{
    UITableViewCell *cell = [self.tableViewOutLet cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UILabel *leftLable = (UILabel*)[cell viewWithTag:200];
    leftLable.text = location;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UINavigationController *navigation = segue.destinationViewController;
    LocationViewController *locationVC = navigation.viewControllers[0];
    locationVC.delegate = self;
}


@end
