//
//  MenuTableViewControllerTransitionAnimator.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/28/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "MenuTableViewControllerTransitionAnimator.h"
#import "GameViewController.h"
#import "MenuTableViewController.h"
#import "Theme.h"
#import "macro.h"

const NSTimeInterval kAnimationDuration_MainToMenuViewControllerTransition = SCALED_ANIMATION_DURATION(0.5f);
const CGFloat kAnimationSpringDamping_MainToMenuViewControllerTransition = 0.8f;
const CGFloat kAnimationSpringVelocity_MainToMenuViewControllerTransition = 0.4f;
const CGFloat kMenuViewScaleFraction = 0.95f;

@implementation MenuTableViewControllerTransitionAnimator

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
	return kAnimationDuration_MainToMenuViewControllerTransition;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	// If we're transitioning to menu table view:
	if ([[transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey] isKindOfClass:[GameViewController class]]) {
		// Get container view, from and to View controllers
		UIView *containerView = [transitionContext containerView];
		GameViewController *fromViewController = (GameViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
		UINavigationController *toViewController = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
		
		[containerView addSubview:fromViewController.view];
		CGFloat yTransform = fromViewController.menuButton.frame.origin.y + fromViewController.menuButton.frame.size.height/2.0f;
		yTransform = yTransform - toViewController.view.frame.size.height/2.0f;
		CGAffineTransform menuViewTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, yTransform);
		menuViewTransform = CGAffineTransformScale(menuViewTransform, 1.0f, 0.0f);
		toViewController.view.transform = menuViewTransform;
		toViewController.view.alpha = 0.0f;
		[containerView addSubview:toViewController.view];
		
		// Add a grey layer:
		fromViewController.greyLayerView = [[UIView alloc] initWithFrame:fromViewController.view.bounds];
		fromViewController.greyLayerView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
		fromViewController.greyLayerView.alpha = 0.0f;
		CGFloat halfHeightOfMenuButton = fromViewController.menuButton.frame.size.height;
		CGAffineTransform menuButtonTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, halfHeightOfMenuButton);
		menuButtonTransform = CGAffineTransformScale(menuButtonTransform, 1.0f, 0.0f);
		[fromViewController.view addSubview:fromViewController.greyLayerView];
		[fromViewController.view bringSubviewToFront:fromViewController.greyLayerView];
		
		[UIView animateWithDuration:kAnimationDuration_MainToMenuViewControllerTransition
							  delay:0.0f
			 usingSpringWithDamping:kAnimationSpringDamping_MainToMenuViewControllerTransition
			  initialSpringVelocity:kAnimationSpringVelocity_MainToMenuViewControllerTransition
							options:UIViewAnimationOptionCurveLinear
						 animations:^{
							 // Add a gray layer on top of the from view, so it's deemed out.
							 fromViewController.greyLayerView.alpha = 1.0f;
							 // Animate the "Menu" button
							 fromViewController.menuButton.transform = menuButtonTransform;
							 fromViewController.menuButton.titleLabel.alpha = 0.0f;
							 // Animate to view.
							 toViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, kMenuViewScaleFraction, kMenuViewScaleFraction);
							 toViewController.view.alpha = 1.0f;
						 }
						 completion:^(BOOL finished) {
							 [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
						 }];
	// Dismiss menu
	} else  {
		// Get container view, from and to View controllers
		UIView *containerView = [transitionContext containerView];
		UINavigationController *fromViewController = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
		GameViewController *toViewController = (GameViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
		
		[containerView addSubview:toViewController.view];
		[containerView addSubview:fromViewController.view];
		
		CGFloat yTransform = toViewController.menuButton.frame.origin.y + toViewController.menuButton.frame.size.height/2.0f;
		yTransform = yTransform - toViewController.view.frame.size.height/2.0f;
		CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, yTransform);
		transform = CGAffineTransformScale(transform, 0.0f, 0.0f);
		
		[UIView animateWithDuration:kAnimationDuration_MainToMenuViewControllerTransition
							  delay:0.0f
			 usingSpringWithDamping:kAnimationSpringDamping_MainToMenuViewControllerTransition
			  initialSpringVelocity:kAnimationSpringVelocity_MainToMenuViewControllerTransition
							options:UIViewAnimationOptionCurveLinear
						 animations:^{
							 // Make the grey layer transparent
							 toViewController.greyLayerView.alpha = 0.0f;
							 // Restore the menu button
							 toViewController.menuButton.transform = CGAffineTransformIdentity;
							 toViewController.menuButton.titleLabel.alpha = 1.0f;
							 // Dismiss the menu view
							 fromViewController.view.transform = transform;
							 fromViewController.view.alpha = 0.0f;
						 }
						 completion:^(BOOL finished) {
							 [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
						 }];
	}
}

@end
