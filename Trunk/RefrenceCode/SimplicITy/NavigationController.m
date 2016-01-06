//
//  MyNavigationControllerViewController.m
//  ViewControllerTransitions
//
//  Created by Colin Eberhardt on 09/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "NavigationController.h"
#import "AppDelegate.h"
#import "CEReversibleAnimationController.h"
#import "CEPanAnimationController.h"

@interface NavigationController () <UINavigationControllerDelegate>

@end

@implementation NavigationController
{
    CEPanAnimationController *_animationController;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.delegate = self;
    
        _animationController = [CEPanAnimationController new];
    }
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    _animationController.reverse = operation == UINavigationControllerOperationPop;
    return _animationController;
}


@end
