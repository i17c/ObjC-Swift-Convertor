//
//  GameViewController.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/19/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "GameViewController.h"
#import <iAd/iAd.h>
#import "AppDelegate.h"
#import "GameManager+ModelLayer03.h"
#import "History+ModelLayer03.h"
#import "Board+ModelLayer03.h"
#import "Tile+ModelLayer03.h"
#import "Theme.h"
#import "macro.h"

#import "BoardScene.h"
#import "TileSKShapeNode.h"
#import "UIImage+ImageEffects.h"
#import "MenuTableViewController.h"
#import "MenuTableViewControllerTransitionAnimator.h"

// Defines for localization
#define STRING_GAME_OVER_LABEL NSLocalizedStringFromTable(@"STRING_GAME_OVER_LABEL", @"GameViewControllerTable", @"Text on Game Over label.")
#define STRING_TRY_AGAIN NSLocalizedStringFromTable(@"STRING_TRY_AGAIN", @"GameViewControllerTable", @"Text on play again button.")

// Constants
const NSTimeInterval kAnimationDuration_Default = SCALED_ANIMATION_DURATION(0.1f);
const NSTimeInterval kAnimationDuration_ScreenBlur = SCALED_ANIMATION_DURATION(1.5f);
const NSTimeInterval kAnimationDuration_ScaleTile = SCALED_ANIMATION_DURATION(1.0f);
const NSTimeInterval kAnimationDuration_MoveTile = SCALED_ANIMATION_DURATION(0.2f);
const NSTimeInterval kAnimationDelay_GameOver = SCALED_ANIMATION_DURATION(0.0f);
const NSTimeInterval kAnimationDuration_TextFade = SCALED_ANIMATION_DURATION(0.5f);
const NSTimeInterval kTextShowDuration = 5.0f;
const NSTimeInterval kReplayBoardShowDuration = 0.2f;
const CGFloat kAnimationSpring_Damping = 0.5f;
const CGFloat kAnimationSpring_Velocity = 0.4f;

const CGFloat kTileMoveAnimationDurationFraction = 1.5f;

const CGFloat kBoardPanMinDistance = 5.0f;
const CGFloat kLineWidthDefault_iPhone = 8.0f;

const NSUInteger kDefaultContextSavingSwipeNumber = 10;

@interface GameViewController ()

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UIView *profilePictureView;
@property (weak, nonatomic) IBOutlet UIView *profilePictureInteractionLayer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *profilePictureTapGestureRecognizer;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *profilePictureLongPressGestureRecognizer;
@property (weak, nonatomic) IBOutlet SKView *boardSKView;
@property (weak, nonatomic) IBOutlet UIView *boardInteractionLayerVIew;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (weak, nonatomic) IBOutlet UISlider *replaySlider;
@property (weak, nonatomic) IBOutlet UIButton *replayPreviousButton;
@property (weak, nonatomic) IBOutlet UIButton *replayNextButton;
@property (weak, nonatomic) IBOutlet UIButton *replayPlayButton;

@property (weak, nonatomic) IBOutlet UIView *pauseView;
@property (weak, nonatomic) IBOutlet UIImageView *pauseImageView;
@property (weak, nonatomic) IBOutlet UILabel *pauseLabel;
@property (weak, nonatomic) IBOutlet UIButton *resumeGameButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

#pragma mark - Analyzing Algorithm Property
@property (nonatomic) BoardSwipeGestureDirection direction;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) BOOL analyzed;
@property (nonatomic, assign) BOOL canSwipeToDesiredDirection;

#pragma mark - SKAction for Animation
@property (nonatomic, strong) SKAction *tileMagnifyAction;

