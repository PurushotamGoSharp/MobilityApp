//
//  MessageDetailViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 03/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "MessageDetailViewController.h"


@interface MessageDetailViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UILabel *subjectLable;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@property (weak, nonatomic) IBOutlet UIWebView *body;

@property (weak, nonatomic) IBOutlet UIView *separator1;
@property (weak, nonatomic) IBOutlet UIView *separator2;

@end

@implementation MessageDetailViewController
{
    UIBarButtonItem *backButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.nameLable.text = self.mesgModel.name;
//    self.subjectLable.text = self.mesgModel.subject;
//    self.bodyTextView.text = self.mesgModel.body;
//    self.timeLable.text = self.mesgModel.time;
    
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];
    
    back.imageEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0);
    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    back.frame = CGRectMake(0, 0,80, 40);
    
    //    back imageEdgeInsets = UIEdgeInsetsMake(<#CGFloat top#>, CGFloat left, <#CGFloat bottom#>, <#CGFloat right#>);
    
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.nameLable.text = self.categoryName;
    
    [self.body loadHTMLString:self.newsContent.newsDetails baseURL:nil ];
    self.subjectLable.text = self.newsContent.subject;
    
    NSDateFormatter *converter = [[NSDateFormatter alloc] init];
    [converter setDateFormat:@"yyyy/MM/dd  hh: mm: ss a"];
    self.timeLable.text = [converter stringFromDate:self.newsContent.recivedDate ];

    
    self.nameLable.font=[self customFont:18 ofName:MuseoSans_700];
    self.bodyTextView.font=[self customFont:14 ofName:MuseoSans_300];
    self.timeLable.font=[self customFont:14 ofName:MuseoSans_300];
    self.subjectLable.font=[self customFont:20 ofName:MuseoSans_300];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *javascript = @"var style = document.createElement(\"style\"); document.head.appendChild(style); style.innerHTML = \"html{-webkit-text-size-adjust: 100%;} body {-webkit-text-size-adjust:100%;}\";var viewPortTag=document.createElement('meta');viewPortTag.id=\"viewport\";viewPortTag.name = \"viewport\";viewPortTag.content = \"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\";document.getElementsByTagName('head')[0].appendChild(viewPortTag);";
    [webView stringByEvaluatingJavaScriptFromString:javascript];

    
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    
    NSLog(@"size: %f, %f", fittingSize.width, fittingSize.height);
    
//    yourScrollView.contentSize = webView.bounds.size;
}

-(void)backBtnAction
{
    //    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popViewControllerAnimated:YES];
    
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
