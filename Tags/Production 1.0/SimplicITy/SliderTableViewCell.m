//
//  SliderTableViewCell.m
//  SimplicITy
//
//  Created by Varghese Simon on 4/20/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "SliderTableViewCell.h"

@implementation SliderTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.lowLabel.font = [self customFont:14 ofName:MuseoSans_300];
    self.mediumLabel.font = [self customFont:14 ofName:MuseoSans_300];
    self.highLabel.font = [self customFont:14 ofName:MuseoSans_300];
    self.criticalLabel.font = [self customFont:14 ofName:MuseoSans_300];
    
    self.imapactLabel.font = [self customFont:16 ofName:MuseoSans_700];

    [self.impactSlider setThumbImage:[UIImage imageNamed:@"grayCircle"]
                            forState:(UIControlStateHighlighted)];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)sliderValueChanged:(UISlider *)sender
{
    [self.delegate sliderTableCell:self
             valueCahngedForSLider:self.impactSlider];
    
    self.impactSlider.value = roundf(sender.value);
    
    [self.impactSlider setThumbImage:[self imageForSLiderThumb:roundf(sender.value)] forState:(UIControlStateNormal)];
    
    if (self.impactSlider.value == 3 )
    {
        [self.impactSlider setTintColor:([UIColor redColor])];
        [self.impactSlider setMinimumTrackTintColor:([UIColor redColor])];
        
        [self setBlackColorFor:self.criticalLabel];
        
    }else if (self.impactSlider.value == 2)
    {
        [self.impactSlider setTintColor:([UIColor orangeColor])];
        [self.impactSlider setMinimumTrackTintColor:([UIColor orangeColor])];
        
        [self setBlackColorFor:self.highLabel];
        
    }else if (self.impactSlider.value == 1)
    {
        [self.impactSlider setTintColor:([UIColor yellowColor])];
        [self.impactSlider setMinimumTrackTintColor:([UIColor yellowColor])];
        
        [self setBlackColorFor:self.mediumLabel];
        
    } if (self.impactSlider.value ==0)
    {
        [self.impactSlider setTintColor:([UIColor greenColor])];
        [self.impactSlider setMinimumTrackTintColor:([UIColor greenColor])];
        
        [self setBlackColorFor:self.lowLabel];
    }

}


- (void)setBlackColorFor:(UILabel *)blackLabel
{
    self.lowLabel.textColor = [UIColor lightGrayColor];
    self.mediumLabel.textColor = [UIColor lightGrayColor];
    self.highLabel.textColor = [UIColor lightGrayColor];
    self.criticalLabel.textColor = [UIColor lightGrayColor];
    
    blackLabel.textColor = [UIColor blackColor];
}

- (void)updateSliderForValue:(NSInteger)value
{
    [self.impactSlider setThumbImage:[self imageForSLiderThumb:value]
                            forState:(UIControlStateNormal)];

}

- (UIImage *)imageForSLiderThumb:(NSInteger)value
{
    switch (value)
    {
        case 0:
            return [UIImage imageNamed:@"greenCirlce"];
            break;
            
        case 1:
            return [UIImage imageNamed:@"YellowCircle"];
            break;
            
        case 2:
            return [UIImage imageNamed:@"OrangeCircle"];
            break;
            
        case 3:
            return [UIImage imageNamed:@"RedCircle"];
            break;
            
        default:
            break;
    }
    return nil;
}

- (UIFont *)customFont:(NSInteger)size ofName:(CustomFontNames)fontName
{
    UIFont *customFont;
    switch (fontName)
    {
        case MuseoSans_100:
            customFont = [UIFont fontWithName:@"MuseoSans-100" size:size];
            break;
        case MuseoSans_300:
            customFont = [UIFont fontWithName:@"MuseoSans-300" size:size];
            break;
        case MuseoSans_700:
            customFont = [UIFont fontWithName:@"MuseoSans-700" size:size];
            break;
        default:
            break;
    }
    return customFont;
}

@end