#pragma mark - Other Private Properties
@property (strong, nonatomic) Theme *theme;
@property (strong, nonatomic) GameManager *gManager;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) UIImage *lastFullScreenSnapshot;
@property (nonatomic, assign) CGFloat scaledFraction;
// This timer is for displaying text, everytime the text needs to update, the timer get stopped, and start again.
@property (nonatomic, strong) NSTimer *messageUpdateTimer;
/** This timer is for play replay. Every time the play button get hit, the timer starts.
 *  When the replay is playing, the timer is not nil, when the replay is not playing, the timer should be nil.
 *  This timer indicates if the replay is playing. (as like a boolean variable)
 */
@property (nonatomic, strong) NSTimer *replayTimer;

@property (nonatomic, assign) NSUInteger lastSliderValue;

@end

@implementation GameViewController

#pragma mark - Setup Methods
-(void)setup
{
	// Initialization code here...
	
	self.gManager = [GameManager sharedGameManager];
	self.theme = [Theme sharedThemeWithID:self.gManager.currentThemeID];
	self.messageLabel.textAlignment = NSTextAlignmentCenter;
	self.bestScoreLabel.textAlignment = NSTextAlignmentCenter;
	self.scoreLabel.textAlignment = NSTextAlignmentCenter;
	self.appDelegate = [UIApplication sharedApplication].delegate;
	self.canSwipeToDesiredDirection = YES;
	self.canDisplayBannerAds = YES;
	
	// Setup SKActions
	CGFloat scaleFactor = 1+((self.scene.size.width - 4 * self.theme.tileWidth)/5.0f)/self.theme.tileWidth;
	self.tileMagnifyAction = [SKAction group:@[[SKAction scaleTo:scaleFactor duration:kAnimationDuration_Default * 2],
											   [SKAction moveBy:CGVectorMake(-self.theme.tileWidth*((scaleFactor - 1)/2.0f), -self.theme.tileWidth*((scaleFactor - 1)/2))
																	 duration:kAnimationDuration_Default * 2]]];
}

-(void)awakeFromNib
{
	[self setup];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self updateThemeAnimated:NO];
	_pauseLabel.textAlignment = NSTextAlignmentCenter;
	_resumeGameButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	_shareButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	
    // SpriteKit stuff
    SKView * skView = (SKView *)_boardSKView;
    
    // Create and configure the scene.
    self.scene = [BoardScene sceneWithSize:skView.bounds.size andTheme:self.theme];
	if (!_theme) {
		GameManager *gManager = [GameManager sharedGameManager];
		self.theme = [Theme sharedThemeWithID:gManager.currentThemeID];
	}
	_scene.theme = self.theme;
    _scene.scaleMode = SKSceneScaleModeAspectFill;
	_scene.gameViewController = self;
	
	_profilePictureImageView.contentMode = UIViewContentModeScaleAspectFill;
	UIImage *profileImage = [Tile tileWithValue:2048].image;
	if (profileImage) {
		_profilePictureImageView.image = profileImage;
	}
	
    // Present the scene.
    [skView presentScene:self.scene];
}

-(void)viewDidLayoutSubviews {
	self.width = self.boardSKView.frame.size.width;
	self.height  = self.boardSKView.frame.size.height;

}

-(void)updateThemeAnimated:(BOOL) animated {
	if (animated) {
		[UIView animateWithDuration:kAnimationDuration_ScreenBlur
							  delay:0.0f
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
							 [self setThemeDataForViews];
						 } completion:nil];
	} else {
		[self setThemeDataForViews];
	}
}

