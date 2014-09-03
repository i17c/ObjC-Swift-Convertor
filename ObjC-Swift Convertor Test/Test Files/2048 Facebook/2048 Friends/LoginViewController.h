//
//  ViewController.h
//  2048 FB
//
//  Created by Shuyang Sun on 3/31/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class GameViewController;
@class Theme;

// constant variables
extern const NSTimeInterval kViewControllerDuration_Animation;
extern const NSTimeInterval kViewControllerDuration_Delay;
extern const NSTimeInterval kViewControllerDuration_SpringDamping;
extern const NSTimeInterval kViewControllerDuration_SpringVelocity;

@interface LoginViewController : UIViewController <FBLoginViewDelegate>

/// The Facebook login button, may not neccesarily be shown on the screen, but is sent event when user want to log in/out.

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (weak, nonatomic) IBOutlet UIButton *customFacebookLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *customTwitterLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *customWeiboLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *updatePictureButton;
@property (nonatomic, strong) Theme *theme;

/// Handles pan gestures on the "Introduction" page.
- (void)handlePan:(UIPanGestureRecognizer *)sender;
// When the custom login UI get touched
- (IBAction)customFacebookLoginButtonTouched:(UIButton *)sender;
- (IBAction)updatePictureButtonTouched:(UIButton *)sender;

@end
