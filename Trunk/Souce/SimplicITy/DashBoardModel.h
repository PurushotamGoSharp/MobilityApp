//
//  DashBoardModel.h
//  SimplicITy
//
//  Created by Saurabh on 12/19/16.
//  Copyright © 2016 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DashBoardModel : NSObject

//Dashboard Collection View-Dashboard Model Data Title Property
@property (nonatomic,strong)NSString *title;
//Dashboard Collection View-Dashboard Model Data Image Property
@property (nonatomic,strong)NSString *imageName;
//Dashboard Collection View-Dashboard Model Data SeguaName Property
@property(nonatomic,strong)NSString *seguaName;
//Dashboard Collection View-Dashboard Model Data Code Property
@property(nonatomic,strong)NSString *code;
//Dashboard Collection View-Dashboard Model Data Colour Code Property
@property(nonatomic,strong)NSString *colourCode;


@property (nonatomic,strong)NSString *urlLink;
@property (nonatomic,strong)NSString *imageCode;
@property (nonatomic,strong)UIImage *image;

@end