-(void)setThemeDataForViews {
	// Change the corner radius of views
	_boardSKView.layer.cornerRadius = _theme.boardCornerRadius;
	_boardSKView.layer.masksToBounds = YES;
	_profilePictureView.layer.cornerRadius = _theme.buttonCornerRadius;
	_profilePictureView.layer.masksToBounds = YES;
	_profilePictureImageView.layer.cornerRadius = _theme.buttonCornerRadius;
	_profilePictureImageView.layer.masksToBounds = YES;
	_profilePictureInteractionLayer.layer.cornerRadius = _theme.buttonCornerRadius;
	_profilePictureInteractionLayer.layer.masksToBounds = YES;
	_menuButton.layer.cornerRadius = _theme.buttonCornerRadius;
	_menuButton.layer.masksToBounds = YES;
	_bestScoreLabel.layer.cornerRadius = _theme.buttonCornerRadius;
	_scoreLabel.layer.cornerRadius = _theme.buttonCornerRadius;
	_resumeGameButton.layer.cornerRadius = _theme.buttonCornerRadius;
	_resumeGameButton.layer.masksToBounds = YES;
	_shareButton.layer.cornerRadius = _theme.buttonCornerRadius;
	_shareButton.layer.masksToBounds = YES;
	_replayPreviousButton.layer.cornerRadius = _theme.buttonCornerRadius;
	_replayPreviousButton.layer.masksToBounds = YES;
	_replayNextButton.layer.cornerRadius = _theme.buttonCornerRadius;
	_replayNextButton.layer.masksToBounds = YES;
	_replayPlayButton.layer.cornerRadius = _theme.buttonCornerRadius;
	_replayPlayButton.layer.masksToBounds = YES;
	
	// Change the color of views
	self.originalContentView.backgroundColor = _theme.backgroundColor;
	_boardSKView.backgroundColor = _theme.boardColor;
	_profilePictureView.backgroundColor = _theme.tileColors[@(2048)];
	_resumeGameButton.backgroundColor = _theme.boardColor;
	_shareButton.backgroundColor = _theme.boardColor;
	_scoreLabel.backgroundColor = _theme.tileColors[@(4)];
	_menuButton.backgroundColor = _theme.buttonColor;
	_messageLabel.textColor = _theme.tileTextColor;
	_replaySlider.minimumTrackTintColor = _theme.boardColor;
	_replaySlider.maximumTrackTintColor = _theme.tileColors[@(4)];
	_replayPreviousButton.backgroundColor = _replayNextButton.backgroundColor = _replayPlayButton.backgroundColor = _theme.buttonColor;
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.scene.tileType == TileTypeImage) {
		UIImage *image = [Tile tileWithValue:2048].image;
		if (image) {
			image = [self.scene cropImageToRoundedRect:image];
			self.profilePictureImageView.image = image;
		}
	}
	
	/** The following code is to hide/show views on the controller based on the current view controller mode (play or replay). */
	// Play Mode
	if (_mode == GameViewControllerModePlay) {
		[_scene popupTileContainersAnimated:YES];
		_replaySlider.alpha = 0.0f;
		_replayPreviousButton.alpha = 0.0f;
		_replayNextButton.alpha = 0.0f;
		_replayPlayButton.alpha = 0.0f;
	// Replay Mode
	} else if (_mode == GameViewControllerModeReplay) {
		self.canDisplayBannerAds = NO;
		[self enableButtonAndGestureInteractions:NO];
		_menuButton.alpha = 0.0f;
		_profilePictureView.alpha = 0.0f;
		_messageLabel.alpha = 0.0f;
		_bestScoreLabel.alpha = 0.0f;
		_scene.tileType = TileTypeNumber;
		_replaySlider.minimumValue = 0.0f;
		_replaySlider.maximumValue = (float)([_replayBoards count] - 1);
		
		// TODO: Instead of make these buttons invisible, display them as grey.
		if (_replaySlider.maximumValue == 0.0f) {
			_replaySlider.alpha = 0.0f;
			_replayPreviousButton.alpha = 0.0f;
			_replayNextButton.alpha = 0.0f;
			_replayPlayButton.alpha = 0.0f;
		} else {
			_replaySlider.alpha = 1.0f;
			_replayPreviousButton.alpha = 1.0f;
			_replayNextButton.alpha = 1.0f;
			_replayPlayButton.alpha = 1.0f;
		}
		self.lastSliderValue = 0;
		// TODO: Change constraints and frame for _scoreLabel
		[_scene popupTileContainersAnimated:NO];
		[_scene startGameFromBoard:_replayBoards[0] animated:NO];
	}
}

