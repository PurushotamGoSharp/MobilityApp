//
//  TabBarViewController.m
//  TabBarDemo
//
//  Created by Colin Eberhardt on 18/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "TabBarViewController.h"
#import "CEPanAnimationController.h"

@interface TabBarViewController () <UITabBarControllerDelegate>

@end

@implementation TabBarViewController {
    CEPanAnimationController *_animationController;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.delegate = self;
        
        // create the interaction / animation controllers
        _animationController = [CEPanAnimationController new];
//        _animationController.folds = 3;
        
        // observe changes in the currently presented view controller
        [self addObserver:self
               forKeyPath:@"selectedViewController"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedViewController"] )
    {
    	// wire the interaction controller to the view controller
    }
}



- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                              toViewController:(UIViewController *)toVC {
    
    NSUInteger fromVCIndex = [tabBarController.viewControllers indexOfObject:fromVC];
    NSUInteger toVCIndex = [tabBarController.viewControllers indexOfObject:toVC];
    
    _animationController.reverse = fromVCIndex > toVCIndex;
    return _animationController;
}



@end
