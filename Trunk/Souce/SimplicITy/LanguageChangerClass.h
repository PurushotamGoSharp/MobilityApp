//
//  LanguageChangerClass.h
//  SimplicITy
//
//  Created by Saurabh on 2/3/16.
//  Copyright © 2016 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol languageChangeProtocol <NSObject>

-(void)successResponseDelegateMethod;
-(void)failourResponseDelegateMethod;

@end


@interface LanguageChangerClass : NSObject

@property(nonatomic,strong)id<languageChangeProtocol>delegate;
-(void)changeLanguageWithCode:(NSString*)langCode;


@end
