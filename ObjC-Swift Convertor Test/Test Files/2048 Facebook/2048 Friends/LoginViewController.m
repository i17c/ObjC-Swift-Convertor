//
//  ViewController.m
//  2048 FB
//
//  Created by Shuyang Sun on 3/31/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "LoginViewController.h"
#import "Theme.h"
#import "GameManager+ModelLayer03.h"
#import "Tile+ModelLayer03.h"
#import "AppDelegate.h"
#import "macro.h"

#import "GameViewController.h"
#import "BoardScene.h"
#import "TileSKShapeNode.h"

// For localization
#define STRING_OK NSLocalizedStringFromTable(@"STRING_OK", @"ViewControllerTable", @"OK button on alert view when fetching image unsuccessful.")
#define STRING_ERROR NSLocalizedStringFromTable(@"STRING_ERROR", @"ViewControllerTable", @"Error button on alert view when fetching image unsuccessful.")

const NSTimeInterval kViewControllerDuration_Animation = SCALED_ANIMATION_DURATION(0.1f);
const NSTimeInterval kViewControllerDuration_Delay = SCALED_ANIMATION_DURATION(0.0f);
const NSTimeInterval kViewControllerDuration_SpringDamping = SCALED_ANIMATION_DURATION(0.4f);
const NSTimeInterval kViewControllerDuration_SpringVelocity = SCALED_ANIMATION_DURATION(0.6f);

@interface  LoginViewController()

@property (strong, nonatomic) UIButton *fbLoginViewButton;

// Private property to check if the user
@property (nonatomic, getter = isUserLoggedIn) BOOL userLoggedIn;

+(NSURL *)profilePictureURLFromFBUserID: (NSString *) userId;
-(void)executeFacebookFetchRequests;

/** This method is a private helper method to find the UIButton in the fbLoginView.
 *  So we can send touch events to fbLoginView programmatically.
 *  This is used for customizing our own Facebook login UI.
 *  This method will set the private "fbLoginViewButton" property as the button.
 */
-(void)findUIButtonInfbLoginView;

/**
 * Always return yes for now
 */
-(BOOL)fetchFbImages;

@end

@implementation LoginViewController

-(void)setup
{
	// Initialization code here...
	GameManager *gManager = [GameManager sharedGameManager];
	self.theme = [Theme sharedThemeWithID:gManager.currentThemeID];
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
    // Do any additional setup after loading the view.
	self.fbLoginView.readPermissions = @[@"read_friendlists", @"user_about_me", @"friends_about_me"];
	
	// Set colros
	self.view.backgroundColor = self.theme.backgroundColor;
	self.customFacebookLoginButton.backgroundColor = self.theme.boardColor;
	self.customTwitterLoginButton.backgroundColor = self.theme.boardColor;
	self.customWeiboLoginButton.backgroundColor = self.theme.boardColor;
	self.updatePictureButton.backgroundColor = self.theme.boardColor;
	
	// Set corner raidus:
	self.customFacebookLoginButton.layer.cornerRadius = self.theme.buttonCornerRadius;
	self.customTwitterLoginButton.layer.cornerRadius = self.theme.buttonCornerRadius;
	self.customWeiboLoginButton.layer.cornerRadius = self.theme.buttonCornerRadius;
	self.updatePictureButton.layer.cornerRadius = self.theme.buttonCornerRadius;
	
	self.customFacebookLoginButton.layer.masksToBounds = YES;
	self.customTwitterLoginButton.layer.masksToBounds = YES;
	self.customWeiboLoginButton.layer.masksToBounds = YES;
	self.updatePictureButton.layer.masksToBounds = YES;
	
	// Navigation bar related
	if (self.navigationController) {
		self.view.tintColor = [UIColor whiteColor];
		self.navigationItem.title = @"Log In";
		self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
	}
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.fbLoginView.delegate = self;
	// Get the pointer to the button.
	[self findUIButtonInfbLoginView];
}

