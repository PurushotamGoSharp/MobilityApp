//
//  TabBarViewController.m
//  TabBarDemo
//
//  Created by Colin Eberhardt on 18/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "TabBarViewController.h"
#import "CEPanAnimationController.h"
#import "BadgeNoManager.h"

#import <MCLocalization/MCLocalization.h>



@interface TabBarViewController () <UITabBarControllerDelegate>

@end

@implementation TabBarViewController {
    CEPanAnimationController *_animationController;
    BadgeNoManager *badge;
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
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(upDateBadgeCount)
//                                                     name:@"NewsBadgeCount"
//                                                   object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self localize:nil];
//    [self upDateBadgeCount];
}

-(void )localize:(UITabBar*)tabBar
{
    tabBar = self.tabBar;
    UITabBarItem *tabbarItem = tabBar.items[0];
    tabbarItem.title = [MCLocalization stringForKey:@"Home"];
    
    tabbarItem = tabBar.items[1];
    tabbarItem.title = [MCLocalization stringForKey:@"Setting.Setting"];
    
    tabbarItem = tabBar.items[2];
    tabbarItem.title = [MCLocalization stringForKey:@"Tools"];
    
    
    tabbarItem = tabBar.items[3];
    tabbarItem.title = [MCLocalization stringForKey:@"About"];
}

- (void)upDateBadgeCount
{
    if (badge == nil)
    {
        badge = [[BadgeNoManager alloc] init];
    }
    
    NSInteger badgeNum = [badge totalNoBadges];
    
    UITabBarItem *tabBarItem = self.tabBar.items[1];

    if (badgeNum == 0)
    {
        tabBarItem.badgeValue = nil;
    }else
    {
        tabBarItem.badgeValue = [NSString stringWithFormat:@"%li",(long)badgeNum];
    }
    
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

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    id viewControllerObj = [super viewControllers][selectedIndex];
    
    if ([viewControllerObj isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navCOntroller = (UINavigationController *)viewControllerObj;
        [navCOntroller popToRootViewControllerAnimated:NO];
    }
    
    [super setSelectedIndex:selectedIndex];
}

- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                              toViewController:(UIViewController *)toVC {
    
    NSUInteger fromVCIndex = [tabBarController.viewControllers indexOfObject:fromVC];
    NSUInteger toVCIndex = [tabBarController.viewControllers indexOfObject:toVC];
    
    _animationController.reverse = fromVCIndex > toVCIndex;
    return _animationController;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navCOntroller = (UINavigationController *)viewController;
        [navCOntroller popToRootViewControllerAnimated:NO];
    }
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // You do not need this method if you are not supporting earlier iOS Versions
    return [self.selectedViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations
{
    if (self.selectedViewController)
        return [self.selectedViewController supportedInterfaceOrientations];
    
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end
