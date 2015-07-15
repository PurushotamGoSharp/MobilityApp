//
//  SliderTableViewCell.h
//  SimplicITy
//
//  Created by Varghese Simon on 4/20/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SliderTableViewCell;

@protocol SliderTableCellDelegate <NSObject>
- (void)sliderTableCell:(SliderTableViewCell *)cell valueCahngedForSLider:(UISlider *)slider;
@end

@interface SliderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *imapactLabel;
@property (weak, nonatomic) IBOutlet UISlider *impactSlider;
@property (weak, nonatomic) IBOutlet UILabel *lowLabel;
@property (weak, nonatomic) IBOutlet UILabel *mediumLabel;
@property (weak, nonatomic) IBOutlet UILabel *highLabel;
@property (weak, nonatomic) IBOutlet UILabel *criticalLabel;

@property (weak, nonatomic) id <SliderTableCellDelegate> delegate;

- (void)updateSliderForValue:(NSInteger)value;
- (void)setBlackColorFor:(UILabel *)blackLabel;

@end
