//
//  TipDetailsViewController.h
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TipModel.h"

@interface TipDetailsViewController : CustomColoredViewController

@property (strong, nonatomic) TipModel *tipModel;

@property (strong, nonatomic) MPMoviePlayerController *videoController;
@property (strong, nonatomic) NSString *parentCategory;
@property (strong, nonatomic) NSString *parentCode;

@end
