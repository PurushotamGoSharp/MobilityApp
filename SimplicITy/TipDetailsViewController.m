//
//  TipDetailsViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TipDetailsViewController.h"

@interface TipDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIView *viewAtIndex0;
@property (weak, nonatomic) IBOutlet UIView *viewAtIndex1;

@property (weak, nonatomic) IBOutlet UITextView *textView1;
@property (weak, nonatomic) IBOutlet UITextView *textView2;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *shadowView;


@property (weak, nonatomic) IBOutlet UITextView *text1;
//@property (weak, nonatomic) IBOutlet UIImageView *videoImage;

@property (weak, nonatomic) IBOutlet UIView *scrollContainerView;
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;

@end

@implementation TipDetailsViewController
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.parentCategory;



    self.text1.font=[self customFont:14 ofName:MuseoSans_300];
    self.textView2.font=[self customFont:20 ofName:MuseoSans_700];

    


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    self.text1.text = self.textToDisplay;
    
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.fileName ofType:@"mp4"];
    NSURL *videoURL = [NSURL fileURLWithPath:filePath];
    NSLog(@"File path = %@", filePath);
    self.videoController = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    self.videoController.movieSourceType = MPMovieSourceTypeFile;
    [self.videoController.view setFrame:CGRectMake(0,0, 300, 133)];
    
    
    self.videoController.controlStyle = MPMovieControlStyleEmbedded;
    self.videoController.fullscreen = NO;
    [self.videoContainerView addSubview:self.videoController.view];
    [self.scrollContainerView bringSubviewToFront:self.playButton];
    
    
//    if (self.index == 0)
//    {
//        self.textView2.text = self.textToDisplay;
//        self.viewAtIndex0.hidden = YES;
//        self.viewAtIndex1.hidden = NO;
//        
//        if (self.fileName)
//        {
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:self.fileName ofType:@"mp4"];
//            NSURL *videoURL = [NSURL fileURLWithPath:filePath];
//            NSLog(@"File path = %@", filePath);
//            self.videoController = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
//            self.videoController.movieSourceType = MPMovieSourceTypeFile;
//            [self.videoController.view setFrame:CGRectMake(28,75, 320, 170)];
//            self.videoController.controlStyle = MPMovieControlStyleEmbedded;
//            self.videoController.fullscreen = NO;
//            
//            [self.viewAtIndex1 addSubview:self.videoController.view];
//            [self.viewAtIndex1 bringSubviewToFront:self.playButton];
//            self.playButton.hidden = NO;
//        }
//        
//    }else
//    {
//        self.textView1.text = self.textToDisplay;
//        self.viewAtIndex0.hidden = NO;
//        self.viewAtIndex1.hidden = YES;
//        
//    }
}

- (IBAction)playButton:(UIButton *)sender
{
    self.playButton.hidden = YES;
    [self.videoController prepareToPlay];
    [self.videoController play];
}

- (BOOL)shouldAutorotate
{
    return NO;
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