-(BOOL)prefersStatusBarHidden {
	return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - IBActions

/** Seperating replay replated methods because of timer issue.
 *  When the user actually tap on a button, the timer get stopped.
 *  But the "play" timer only fires the helper methods corresponding to IBAction methods,
 *  so the "[_replayTimer invalidate];" line won't get called.
 */

// TODO: Use images instead of text to show "Play" and "Pause"
- (IBAction)replaySliderSlided:(UISlider *)sender {
	[_replayTimer invalidate];
	[_replayPlayButton setTitle:@"Play" forState:UIControlStateNormal];
	self.replayTimer = nil;
	[self showBoardInHistoryWithSlider:sender];
}

-(void)showBoardInHistoryWithSlider: (UISlider *)sender {
	NSUInteger currentValue = (NSUInteger)sender.value;
	if (currentValue != _lastSliderValue) {
		/** Change the button color based on slider value
		 *  If the last slider value is not the same as this one, check to see if we need to change color.
		 *  If the last slider value is 0, now it's changed, enable previous button.
		 *  If the last slider value is [_replayBoards count], and now it's changed, enable next and play button.
		 */
		if (_lastSliderValue <= 0) {
			_replayPreviousButton.backgroundColor = _theme.buttonColor;
			_replayPreviousButton.enabled = YES;
		} else if (_lastSliderValue >= [_replayBoards count] - 1) {
			_replayNextButton.backgroundColor = _theme.buttonColor;
			_replayPlayButton.backgroundColor = _theme.buttonColor;
			_replayNextButton.enabled = YES;
			_replayPlayButton.enabled = YES;
		}
		if (currentValue < 1) {
			_replayPreviousButton.backgroundColor = [UIColor grayColor];
			_replayPreviousButton.enabled = NO;
		}
		if (currentValue >= [_replayBoards count] - 1) {
			_replayNextButton.backgroundColor = [UIColor grayColor];
			_replayPlayButton.backgroundColor = [UIColor grayColor];
			_replayNextButton.enabled = NO;
			_replayPlayButton.enabled = NO;
		}
		
		self.lastSliderValue = currentValue;
		[_scene startGameFromBoard:_replayBoards[currentValue] animated:NO];
	}
}

- (IBAction)replayPreviousTapped:(UIButton *)sender {
	[_replayTimer invalidate];
	[_replayPlayButton setTitle:@"Play" forState:UIControlStateNormal];
	self.replayTimer = nil;
	[self showPreviousBoardInHistory];
}

-(void)showPreviousBoardInHistory {
	if (_lastSliderValue < 1) {
		return;
	} else {
		_replaySlider.value = _replaySlider.value - 1;
		[self showBoardInHistoryWithSlider:_replaySlider];
	}
}

- (IBAction)replayNextTapped:(UIButton *)sender {
	[_replayTimer invalidate];
	[_replayPlayButton setTitle:@"Play" forState:UIControlStateNormal];
	self.replayTimer = nil;
	[self showNextBoardInHistory];
}

-(void)showNextBoardInHistory {
	if (_lastSliderValue > [_replayBoards count] - 2) {
		return;
	} else {
		_replaySlider.value = _replaySlider.value + 1;
		[self showBoardInHistoryWithSlider:_replaySlider];
	}
}

- (IBAction)replayPlayTapped:(UIButton *)sender {
	if (_replayTimer) {
		[_replayPlayButton setTitle:@"Play" forState:UIControlStateNormal];
		[_replayTimer invalidate];
		self.replayTimer = nil;
	} else {
		[_replayPlayButton setTitle:@"Pause" forState:UIControlStateNormal];
		self.replayTimer = [NSTimer timerWithTimeInterval:kReplayBoardShowDuration
												   target:self
												 selector:@selector(showNextBoardInHistory)
												 userInfo:nil
												  repeats:YES];
		NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
		[runLoop addTimer:_replayTimer
				  forMode:NSRunLoopCommonModes];
	}
}

- (IBAction)profilePictureTapped:(UITapGestureRecognizer *)sender {
	
	UIGestureRecognizerState state = sender.state;
	if (state == UIGestureRecognizerStateRecognized) {
		
		self.gManager.tileViewType = (int16_t)self.scene.tileType;
		NSArray *allNodes = [self.scene.nodeForIndexes allValues];
		for (TileSKShapeNode *node in allNodes) {
			if (self.scene.tileType == TileTypeImage) {
				[node hideImageAnimated:YES];
			} else if (self.scene.tileType == TileTypeNumber) {
				[node showImageAnimated:YES];
			}
		}
		
		if (self.scene.tileType == TileTypeNumber) {
			self.scene.tileType = TileTypeImage;
		} else if (self.scene.tileType == TileTypeImage) {
			self.scene.tileType = TileTypeNumber;
		}
		self.gManager.tileViewType = (int16_t)self.scene.tileType;
		[self saveContext];
	}
}

- (IBAction)profilePictureBeingHold:(UILongPressGestureRecognizer *)sender {
	if (self.scene.tileType == TileTypeImage) {
		if (sender.state == UIGestureRecognizerStateBegan) { // Animate show number layer
			NSArray *allNodes = [self.scene.nodeForIndexes allValues];
			for (TileSKShapeNode *node in allNodes) {
				[node transparentImageAnimated:YES];
			}
			[UIView animateWithDuration:kAnimationDuration_ImageTransparent
							 animations:^{
								 self.profilePictureImageView.alpha = kAnimationImageTransparencyFraction;
							 }];
		} else if (sender.state == UIGestureRecognizerStateEnded ||
				   sender.state == UIGestureRecognizerStateCancelled ||
				   sender.state == UIGestureRecognizerStateFailed) { // Animate hide number layer
			NSArray *allNodes = [self.scene.nodeForIndexes allValues];
			for (TileSKShapeNode *node in allNodes) {
				[node opaqueImageAnimated:YES];
			}
			[UIView animateWithDuration:kAnimationDuration_ImageTransparent
							 animations:^{
								 self.profilePictureImageView.alpha = 1.0f;
							 }];
		}
	}
}

- (IBAction)resumeButtonTapped:(UIButton *)sender {
	if (sender.tag == 0) { // If it's try again button
		for (NSValue *value in [self.scene.positionsForNodes allKeys]) {
			SKShapeNode *node = [value nonretainedObjectValue];
			[node removeFromParent];
		}
		[self enableButtonAndGestureInteractions:NO];
		[UIView animateWithDuration:kAnimationDuration_Default
						 animations:^{
							 self.pauseView.alpha = 0.0f;
						 }
						 completion:^(BOOL finished) {
							 [self.scene initializePropertyLists];
							 self.scene.gamePlaying = YES;
							 self.scene.score = 0;
							 self.scene.board = [Board initializeNewBoard];
							 self.scene.history = self.scene.board.boardHistory;
							 [self.scene startGameFromBoard:self.scene.board animated:YES];
							 [self enableButtonAndGestureInteractions:YES];
						 }];
	}
}

- (IBAction)shareButtonTapped:(UIButton *)sender {
	self.scene.paused = NO;
	self.boardSKView.paused = NO;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)sender {
	UIGestureRecognizerState state = sender.state;
	
	if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStatePossible) {
		self.analyzed = NO;
		self.direction = BoardSwipeGestureDirectionNone;
	} else if (state == UIGestureRecognizerStateChanged) {
		CGPoint translate = [sender translationInView:self.boardSKView];
		CGFloat x = translate.x;
		CGFloat y = translate.y;
		// Set the direction
		if (fabs(x) >= 5 || fabs(y) >= 5) {
			if (self.direction == BoardSwipeGestureDirectionNone) {
				if (fabs(x) > fabs(y)) { // Left or Right
					if (x > 0) {
						self.direction = BoardSwipeGestureDirectionRight;
					} else {
						self.direction = BoardSwipeGestureDirectionLeft;
					}
				} else { // Up or Down
					if (y > 0) {
						self.direction = BoardSwipeGestureDirectionDown;
					} else {
						self.direction = BoardSwipeGestureDirectionUp;
					}
				}
			}
			
			if (self.direction != BoardSwipeGestureDirectionNone && !self.analyzed) {
				self.analyzed = YES;
#ifdef DEBUG
				NSDate *start = [NSDate date];
#endif
				self.canSwipeToDesiredDirection = [self.scene analyzeTilesForSwipeDirection:self.direction completion:nil];
#ifdef DEBUG
				NSDate *end = [NSDate date];
				NSLog(@"Took %f seconds analyzing swiping %@", [end timeIntervalSinceDate:start], [Board directionStringFromDirection:self.direction]);
#endif
				if (self.canSwipeToDesiredDirection == NO) {
					self.direction = BoardSwipeGestureDirectionNone;
				}
			}
			
			if (self.direction != BoardSwipeGestureDirectionNone && self.analyzed) {
				CGFloat fraction = 0.0f;
				if  ((self.direction == BoardSwipeGestureDirectionLeft && x < 0) ||
					 (self.direction == BoardSwipeGestureDirectionRight && x > 0)) {
					fraction = fabs(x/(self.width/2.0f));
				} else if ((self.direction == BoardSwipeGestureDirectionUp && y < 0) ||
						   (self.self.direction == BoardSwipeGestureDirectionDown && y > 0)) {
					fraction = fabs(y/(self.height/2.0f));
				}
				// If we can swipe to that direction, swipe it
				if (self.canSwipeToDesiredDirection) {
										[self.scene swipeToDirection:self.direction withFraction:fraction];
				// If we cannot swipe to that direction, do the animation.
				} else {
					[self.scene animateTileScaleToDirection:self.direction withFraction:fraction];
				}
			}
		}
	} else if (state == UIGestureRecognizerStateEnded ||
			   state == UIGestureRecognizerStateCancelled ||
			   state == UIGestureRecognizerStateFailed) {
		// If the board can be swiped previously:
		if (self.canSwipeToDesiredDirection) {
			CGPoint translate = [sender translationInView:self.boardSKView];
			if ((self.direction == BoardSwipeGestureDirectionLeft && translate.x < 0) ||
				(self.direction == BoardSwipeGestureDirectionRight && translate.x > 0)) {
				CGFloat f = fabs(translate.x/(self.width/2.0f));
				f = MIN(1.0f, f);
				f = MAX(0.0f, f);
				f = 1.0f - f;
				// If cancelled or failed: reverse it
				if (fabs(translate.x/(self.width/2.0f)) > 0.5 && state == UIGestureRecognizerStateEnded) {
					[self.scene finishSwipeAnimationWithDuration:kAnimationDuration_Default*f * kTileMoveAnimationDurationFraction];
					[self saveContext];
				} else {
					[self.scene reverseSwipeAnimationWithDuration:kAnimationDuration_Default*f * kTileMoveAnimationDurationFraction];
				}
			} else if ((self.direction == BoardSwipeGestureDirectionUp && translate.y < 0) ||
					   (self.direction == BoardSwipeGestureDirectionDown && translate.y > 0)) {
				CGFloat f = fabs(translate.y/(self.height/2.0f));
				f = MIN(1.0f, f);
				f = MAX(0.0f, f);
				f = 1-f;
				if (fabs(translate.y/(self.height/2.0f)) > 0.5 && state == UIGestureRecognizerStateEnded) {
					[self.scene finishSwipeAnimationWithDuration:kAnimationDuration_Default* f * kTileMoveAnimationDurationFraction];
					[self saveContext];
				} else {
					[self.scene reverseSwipeAnimationWithDuration:kAnimationDuration_Default* f * kTileMoveAnimationDurationFraction];
				}
			}
		// If we can't swipe to a direction, but we have a direction:
		} else if (self.direction != BoardSwipeGestureDirectionNone) {
			// Restore the scale animation
			[self.scene reverseTileScaleAnimationWithDuration:kAnimationDuration_Default];
		}
		
		self.analyzed = NO;
		self.direction = BoardSwipeGestureDirectionNone;
		self.canSwipeToDesiredDirection = YES;
	}
}

