//
//  TipDetailsViewController.h
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TipDetailsViewController : CustomColoredViewController

@property (strong, nonatomic) NSString *parentCategory;
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSString *textToDisplay;
@property (strong, nonatomic) NSString *fileName;

@property (strong, nonatomic) MPMoviePlayerController *videoController;

@end
