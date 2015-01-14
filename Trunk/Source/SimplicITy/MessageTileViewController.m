//
//  MessageTileViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 09/01/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "MessageTileViewController.h"
#import "MessagesViewController.h"

@interface MessageTileViewController ()
{
    NSArray *arrOfData;
     UIBarButtonItem *backButton;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewoutlet;

@end

@implementation MessageTileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrOfData= @[@" Mobility",@"Service Desk",@"Human Resources",@"Local Site Services",@"Other"];
    
    
//    [self.tableViewoutlet setContentInset:UIEdgeInsetsMake(-40, 0, 0, 0)];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    [back setTitle:@"Home" forState:UIControlStateNormal];
    
    back.imageEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0);
    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    back.frame = CGRectMake(0, 0,80, 40);
    
    //    back imageEdgeInsets = UIEdgeInsetsMake(<#CGFloat top#>, CGFloat left, <#CGFloat bottom#>, <#CGFloat right#>);
    
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
}

-(void)backBtnAction
{
    [self.tabBarController setSelectedIndex:0];
    
}

- (IBAction)btnAction:(id)sender
{
    [self performSegueWithIdentifier:@"messagesList_segue" sender:self];
}


//#pragma mark UITableViewDataSource
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [arrOfData count];
//    
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 75;
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
//    titleLable.layer.cornerRadius= 5;
//    titleLable.layer.masksToBounds = YES;
//    titleLable.text = arrOfData[indexPath.row];
//    titleLable.font=[self customFont:18 ofName:MuseoSans_700];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    return cell;
//}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
//    titleLable.backgroundColor = [UIColor redColor];
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    
//    MessagesViewController *messagesVC = (MessagesViewController *) segue.destinationViewController;
//    
//    messagesVC.navBarTitleName = arrOfData[[self.tableViewoutlet indexPathForSelectedRow].row];
//    
//    
//}


@end