#pragma mark - Custom View Controller Transitions

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[super prepareForSegue:segue sender:sender];
	// If we are going to menu view
	if ([segue.identifier isEqualToString:@"GameViewControllerToMenuTableViewControllerSegue"]) {
		UIViewController *menuNavigationViewController = segue.destinationViewController;
		menuNavigationViewController.transitioningDelegate = self;
		menuNavigationViewController.modalPresentationStyle = UIModalPresentationCustom;
		menuNavigationViewController.view.layer.cornerRadius = self.theme.boardCornerRadius;
		menuNavigationViewController.view.layer.masksToBounds = YES;
		// Add button corner radius
		menuNavigationViewController.view.layer.cornerRadius = self.theme.buttonCornerRadius;
		menuNavigationViewController.view.layer.masksToBounds = YES;
		
		// Set the theme for menu tableViewController
		if ([menuNavigationViewController isKindOfClass:[UINavigationController class]]) {
			UIViewController *topViewController = ((UINavigationController *) menuNavigationViewController).topViewController;
			if ([topViewController isKindOfClass:[MenuTableViewController class]]) {
				MenuTableViewController *menuTableViewController = (MenuTableViewController *)topViewController;
				menuTableViewController.theme = self.theme;
				menuTableViewController.gViewController = self;
			}
		}
	}
}

