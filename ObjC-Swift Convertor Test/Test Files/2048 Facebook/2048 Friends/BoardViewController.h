//
//  BoardViewController.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/8/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

extern const CGFloat kAnimationDuration_Default;
extern const CGFloat kAnimationDuration_ScreenBlur;
extern const CGFloat kAnimationDuration_MoveTile;
extern const CGFloat kAnimationDelay_GameOver;
extern const CGFloat kAnimationDuration_ScaleTile;
extern const CGFloat kAnimationDuration_TextFade;
extern const CGFloat kAnimationSpring_Damping;
extern const CGFloat kAnimationSpring_Velocity;
extern const CGFloat kTextShowDuration;
extern const CGFloat kBoardPanMinDistance;
extern const CGFloat kLineWidthDefault_iPhone;
extern const NSUInteger kDefaultContextSavingSwipeNumber;

typedef NS_ENUM(NSUInteger, BoardViewControllerMode) {
	BoardViewControllerModePlaying = 0, // When user is playing with this board
	BoardViewControllerModeHisory,      // When user is using this board reviewing history
	BoardViewControllerModeShow         // When this is just a non interactive showing of the board
};

@interface BoardViewController : UIViewController <ADBannerViewDelegate>

// Upper screen views
@property (weak, nonatomic) IBOutlet UIView *profilePictureView;
@property (weak, nonatomic) IBOutlet UIButton *profilePictureButton;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIButton *menuView;
@property (weak, nonatomic) IBOutlet UIView *bestScoreView;
@property (weak, nonatomic) IBOutlet UILabel *bestScoreLabel;
@property (weak, nonatomic) IBOutlet UIView *scoreView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

// On board views
@property (weak, nonatomic) IBOutlet UIView *boardView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *tileContainerViews;
@property (weak, nonatomic) IBOutlet UIView *boardViewInteractionLayer;

@property (weak, nonatomic) IBOutlet UIView *pauseView;
@property (weak, nonatomic) IBOutlet UIImageView *pauseImageView;
@property (weak, nonatomic) IBOutlet UILabel *gameStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *retryOrKeepPlayingButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutletCollection(UISwipeGestureRecognizer) NSArray *swipeGestureRecognizers;


@property (weak, nonatomic) IBOutlet UILabel *textLabel;

- (IBAction)profilePictureButtonTouched:(UIButton *)sender;
- (IBAction)menuTapped:(UIButton *)sender;
- (IBAction)retryOrKeepPlayingTapped:(UIButton *)sender;

- (IBAction)profilePictureBeingHold:(UILongPressGestureRecognizer *)sender;
- (IBAction)boardSwiped:(UISwipeGestureRecognizer *)sender;

@end
