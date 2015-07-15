//
//  FeedbackViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 30/01/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "FeedbackViewController.h"
#import "Postman.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface FeedbackViewController ()<UITextViewDelegate,postmanDelegate>

@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITextView *textViewOutlet;
@property (weak, nonatomic) IBOutlet UIButton *submitBtnOutlet;
@property (weak, nonatomic) IBOutlet UILabel *yourRatingLblOutlet;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLblOutlet;
@property (weak, nonatomic) IBOutlet UILabel *writeReviewLblOutlet;

@end

@implementation FeedbackViewController
{
    NSString *URLString;
    NSString *parameter;
    Postman *postMan;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [super viewDidLoad];
    self.rateView.notSelectedImage = [UIImage imageNamed:@"starEmpty.png"];
   // self.rateView.halfSelectedImage = [UIImage imageNamed:@"kermit_half.png"];
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"starFull.png"];
    self.rateView.rating = 0;
    self.rateView.editable = YES;
    self.rateView.maxRating = 5;
    self.rateView.delegate = self;
    
    self.textViewOutlet.layer.borderWidth = 1;
    self.textViewOutlet.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.submitBtnOutlet.layer.cornerRadius = 5;
    
    self.feedbackLblOutlet.font = [self customFont:16 ofName:MuseoSans_700];
    self.writeReviewLblOutlet.font = [self customFont:16 ofName:MuseoSans_700];
    self.submitBtnOutlet.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];
    
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    
    self.writeReviewLblOutlet.text = @"Nice";

}

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating
{
    self.statusLabel.text = [NSString stringWithFormat:@"%i", (int)rating];
}
- (IBAction)submitBtnAction:(id)sender
{
    URLString = @"http://simplicitytst.ripple-io.in/Rating/Corp123";
//    parameter = @"{\"request\":{\"CorpId\":\"Corp123\",\"Rating\":\"2\",\"Feedback\":\"Good\"}}";
    
    parameter = [NSString stringWithFormat:@"{\"request\":{\"CorpId\":\"Corp123\",\"Rating\":\"%@\",\"Feedback\":\"%@\"}}", self.statusLabel.text, self.writeReviewLblOutlet.text];
    [self tryUpdateAboutDeatils];
}

- (void)tryUpdateAboutDeatils
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [postMan post:URLString withParameters:parameter];
}

#pragma mark
#pragma mark postmanDelegate

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [self parseResponseData:response];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)parseResponseData:(NSData*)data
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSLog(@"json %@",json);
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
