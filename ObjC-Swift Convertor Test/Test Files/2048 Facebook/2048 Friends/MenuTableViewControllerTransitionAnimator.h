//
//  MenuTableViewControllerTransitionAnimator.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/28/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Theme;

extern const NSTimeInterval kAnimationDuration_MainToMenuViewControllerTransitionDu;
extern const CGFloat kAnimationSpringDamping_MainToMenuViewControllerTransition;
extern const CGFloat kAnimationSpringVelocity_MainToMenuViewControllerTransition;
extern const CGFloat kMenuViewScaleFraction;

@interface MenuTableViewControllerTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) Theme *theme;

@end
