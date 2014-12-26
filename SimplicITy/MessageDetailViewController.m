//
//  MessageDetailViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 03/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "MessageDetailViewController.h"


@interface MessageDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UILabel *subjectLable;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;

@property (weak, nonatomic) IBOutlet UIView *separator1;
@property (weak, nonatomic) IBOutlet UIView *separator2;

@end

@implementation MessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLable.text = self.mesgModel.name;
    self.subjectLable.text = self.mesgModel.subject;
    self.bodyTextView.text = self.mesgModel.body;
    self.timeLable.text = self.mesgModel.time;
    

    
    self.nameLable.font=[self customFont:18 ofName:MuseoSans_700];
    self.bodyTextView.font=[self customFont:14 ofName:MuseoSans_300];
    self.timeLable.font=[self customFont:14 ofName:MuseoSans_300];
    self.subjectLable.font=[self customFont:20 ofName:MuseoSans_300];

}

//-(void)viewWillAppear:(BOOL)animated
//{
//
//}



//#pragma mark UITableViewDataSource methods
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 3;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    if (indexPath.row == 0)
//    {
//        return 44;
//    }else if (indexPath.row == 1)
//    {
//        return 44;
//    }
//    else
//    {
//        return 44;
//    }
//        
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    
//    
//    return cell;
//}

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