-(void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Handle events when users start panning on "Introduction" page.
- (IBAction)handlePan:(UIPanGestureRecognizer *)sender {
	CGFloat viewWidth = self.view.frame.size.width;
	CGFloat maxPanLength1 = 3.0f;
	CGFloat maxPanLength2 = 2.0f;
	CGFloat newWidthAdded = 0.0f;
	if (sender.state == UIGestureRecognizerStateBegan) {
		NSArray *viewArr = [self.view subviews];
		for (UIView *v in viewArr) {
			v.translatesAutoresizingMaskIntoConstraints = NO;
		}
	} else if (sender.state == UIGestureRecognizerStateChanged) {
		if (fabs([sender translationInView:self.view].x) >  fabs([sender translationInView:self.view].y)) {
			CGFloat translationX = [sender translationInView:self.view].x;
			newWidthAdded += maxPanLength1 * MIN(1.0f, fabs(translationX)/(viewWidth/2));
			newWidthAdded += maxPanLength2 * MAX(0.0f, (fabs(translationX) - (viewWidth/2))/(viewWidth/2));
			CGAffineTransform transform = CGAffineTransformIdentity;
			if (translationX > 0) {
				transform = CGAffineTransformTranslate(CGAffineTransformIdentity, newWidthAdded, 0.0f);
			} else {
				transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -newWidthAdded * 2, 0.0f);
			}
			transform = CGAffineTransformScale(transform, 1.0f + newWidthAdded/self.customFacebookLoginButton.frame.size.width, 1.0f);
			for (UIButton *button in self.buttons) {
				button.transform = transform;
			}
		}
	} else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
		[UIView animateWithDuration:kViewControllerDuration_Animation
							  delay:kViewControllerDuration_Delay
			 usingSpringWithDamping:kViewControllerDuration_SpringDamping
			   initialSpringVelocity:kViewControllerDuration_SpringVelocity
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 for (UIButton *button in self.buttons) {
								 button.transform = CGAffineTransformIdentity;
							 }
						 }
						 completion:^(BOOL finished){
							 NSArray *viewArr = [self.view subviews];
							 for (UIView *v in viewArr) {
								 v.translatesAutoresizingMaskIntoConstraints = YES;
							 }
						 }];
	}
}

- (IBAction)customFacebookLoginButtonTouched:(UIButton *)sender {
	[self.fbLoginViewButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)updatePictureButtonTouched:(UIButton *)sender {
	[self fetchFbImages];
}

// <FBLoginViewDelegate> method
-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
	
}

// <FBLoginViewDelegate> method
-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
	
}

// <FBLoginViewDelegate> method
-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView
						   user:(id<FBGraphUser>)user {
	
	dispatch_queue_t fetchingImageQueue = dispatch_queue_create("Fetch Facebook Profile Picture Queue", NULL);
	dispatch_async(fetchingImageQueue, ^{
		// Assign user's own profile pictures to a tile.
		Tile *tile = [Tile tileWithValue:2048];
		// Get a random friend from the list:
		NSString *name = user.name;
		NSString *fbUserID = user.id;
		NSURL *profilePictureURL = [LoginViewController profilePictureURLFromFBUserID:fbUserID];
		// Get image:
		NSData *imageData = [NSData dataWithContentsOfURL:profilePictureURL];
		UIImage *profilePic = [UIImage imageWithData:imageData];
		tile.fbUserID = fbUserID;
		tile.fbUserName = name;
		tile.image = profilePic;
	});
}

// Get the pointer to UIButton in fbLoginView, so we can programmatically "touch" it.
-(void)findUIButtonInfbLoginView {
	// Code and idea from "ozba - StackOverflow"
	for (id obj in self.fbLoginView.subviews) {
		if ([obj isKindOfClass:[UIButton class]]) {
			self.fbLoginViewButton = (UIButton *)obj;
		}
	}
}

+(NSURL *)profilePictureURLFromFBUserID: (NSString *) userId {
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userId]];
}

-(BOOL)fetchFbImages {
	if (!FBSession.activeSession.isOpen) {
		// if the session is closed, then we open it here, and establish a handler for state changes
		[FBSession openActiveSessionWithReadPermissions:@[@"read_friendlists", @"user_about_me", @"friends_about_me"]
										   allowLoginUI:YES
									  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
										  if (error) {
											  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
																								  message:error.localizedDescription
																								 delegate:nil
																						cancelButtonTitle:@"OK"
																						otherButtonTitles:nil];
											  [alertView show];
										  } else if (session.isOpen) {
											  //run your user info request here
											  [self executeFacebookFetchRequests];
										  }
									  }];
	} else {
		[self executeFacebookFetchRequests];
	}
	return YES;
}

