//
//  FeedbackViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 30/01/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITextView *textViewOutlet;
@property (weak, nonatomic) IBOutlet UIButton *submitBtnOutlet;
@property (weak, nonatomic) IBOutlet UILabel *yourRatingLblOutlet;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLblOutlet;
@property (weak, nonatomic) IBOutlet UILabel *writeReviewLblOutlet;

@end

@implementation FeedbackViewController

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
    
    self.yourRatingLblOutlet.font = [self customFont:18 ofName:MuseoSans_300];
    self.statusLabel.font = [self customFont:18 ofName:MuseoSans_300];
    self.feedbackLblOutlet.font = [self customFont:18 ofName:MuseoSans_300];
    self.writeReviewLblOutlet.font = [self customFont:18 ofName:MuseoSans_300];
    self.submitBtnOutlet.titleLabel.font = [self customFont:18 ofName:MuseoSans_300];

}

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating
{
    self.statusLabel.text = [NSString stringWithFormat:@"%f", rating];
}
- (IBAction)submitBtnAction:(id)sender {
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
