//
//  FetchingImagesTest.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/27/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <XCTest/XCTest.h>
#import "GameManager+ModelLayer03.h"
#import "History+ModelLayer03.h"
#import "Board+ModelLayer03.h"
#import "Tile+ModelLayer03.h"
#import "Theme.h"
#import "BoardScene.h"
#import "TileSKShapeNode.h"
#import "GameViewController.h"
#import "LoginViewController.h"

@interface FetchingImagesTest : XCTestCase

@property (strong, nonatomic) GameManager *gManager;
@property (strong, nonatomic) History *history;
@property (strong, nonatomic) Board *board;
@property (strong, nonatomic) Theme *theme;
@property (strong, nonatomic) BoardScene *scene;
@property (nonatomic) BOOL printBoard;

@end

@implementation FetchingImagesTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	self.gManager = [GameManager initializeGameManager];
	self.board = [Board initializeNewBoard];
	[Tile initializeAllTiles];
	self.theme = [Theme sharedThemeWithID:self.gManager.currentThemeID];
	self.scene = [BoardScene sceneWithSize:CGSizeMake(280, 280) andTheme:self.theme];
	self.printBoard = NO;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
	// Remove all boards:
	NSArray *arr = [Board allBoards];
	for (Board *b in arr) {
		[Board removeBoardWithUUID:b.uuid];
	}
	// Remove all histories:
	arr = [History allHistories];
	for (History *h in arr) {
		[History removeHistoryWithUUID:h.uuid];
	}
	// Remove all Game managers:
	arr = [GameManager allGameManagers];
	for (GameManager *g in arr) {
		[GameManager removeGameManagerWithUUID:g.uuid];
	}
	// Remove all Tiles:
	arr = [Tile allTiles];
	for (Tile *t in arr) {
		[Tile removeTileWithValue:t.value];
	}
}

//- (void)testFetchImageAlwaysDone {
//	NSString *storyBoardName = @"";
//	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
//		storyBoardName = @"Main_iPhone";
//	} else {
//		storyBoardName = @"Main_iPad";
//	}
//	UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyBoardName bundle:[NSBundle mainBundle]];
//	if (storyBoard) {
//		GameViewController *gameVC = [storyBoard instantiateViewControllerWithIdentifier:@"GameViewController"];
//		LoginViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//		if (gameVC && loginVC) {
//			[gameVC presentViewController:loginVC animated:NO completion:nil];
//		}
//		XCTAssertNotNil(gameVC.scene.imagesForValues);
//		XCTAssertNotNil(gameVC.scene.userIDs);
////		XCTAssertEqual([gameVC.scene.userIDs count], maxTilePower, @"There should be %lu user IDs in scene.userIDs instead of %lu.", [gameVC.scene.userIDs count], maxTilePower);
//	}
//}

@end