-(void)executeFacebookFetchRequests {
	NSString *graphPath = @"/me/friends";
	[FBRequestConnection startWithGraphPath:graphPath
								 parameters:nil
								 HTTPMethod:@"GET"
						  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
							  /* handle the result */
							  if (error) {
								  NSLog(@"%@", error);
							  } else {
								  NSArray* friends = [result objectForKey:@"data"];
									  // Assign profile pictures to Tiles.
									  if ([friends count] < 16) {
										  NSLog(@"Not enough facebook friends.");
										  return;
									  }
									  UIViewController *presentingViewController = self.presentingViewController;
									  GameViewController *gViewController = nil;
									  if ([presentingViewController isKindOfClass:[GameViewController class]]) {
										  gViewController = (GameViewController *)presentingViewController;
									  }
									  NSMutableSet *indSet = [NSMutableSet set];
									  NSUInteger count = 0;
									  BOOL detectFacesAndDuplicates = YES;
									  for (size_t i = 1; i <= maxTilePower; ++i) {
										  count++;
										  int ind = arc4random()%[friends count];
										  if (i != 11) { // 2048 is user's own profile picture
											  if (![indSet containsObject:@(ind)]) {
												  [indSet addObject:@(ind)];
												  Tile *tile = [Tile tileWithValue:(int32_t)pow(2.0f, i)];
												  // Get a random friend from the list:
												  NSDictionary<FBGraphUser> *friend = friends[ind++];
												  NSString *name = friend.name;
												  NSString *fbUserID = friend.id;
												  NSURL *profilePictureURL = [LoginViewController profilePictureURLFromFBUserID:fbUserID];
												  // Get image:
												  NSData *imageData = [NSData dataWithContentsOfURL:profilePictureURL];
												  UIImage *profilePic = [UIImage imageWithData:imageData];
												  // Detect if there's a face in it.
												  if (detectFacesAndDuplicates) {
													  // If the user ID already exists, use another one
													  if ([gViewController.scene.userIDs containsObject:friend.id]) {
														  i--;
														  continue;
													  }
													  CGImageRef imageRef = [profilePic CGImage];
													  CIImage *convertedCIImage = [CIImage imageWithCGImage:imageRef];
													  CIContext *context = [CIContext contextWithOptions:nil];
													  NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
													  CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
																								context:context
																								options:opts];
													  if([[convertedCIImage properties] valueForKey:(NSString *)kCGImagePropertyOrientation]) {
														  opts = @{CIDetectorImageOrientation : [[convertedCIImage properties] valueForKey:(NSString *)kCGImagePropertyOrientation]};
													  } else {
														  opts = @{CIDetectorImageOrientation :@(1)};
													  }
													  NSArray *features = [detector featuresInImage:convertedCIImage options:opts];
													  if ([features count] > 0) { // If there is a face"
														  tile.fbUserID = fbUserID;
														  tile.fbUserName = name;
														  tile.image = profilePic;
													  } else {
														  i--;
														  continue;
													  }
												  } else {
													  tile.fbUserID = fbUserID;
													  tile.fbUserName = name;
													  tile.image = profilePic;
													  
												  }
												  
												  if (count >= [friends count]) {
													  detectFacesAndDuplicates = NO;
												  }
											  } else {
												  i--;
												  continue;
											  }
											  
										  }
									  }
									  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
									  [appDelegate saveContext];
									  NSLog(@"Fetching friends pictures done.");
									  // Update profile images
									  if ([presentingViewController isKindOfClass:[GameViewController class]]) {
										  if (gViewController) {
											  [gViewController.scene updateImagesAndUserIDs];
											  for (TileSKShapeNode *node in [gViewController.scene.nodeForIndexes allValues]) {
												  [node updateImage:gViewController.scene.imagesForValues[@(node.value)] completion:nil];
											  }
											  gViewController.profilePictureImageView.image = gViewController.scene.imagesForValues[@(2048)];
										  }
									  }
							  }
						  }];
}

-(void)dealloc {
	self.fbLoginView.delegate = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