// Should return an animator object to handle the presenting (other view controllers) transition.
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented // The view controller is going to be presented on the screen.
																 presentingController:(UIViewController *)presenting
																	 sourceController:(UIViewController *)source { // Source view controller is this one.
	if (([source isKindOfClass: [self class]] && [presenting isKindOfClass:[self class]])) { // If source is this view controller
		self.menuNavigationViewControllerAnimator = [[MenuTableViewControllerTransitionAnimator alloc] init];
		presented.modalPresentationStyle = UIModalPresentationCustom;
		presented.transitioningDelegate = self;
		return self.menuNavigationViewControllerAnimator;
	}
	self.menuNavigationViewControllerAnimator = [[MenuTableViewControllerTransitionAnimator alloc] init];
	self.menuNavigationViewControllerAnimator.theme = self.theme;
	return self.menuNavigationViewControllerAnimator;
}

// Should return an animator object to handle the dismissing (other view controllers) transition.
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	self.transitioningDelegate = self;
	self.menuNavigationViewControllerAnimator = [[MenuTableViewControllerTransitionAnimator alloc] init];
	self.menuNavigationViewControllerAnimator.theme = self.theme;
	return self.menuNavigationViewControllerAnimator;
}

#pragma mark - Helper Methods

-(void)saveContext {
	dispatch_queue_t contextSavingQueue = dispatch_queue_create("Context Saving Queue", NULL);
	dispatch_async(contextSavingQueue, ^{
		[self.appDelegate saveContext];
	});
}

