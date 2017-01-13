//
//  webClipModel.h
//  SimplicITy
//
//  Created by Vmoksha on 07/01/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface webClipModel : NSObject
//Dashboard Model Data Title Property
@property (nonatomic,strong)NSString *title;
//Dashboard Model Data Image Property
@property (nonatomic,strong)NSString *imageName;
//Dashboard Model Data SeguaName Property
@property(nonatomic,strong)NSString *seguaName;
//Dashboard Model Data Code Property
@property(nonatomic,strong)NSString *code;
//Dashboard Model Data ColorCode Property
@property(nonatomic,strong)NSString *colourCode;

@property (nonatomic,strong)NSString *urlLink;
@property (nonatomic,strong)NSString *imageCode;
@property (nonatomic,strong)UIImage *image;

@end