-(void)enableGestureRecognizers:(BOOL)enabled {
	self.panGestureRecognizer.enabled = enabled;
}

-(void)enableButtonAndGestureInteractions:(BOOL)enabled {
	[self enableGestureRecognizers:enabled];
	self.profilePictureTapGestureRecognizer.enabled = enabled;
	self.profilePictureLongPressGestureRecognizer.enabled = enabled;
}

-(void)showGameEndView {
	if (_scene.gamePlaying == NO &&
		_mode == GameViewControllerModePlay) {
		// Disable some user interactions.
		[self enableButtonAndGestureInteractions:NO];
		
		// Task a snapshot for sharing
		UIGraphicsBeginImageContextWithOptions(self.originalContentView.bounds.size, YES, 0.0f);
		[_boardSKView drawViewHierarchyInRect:self.originalContentView.bounds afterScreenUpdates:YES];
		self.lastFullScreenSnapshot = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		_pauseView.alpha = 0.0f;
		[_boardSKView bringSubviewToFront:self.pauseView];
		[_boardSKView bringSubviewToFront:self.pauseImageView];
		[_pauseView bringSubviewToFront:self.pauseLabel];
		[_pauseView bringSubviewToFront:self.shareButton];
		[_pauseView bringSubviewToFront:self.resumeGameButton];
		_pauseLabel.tag = 0;
		self.pauseLabel.text = STRING_GAME_OVER_LABEL;
		self.resumeGameButton.tag = 0; // 0 Represents "play again"
		self.resumeGameButton.titleLabel.text = STRING_TRY_AGAIN;
		__block UIImage *snapshot;
		NSArray *allTileViewsWithoutNewTile = [self.scene.positionsForNodes allKeys];
		NSMutableArray *allTileViews = [NSMutableArray arrayWithArray:allTileViewsWithoutNewTile];
		NSValue *newNSValueTile = [[self.scene.positionForNewRandomTile allKeys] lastObject];
		if (newNSValueTile) {
			[allTileViews addObject:newNSValueTile];
		}
		// Disable gesture recognizers for now
		[self enableGestureRecognizers:NO];
		NSUInteger count = 0;
		NSUInteger size = [allTileViews count];
		void (^completion)() = nil;
		for (NSValue *value in allTileViews) {
			TileSKShapeNode *tile = [value nonretainedObjectValue];
			count++;
			if (count >= size) {
				completion = ^void() {
					if (!snapshot) {
						UIGraphicsBeginImageContextWithOptions(self.boardSKView.bounds.size, YES, 0.0f);
						[self.boardSKView drawViewHierarchyInRect:self.boardSKView.bounds afterScreenUpdates:YES];
						snapshot = UIGraphicsGetImageFromCurrentImageContext();
						UIGraphicsEndImageContext();
						
						UIColor *blurtTintColor = self.theme.tileColors[@(2048)];
						CGFloat red, green, blue, alpha;
						[blurtTintColor getRed:&red green:&green blue:&blue alpha:&alpha];
						blurtTintColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.1f];
						snapshot = [snapshot applyBlurEffectWithRadius:3.0f tintColor:blurtTintColor];
						self.pauseImageView.image = snapshot;
						
						[UIView animateWithDuration:kAnimationDuration_ScreenBlur
											  delay:0.0f
											options:UIViewAnimationOptionCurveEaseInOut
										 animations:^{
											 self.pauseView.alpha = 1.0f;
										 }
										 completion:^(BOOL finished) {
											 [self.boardSKView bringSubviewToFront:self.pauseView];
										 }];
						[self enableButtonAndGestureInteractions:YES];
					}
				};
			}
			[tile runAction:self.tileMagnifyAction completion:completion];
		}
		[self saveContext];
	} else {
		self.pauseView.alpha = 0.0f;
	}
}

// The following two methods are for updating text. When updating, the banner ads should disapear.
-(void)updateMessage: (NSString *)message {
	[_messageUpdateTimer invalidate];
	[UIView animateWithDuration:kAnimationDuration_TextFade
					 animations:^{
						 self.messageLabel.alpha = 0.0f;
					 } completion:^(BOOL finished) {
						 self.messageLabel.text = message;
						 // If we're on an 3.7" screen
						 if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone &&
							 [UIScreen mainScreen].bounds.size.height < 568) {
							 self.canDisplayBannerAds = NO;
						 }
						 [UIView animateWithDuration:kAnimationDuration_TextFade
										  animations:^{
											  self.messageLabel.alpha = 1.0f;
										  } completion:^(BOOL finished) {
											  self.messageUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:kTextShowDuration
																										 target:self
																									   selector:@selector(enableDisplayingBannerAds)
																									   userInfo:nil
																										repeats:NO];
										  }];
					 }];
}

-(void)enableDisplayingBannerAds {
	self.canDisplayBannerAds = YES;
}

@end
