//
//  BoardSceneTests.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/21/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GameManager+ModelLayer03.h"
#import "History+ModelLayer03.h"
#import "Board+ModelLayer03.h"
#import "Tile+ModelLayer03.h"
#import "Theme.h"
#import "BoardScene.h"
#import "TileSKShapeNode.h"

@interface BoardSceneTests : XCTestCase

@property (strong, nonatomic) GameManager *gManager;
@property (strong, nonatomic) History *history;
@property (strong, nonatomic) Board *board;
@property (strong, nonatomic) Theme *theme;
@property (strong, nonatomic) BoardScene *scene;
@property (nonatomic) BOOL printBoard;

@end

@implementation BoardSceneTests

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

-(void)testInitializing {
	// Not nil
	XCTAssertNotNil(self.scene.theme);
	XCTAssertNotNil(self.scene.positionsForNodes);
	XCTAssertNotNil(self.scene.nextPositionsForNodes);
	XCTAssertNotNil(self.scene.positionForNewRandomTile);
	XCTAssertNotNil(self.scene.positionForNewNodes);
	XCTAssertNotNil(self.scene.nodeForIndexes);
	XCTAssertNotNil(self.scene.nextNodeForIndexes);
	XCTAssertNotNil(self.scene.indexForNewRandomTile);
	XCTAssertNotNil(self.scene.movingNodes);
	XCTAssertNotNil(self.scene.removingNodes);
	XCTAssertNotNil(self.scene.tileContainers);
	XCTAssertNotNil(self.scene.positionForNewNodes);
	
	XCTAssertNotNil(self.scene.gManager);
	XCTAssertNotNil(self.scene.history);
	XCTAssertNotNil(self.scene.board);
	
	// Other
	XCTAssertEqual(self.scene.score, 0);
	XCTAssertEqual(self.scene.nextDirection, 0);
	XCTAssertFalse(self.scene.gamePlaying);
}

-(void)testStartGameFromBoardModel {
	[self.scene startGameFromBoard:self.board animated:YES];
	
	// Not nil
	XCTAssertNotNil(self.scene.data);
	XCTAssertNotNil(self.scene.gManager);
	XCTAssertNotNil(self.scene.history);
	XCTAssertNotNil(self.scene.board);
	
	// Equal
	XCTAssertEqualObjects(self.scene.data, [self.board getBoardDataArray]);
	XCTAssertEqual(self.scene.score, self.board.score);
	XCTAssertEqual(self.scene.gamePlaying, self.board.gameplaying);
}

-(void)testStartGameFromBoardUI_01 {
	[self.scene startGameFromBoard:self.board animated:YES];
	
	// 16 tile containers
	XCTAssertEqual([self.scene.tileContainers count], 4);
	for (size_t i = 0; i < 4; ++i) {
		XCTAssertEqual([self.scene.tileContainers[i] count], 4);
	}
	
	// 2 tiles
	XCTAssertEqual([[self.scene.positionsForNodes allKeys] count], 2);
	XCTAssertEqual([[self.scene.nextPositionsForNodes allKeys] count], 0);
	XCTAssertEqual([[self.scene.positionForNewRandomTile allKeys] count], 0);
	XCTAssertEqual([[self.scene.nodeForIndexes allKeys] count], 2);
	XCTAssertEqual([[self.scene.nextNodeForIndexes allKeys] count], 0);
	XCTAssertEqual([[self.scene.indexForNewRandomTile allKeys] count], 0);
	
	// No next state
	XCTAssertEqual([[self.scene.positionForNewNodes	allKeys] count], 0);
	XCTAssertEqual([self.scene.movingNodes  count], 0);
	XCTAssertEqual([self.scene.removingNodes  count], 0);
}

-(void)testStartGameFromBoardUI_02 {
	self.board = [Board createBoardWithBoardData:[NSMutableArray arrayWithArray:@[@[@(2), @(4), @(8), @(16)],
																				  @[@(8), @(2), @(1048), @(16)],
																				  @[@(2), @(4), @(8), @(2048)],
																				  @[@(16), @(4), @(8), @(16)]]]
									 gamePlaying:YES
										   score:0
								  swipeDirection:0];
	[self.scene startGameFromBoard:self.board animated:YES];
	
	// 16 tile containers
	XCTAssertEqual([self.scene.tileContainers count], 4);
	for (size_t i = 0; i < 4; ++i) {
		XCTAssertEqual([self.scene.tileContainers[i] count], 4);
	}
	
	// 2 tiles
	XCTAssertEqual([[self.scene.positionsForNodes allKeys] count], 16);
	XCTAssertEqual([[self.scene.nextPositionsForNodes allKeys] count], 0);
	XCTAssertEqual([[self.scene.nodeForIndexes allKeys] count], 16);
	XCTAssertEqual([[self.scene.nextNodeForIndexes allKeys] count], 0);
	
	// No next state
	XCTAssertEqual([[self.scene.positionForNewNodes	allKeys] count], 0);
	XCTAssertEqual([self.scene.movingNodes  count], 0);
	XCTAssertEqual([self.scene.removingNodes  count], 0);
	
	// Test data:
	for (size_t row = 0; row < 4; ++row) {
		for (size_t col = 0; col < 4; ++col) {
			TileSKShapeNode *node = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]];
			XCTAssertEqual([self.scene.data[row][col] intValue], node.value);
		}
	}
	// Test UI:
	for (size_t row = 0; row < 3; ++row) {
		for (size_t col = 0; col < 3; ++col) {
			TileSKShapeNode *node1 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]];
			TileSKShapeNode *node2 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row + 1, col)]];
			XCTAssertTrue(node1.position.y > node2.position.y);
			node1 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]];
			node2 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col + 1)]];
			XCTAssertTrue(node1.position.x < node2.position.x);
		}
	}
}

-(void)testStartGameFromBoardUI_03 {
	self.board = [Board createBoardWithBoardData:[NSMutableArray arrayWithArray:@[@[@(0), @(4), @(8), @(16)],
																				  @[@(8), @(2), @(0), @(16)],
																				  @[@(0), @(4), @(8), @(2048)],
																				  @[@(16), @(4), @(8), @(0)]]]
									 gamePlaying:YES
										   score:0
								  swipeDirection:0];
	[self.scene startGameFromBoard:self.board animated:YES];
	
	for (size_t row = 0; row < 4; ++row) {
		for (size_t col = 0; col < 4; ++col) {
			if ((row == 0 && col == 0) ||
				(row == 1 && col == 2) ||
				(row == 2 && col == 0) ||
				(row == 3 && col == 3)) {
				XCTAssertNil(self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]], @"Node at (row:%lu, col:%lu) should be nil.", row, col);
			} else {
				XCTAssertNotNil(self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]], @"Node at (row:%lu, col:%lu) should NOT be nil.", row, col);
			}
		}
	}
	
	XCTAssertNil(self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(0, 0)]]);
	XCTAssertNil(self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(0, 0)]]);
}

-(void)testDataCanBeSwipped {
	self.board = [Board createBoardWithBoardData:[NSMutableArray arrayWithArray:@[@[@(2), @(4), @(8), @(16)],
																				  @[@(8), @(2), @(1048), @(16)],
																				  @[@(2), @(4), @(8), @(2048)],
																				  @[@(16), @(4), @(8), @(16)]]]
									 gamePlaying:YES
										   score:0
								  swipeDirection:0];
	[self.scene startGameFromBoard:self.board animated:YES];
	XCTAssertFalse([self.scene dataCanBeSwippedToDirection:BoardSwipeGestureDirectionLeft]);
	XCTAssertFalse([self.scene dataCanBeSwippedToDirection:BoardSwipeGestureDirectionRight]);
	XCTAssertTrue([self.scene dataCanBeSwippedToDirection:BoardSwipeGestureDirectionUp]);
	XCTAssertTrue([self.scene dataCanBeSwippedToDirection:BoardSwipeGestureDirectionDown]);
	
	self.board = [Board createBoardWithBoardData:[NSMutableArray arrayWithArray:@[@[@(0), @(0), @(0), @(2)],
																				  @[@(0), @(0), @(0), @(2)],
																				  @[@(0), @(0), @(0), @(2)],
																				  @[@(0), @(0), @(0), @(2)]]]
									 gamePlaying:YES
										   score:0
								  swipeDirection:0];
	[self.scene startGameFromBoard:self.board animated:YES];
	XCTAssertTrue([self.scene dataCanBeSwippedToDirection:BoardSwipeGestureDirectionLeft]);
	XCTAssertFalse([self.scene dataCanBeSwippedToDirection:BoardSwipeGestureDirectionRight]);
	XCTAssertTrue([self.scene dataCanBeSwippedToDirection:BoardSwipeGestureDirectionUp]);
	XCTAssertTrue([self.scene dataCanBeSwippedToDirection:BoardSwipeGestureDirectionDown]);
}

-(void)testAnalyzeSwiping_01_Left {
	self.board = [Board createBoardWithBoardData:[NSMutableArray arrayWithArray:@[@[@(0), @(0), @(0), @(2)],
																				  @[@(0), @(0), @(0), @(2)],
																				  @[@(0), @(0), @(0), @(2)],
																				  @[@(0), @(0), @(0), @(2)]]]
									 gamePlaying:YES
										   score:0
								  swipeDirection:0];
	[self.scene startGameFromBoard:self.board animated:YES];
	
	// Before analyzing swipe
	XCTAssertEqual([[self.scene.positionsForNodes allKeys] count], 4, @"positionsForNodes should have %d keys, instead it has %lu keys.", 4, (unsigned long)[[self.scene.positionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nodeForIndexes allKeys] count], 4, @"nodeForIndexes should have %d keys, instead it has %lu keys.", 4, (unsigned long)[[self.scene.nodeForIndexes allKeys] count]);
	
	// Analyze the swipe, also print out the time used to analyze
	NSDate *start = [NSDate date];
	[self.scene analyzeTilesForSwipeDirection:BoardSwipeGestureDirectionLeft completion:nil];
	NSDate *end = [NSDate date];
	NSLog(@"testAnalyzeSwiping_01_Left: analyzing took %f seconds", [end timeIntervalSinceDate:start]);
	
	// After analyzing swipe
	XCTAssertEqual([[self.scene.nextPositionsForNodes allKeys] count], 4, @"nextPositionsForNodes should have %d keys, instead it has %lu keys.", 4, (unsigned long)[[self.scene.nextPositionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.positionForNewNodes allKeys] count], 0, @"positionForNewNodes should have %d keys, instead it has %lu keys.", 0, (unsigned long)[[self.scene.positionForNewNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nextNodeForIndexes allKeys] count], 4, @"nextNodeForIndexes should have %d keys, instead it has %lu keys.", 4, (unsigned long)[[self.scene.nextNodeForIndexes allKeys] count]);
	XCTAssertEqual([self.scene.movingNodes count], 4, @"movingNodes should have %d elements, instead it has %lu elements.", 4, (unsigned long)[self.scene.movingNodes count]);
	XCTAssertEqual([self.scene.removingNodes count], 0, @"removingNodes should have %d elements, instead it has %lu elements.", 0, (unsigned long)[self.scene.removingNodes count]);
	
	NSMutableArray *theNewData = [NSMutableArray arrayWithArray:@[@[@(2), @(0), @(0), @(0)],
																  @[@(2), @(0), @(0), @(0)],
																  @[@(2), @(0), @(0), @(0)],
																  @[@(2), @(0), @(0), @(0)]]];
	XCTAssertEqualObjects(self.scene.nextData, theNewData);
	for (size_t row = 0; row < 4; ++row) {
		for (size_t col = 0; col < 4; ++col) {
			int val = [self.scene.nextData[row][col] intValue];
			if (val == 0) {
				XCTAssertNil(self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]]);
			} else {
				TileSKShapeNode *node = self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]];
				XCTAssertEqual(node.value, val);
				XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:row andCol:col]]);
				XCTAssertTrue([self.scene.movingNodes containsObject:node]);
			}
		}
	}
	
}

-(void)testAnalyzeSwiping_02_Left {
	self.board = [Board createBoardWithBoardData:[NSMutableArray arrayWithArray:@[@[@(0), @(0), @(2), @(0)],
																				  @[@(0), @(2), @(0), @(0)],
																				  @[@(2), @(0), @(0), @(0)],
																				  @[@(0), @(0), @(0), @(2)]]]
									 gamePlaying:YES
										   score:0
								  swipeDirection:0];
	[self.scene startGameFromBoard:self.board animated:YES];
	
	// Before analyzing swipe
	XCTAssertEqual([[self.scene.positionsForNodes allKeys] count], 4, @"positionsForNodes should have %d keys, instead it has %lu keys.", 4, (unsigned long)[[self.scene.positionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nodeForIndexes allKeys] count], 4, @"nodeForIndexes should have %d keys, instead it has %lu keys.", 4, (unsigned long)[[self.scene.nodeForIndexes allKeys] count]);
	
	// Analyze the swipe, also print out the time used to analyze
	NSDate *start = [NSDate date];
	[self.scene analyzeTilesForSwipeDirection:BoardSwipeGestureDirectionLeft completion:nil];
	NSDate *end = [NSDate date];
	NSLog(@"testAnalyzeSwiping_02_Left: analyzing took %f seconds", [end timeIntervalSinceDate:start]);
	
	// After analyzing swipe
	XCTAssertEqual([[self.scene.nextPositionsForNodes allKeys] count], 4, @"nextPositionsForNodes should have %d keys, instead it has %lu keys.", 4, (unsigned long)[[self.scene.nextPositionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.positionForNewNodes allKeys] count], 0, @"positionForNewNodes should have %d keys, instead it has %lu keys.", 0, (unsigned long)[[self.scene.positionForNewNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nextNodeForIndexes allKeys] count], 4, @"nextNodeForIndexes should have %d keys, instead it has %lu keys.", 4, (unsigned long)[[self.scene.nextNodeForIndexes allKeys] count]);
	XCTAssertEqual([self.scene.movingNodes count], 3, @"movingNodes should have %d elements, instead it has %lu elements.", 3, (unsigned long)[self.scene.movingNodes count]);
	XCTAssertEqual([self.scene.removingNodes count], 0, @"removingNodes should have %d elements, instead it has %lu elements.", 0, (unsigned long)[self.scene.removingNodes count]);
	
	NSMutableArray *theNewData = [NSMutableArray arrayWithArray:@[@[@(2), @(0), @(0), @(0)],
																  @[@(2), @(0), @(0), @(0)],
																  @[@(2), @(0), @(0), @(0)],
																  @[@(2), @(0), @(0), @(0)]]];
	XCTAssertEqualObjects(self.scene.nextData, theNewData);
	for (size_t row = 0; row < 4; ++row) {
		for (size_t col = 0; col < 4; ++col) {
			int val = [self.scene.nextData[row][col] intValue];
			if (val == 0) {
				XCTAssertNil(self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]]);
			} else if (row != 2 && col != 0) {
				TileSKShapeNode *node = self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]];
				XCTAssertEqual(node.value, val);
				XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:row andCol:col]]);
				XCTAssertTrue([self.scene.movingNodes containsObject:node]);
			}
		}
	}
	
}

-(void)testAnalyzeSwiping_03_Left {
	self.board = [Board createBoardWithBoardData:[NSMutableArray arrayWithArray:@[@[@(0), @(0), @(0), @(0)],
																				  @[@(0), @(0), @(0), @(0)],
																				  @[@(0), @(0), @(0), @(0)],
																				  @[@(0), @(0), @(2), @(2)]]]
									 gamePlaying:YES
										   score:0
								  swipeDirection:0];
	[self.scene startGameFromBoard:self.board animated:YES];
	
	// Before analyzing swipe
	XCTAssertEqual([[self.scene.positionsForNodes allKeys] count], 2, @"positionsForNodes should have %d keys, instead it has %lu keys.", 2, (unsigned long)[[self.scene.positionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nodeForIndexes allKeys] count], 2, @"nodeForIndexes should have %d keys, instead it has %lu keys.", 2, (unsigned long)[[self.scene.nodeForIndexes allKeys] count]);
	TileSKShapeNode *node1 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(3, 2)]];
	TileSKShapeNode *node2 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(3, 3)]];
	
	// Test positionsForNodes is correct (not including the new tiles)
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node1]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:2]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node2]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:3]]);
	
	// Analyze the swipe, also print out the time used to analyze
	NSDate *start = [NSDate date];
	[self.scene analyzeTilesForSwipeDirection:BoardSwipeGestureDirectionLeft completion:nil];
	NSDate *end = [NSDate date];
	NSLog(@"testAnalyzeSwiping_03_Left: analyzing took %f seconds", [end timeIntervalSinceDate:start]);
	
	// After analyzing swipe
	XCTAssertEqual([[self.scene.nextPositionsForNodes allKeys] count], 2, @"nextPositionsForNodes should have %d keys, instead it has %lu keys.", 2, (unsigned long)[[self.scene.nextPositionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.positionForNewNodes allKeys] count], 1, @"positionForNewNodes should have %d keys, instead it has %lu keys.", 1, (unsigned long)[[self.scene.positionForNewNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nextNodeForIndexes allKeys] count], 1, @"nextNodeForIndexes should have %d keys, instead it has %lu keys.", 1, (unsigned long)[[self.scene.nextNodeForIndexes allKeys] count]);
	XCTAssertEqual([self.scene.movingNodes count], 2, @"movingNodes should have %d elements, instead it has %lu elements.", 2, (unsigned long)[self.scene.movingNodes count]);
	XCTAssertEqual([self.scene.removingNodes count], 2, @"removingNodes should have %d elements, instead it has %lu elements.", 2, (unsigned long)[self.scene.removingNodes count]);
	
	// Test the array is calculated correctly
	NSMutableArray *theNewData = [NSMutableArray arrayWithArray:@[@[@(0), @(0), @(0), @(0)],
																  @[@(0), @(0), @(0), @(0)],
																  @[@(0), @(0), @(0), @(0)],
																  @[@(4), @(0), @(0), @(0)]]];
	XCTAssertEqualObjects(self.scene.nextData, theNewData);
	
	// Test nextPositionForNodes is correct (not including the new tiles)
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node1]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:0]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node2]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:0]]);
	
	// Test positionForNewNodes is correct
	for (size_t row = 0; row < 4; ++row) {
		for (size_t col = 0; col < 4; ++col) {
			int val = [self.scene.nextData[row][col] intValue];
			if (val == 0) {
				XCTAssertNil(self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]]);
			} else {
				TileSKShapeNode *node = self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]];
				XCTAssertEqual(node.value, val);
				XCTAssertNotNil(self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]]);
				XCTAssertEqualObjects(self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:row andCol:col]],
									  @"position in nextPositionsForNodes should be (%.0f, %.0f) instead of (%.0f, %.0f)",
									  [self.scene getPositionFromRow:row andCol:col].x,[self.scene getPositionFromRow:row andCol:col].y,
									  [self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]] CGPointValue].x, [self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node]] CGPointValue].y);
			}
		}
	}
	
}

-(void)testAnalyzeSwiping_04_Left {
	self.board = [Board createBoardWithBoardData:[NSMutableArray arrayWithArray:@[@[@(0), @(0), @(0), @(0)],
																				  @[@(0), @(0), @(0), @(0)],
																				  @[@(4), @(2), @(0), @(0)],
																				  @[@(0), @(2), @(2), @(2)]]]
									 gamePlaying:YES
										   score:0
								  swipeDirection:0];
	[self.scene startGameFromBoard:self.board animated:YES];
	
	// Before analyzing swipe
	XCTAssertEqual([[self.scene.positionsForNodes allKeys] count], 5, @"positionsForNodes should have %d keys, instead it has %lu keys.", 5, (unsigned long)[[self.scene.positionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nodeForIndexes allKeys] count], 5, @"nodeForIndexes should have %d keys, instead it has %lu keys.", 5, (unsigned long)[[self.scene.nodeForIndexes allKeys] count]);
	TileSKShapeNode *node1 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(3, 3)]];
	TileSKShapeNode *node2 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(3, 2)]];
	TileSKShapeNode *node3 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(3, 1)]];
	TileSKShapeNode *node4 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(2, 1)]];
	TileSKShapeNode *node5 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(2, 0)]];
	
	// Test positionsForNodes is correct (not including the new tiles)
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node1]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:3]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node2]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:2]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node3]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:1]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node4]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:1]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node5]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:0]]);
	
	// Analyze the swipe, also print out the time used to analyze
	NSDate *start = [NSDate date];
	[self.scene analyzeTilesForSwipeDirection:BoardSwipeGestureDirectionLeft completion:nil];
	NSDate *end = [NSDate date];
	NSLog(@"testAnalyzeSwiping_04_Left: analyzing took %f seconds", [end timeIntervalSinceDate:start]);
	
	// After analyzing swipe
	XCTAssertEqual([[self.scene.nextPositionsForNodes allKeys] count], 5, @"nextPositionsForNodes should have %d keys, instead it has %lu keys.", 5, (unsigned long)[[self.scene.nextPositionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.positionForNewNodes allKeys] count], 1, @"positionForNewNodes should have %d keys, instead it has %lu keys.", 1, (unsigned long)[[self.scene.positionForNewNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nextNodeForIndexes allKeys] count], 4, @"nextNodeForIndexes should have %d keys, instead it has %lu keys.", 4, (unsigned long)[[self.scene.nextNodeForIndexes allKeys] count]);
	XCTAssertEqual([self.scene.movingNodes count], 3, @"movingNodes should have %d elements, instead it has %lu elements.", 3, (unsigned long)[self.scene.movingNodes count]);
	XCTAssertEqual([self.scene.removingNodes count], 2, @"removingNodes should have %d elements, instead it has %lu elements.", 2, (unsigned long)[self.scene.removingNodes count]);
	
	// Test the array is calculated correctly
	NSMutableArray *theNewData = [NSMutableArray arrayWithArray:@[@[@(0), @(0), @(0), @(0)],
																  @[@(0), @(0), @(0), @(0)],
																  @[@(4), @(2), @(0), @(0)],
																  @[@(4), @(2), @(0), @(0)]]];
	XCTAssertEqualObjects(self.scene.nextData, theNewData);
	
	// Test nextPositionForNodes is correct (not including the new tiles)
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node1]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:1]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node2]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:0]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node3]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:0]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node4]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:1]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node5]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:0]]);
	
	// Test positionForNewNodes is correct
	for (size_t row = 0; row < 4; ++row) {
		for (size_t col = 0; col < 4; ++col) {
			int val = [self.scene.nextData[row][col] intValue];
			if (val != 0) {
				if (row == 3 && col == 3) {
					TileSKShapeNode *node = self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]];
					XCTAssertEqual(node.value, val);
					XCTAssertNotNil(self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]]);
					XCTAssertEqualObjects(self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:row andCol:col]],
										  @"position in nextPositionsForNodes should be (%.0f, %.0f) instead of (%.0f, %.0f)",
										  [self.scene getPositionFromRow:row andCol:col].x,[self.scene getPositionFromRow:row andCol:col].y,
										  [self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]] CGPointValue].x, [self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node]] CGPointValue].y);
				}
			} else {
				XCTAssertNil(self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]]);
			}
		}
	}
	
}

-(void)testAnalyzeSwiping_05_Left {
	self.board = [Board createBoardWithBoardData:[NSMutableArray arrayWithArray:@[@[@(0), @(0), @(0), @(0)],
																				  @[@(0), @(0), @(0), @(0)],
																				  @[@(16), @(4), @(0), @(0)],
																				  @[@(0), @(4), @(4), @(8)]]]
									 gamePlaying:YES
										   score:0
								  swipeDirection:0];
	[self.scene startGameFromBoard:self.board animated:YES];
	
	// Before analyzing swipe
	XCTAssertEqual([[self.scene.positionsForNodes allKeys] count], 5, @"positionsForNodes should have %d keys, instead it has %lu keys.", 5, (unsigned long)[[self.scene.positionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nodeForIndexes allKeys] count], 5, @"nodeForIndexes should have %d keys, instead it has %lu keys.", 5, (unsigned long)[[self.scene.nodeForIndexes allKeys] count]);
	TileSKShapeNode *node1 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(3, 3)]];
	TileSKShapeNode *node2 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(3, 2)]];
	TileSKShapeNode *node3 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(3, 1)]];
	TileSKShapeNode *node4 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(2, 1)]];
	TileSKShapeNode *node5 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(2, 0)]];
	
	// Test positionsForNodes is correct (not including the new tiles)
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node1]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:3]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node2]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:2]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node3]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:1]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node4]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:1]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node5]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:0]]);
	
	// Analyze the swipe, also print out the time used to analyze
	NSDate *start = [NSDate date];
	[self.scene analyzeTilesForSwipeDirection:BoardSwipeGestureDirectionLeft completion:nil];
	NSDate *end = [NSDate date];
	NSLog(@"testAnalyzeSwiping_05_Left: analyzing took %f seconds", [end timeIntervalSinceDate:start]);
	
	// After analyzing swipe
	XCTAssertEqual([[self.scene.nextPositionsForNodes allKeys] count], 5, @"nextPositionsForNodes should have %d keys, instead it has %lu keys.", 5, (unsigned long)[[self.scene.nextPositionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.positionForNewNodes allKeys] count], 1, @"positionForNewNodes should have %d keys, instead it has %lu keys.", 1, (unsigned long)[[self.scene.positionForNewNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nextNodeForIndexes allKeys] count], 4, @"nextNodeForIndexes should have %d keys, instead it has %lu keys.", 4, (unsigned long)[[self.scene.nextNodeForIndexes allKeys] count]);
	XCTAssertEqual([self.scene.movingNodes count], 3, @"movingNodes should have %d elements, instead it has %lu elements.", 3, (unsigned long)[self.scene.movingNodes count]);
	XCTAssertEqual([self.scene.removingNodes count], 2, @"removingNodes should have %d elements, instead it has %lu elements.", 2, (unsigned long)[self.scene.removingNodes count]);
	
	// Test the array is calculated correctly
	NSMutableArray *theNewData = [NSMutableArray arrayWithArray:@[@[@(0), @(0), @(0), @(0)],
																  @[@(0), @(0), @(0), @(0)],
																  @[@(16), @(4), @(0), @(0)],
																  @[@(8), @(8), @(0), @(0)]]];
	XCTAssertEqualObjects(self.scene.nextData, theNewData);
	
	// Test nextPositionForNodes is correct (not including the new tiles)
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node1]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:1]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node2]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:0]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node3]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:0]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node4]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:1]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node5]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:0]]);
	
	// Test positionForNewNodes is correct
	for (size_t row = 0; row < 4; ++row) {
		for (size_t col = 0; col < 4; ++col) {
			int val = [self.scene.nextData[row][col] intValue];
			if (val != 0) {
				if (row == 3 && col == 3) {
					TileSKShapeNode *node = self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]];
					XCTAssertEqual(node.value, val);
					XCTAssertNotNil(self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]]);
					XCTAssertEqualObjects(self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:row andCol:col]],
										  @"position in nextPositionsForNodes should be (%.0f, %.0f) instead of (%.0f, %.0f)",
										  [self.scene getPositionFromRow:row andCol:col].x,[self.scene getPositionFromRow:row andCol:col].y,
										  [self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]] CGPointValue].x, [self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node]] CGPointValue].y);
				}
			} else {
				XCTAssertNil(self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]]);
			}
		}
	}
	
}

-(void)testAnalyzeSwiping_06_Left {
	self.board = [Board createBoardWithBoardData:[NSMutableArray arrayWithArray:@[@[@(2), @(2), @(2), @(2)],
																				  @[@(4), @(0), @(4), @(0)],
																				  @[@(16), @(4), @(4), @(16)],
																				  @[@(0), @(4), @(4), @(8)]]]
									 gamePlaying:YES
										   score:0
								  swipeDirection:0];
	[self.scene startGameFromBoard:self.board animated:YES];
	
	// Before analyzing swipe
	XCTAssertEqual([[self.scene.positionsForNodes allKeys] count], 13, @"positionsForNodes should have %d keys, instead it has %lu keys.", 13, (unsigned long)[[self.scene.positionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nodeForIndexes allKeys] count], 13, @"nodeForIndexes should have %d keys, instead it has %lu keys.", 13, (unsigned long)[[self.scene.nodeForIndexes allKeys] count]);
	TileSKShapeNode *node1 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
	TileSKShapeNode *node2 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(0, 1)]];
	TileSKShapeNode *node3 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(0, 2)]];
	TileSKShapeNode *node4 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(0, 3)]];
	TileSKShapeNode *node5 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(1, 0)]];
	TileSKShapeNode *node6 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(1, 2)]];
	TileSKShapeNode *node7 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(2, 0)]];
	TileSKShapeNode *node8 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(2, 1)]];
	TileSKShapeNode *node9 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(2, 2)]];
	TileSKShapeNode *node10 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(2, 3)]];
	TileSKShapeNode *node11 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(3, 1)]];
	TileSKShapeNode *node12 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(3, 2)]];
	TileSKShapeNode *node13 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(3, 3)]];
	
	// Test positionsForNodes is correct (not including the new tiles)
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node1]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:0 andCol:0]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node2]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:0 andCol:1]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node3]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:0 andCol:2]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node4]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:0 andCol:3]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node5]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:1 andCol:0]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node6]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:1 andCol:2]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node7]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:0]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node8]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:1]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node9]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:2]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node10]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:3]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node11]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:1]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node12]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:2]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node13]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:3]]);
	
	// Analyze the swipe, also print out the time used to analyze
	NSDate *start = [NSDate date];
	[self.scene analyzeTilesForSwipeDirection:BoardSwipeGestureDirectionLeft completion:nil];
	NSDate *end = [NSDate date];
	NSLog(@"testAnalyzeSwiping_06_Left: analyzing took %f seconds", [end timeIntervalSinceDate:start]);
	
	// After analyzing swipe
	XCTAssertEqual([[self.scene.nextPositionsForNodes allKeys] count], 13, @"nextPositionsForNodes should have %d keys, instead it has %lu keys.", 13, (unsigned long)[[self.scene.nextPositionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.positionForNewNodes allKeys] count], 5, @"positionForNewNodes should have %d keys, instead it has %lu keys.", 5, (unsigned long)[[self.scene.positionForNewNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nextNodeForIndexes allKeys] count], 8, @"nextNodeForIndexes should have %d keys, instead it has %lu keys.", 8, (unsigned long)[[self.scene.nextNodeForIndexes allKeys] count]);
	XCTAssertEqual([self.scene.movingNodes count], 9, @"movingNodes should have %d elements, instead it has %lu elements.", 9, (unsigned long)[self.scene.movingNodes count]);
	XCTAssertEqual([self.scene.removingNodes count], 10, @"removingNodes should have %d elements, instead it has %lu elements.", 10, (unsigned long)[self.scene.removingNodes count]);
	
	// Test the array is calculated correctly
	NSMutableArray *theNewData = [NSMutableArray arrayWithArray:@[@[@(4), @(4), @(0), @(0)],
																  @[@(8), @(0), @(0), @(0)],
																  @[@(16), @(8), @(16), @(0)],
																  @[@(8), @(8), @(0), @(0)]]];
	XCTAssertEqualObjects(self.scene.nextData, theNewData);
	
	// Test nextPositionForNodes is correct (not including the new tiles)
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node1]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:0 andCol:0]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node2]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:0 andCol:0]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node3]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:0 andCol:1]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node4]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:0 andCol:1]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node5]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:1 andCol:0]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node6]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:1 andCol:0]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node7]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:0]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node8]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:1]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node9]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:1]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node10]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:2]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node11]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:0]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node12]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:0]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node13]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:1]]);
	
	
	// Test positionForNewNodes is correct
	for (size_t row = 0; row < 4; ++row) {
		for (size_t col = 0; col < 4; ++col) {
			int val = [self.scene.nextData[row][col] intValue];
			if (val != 0) {
				if (row == 3 && col == 3) {
					TileSKShapeNode *node = self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]];
					XCTAssertEqual(node.value, val);
					XCTAssertNotNil(self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]]);
					XCTAssertEqualObjects(self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:row andCol:col]],
										  @"position in nextPositionsForNodes should be (%.0f, %.0f) instead of (%.0f, %.0f)",
										  [self.scene getPositionFromRow:row andCol:col].x,[self.scene getPositionFromRow:row andCol:col].y,
										  [self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]] CGPointValue].x, [self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node]] CGPointValue].y);
				}
			} else {
				XCTAssertNil(self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]]);
			}
		}
	}
	
}

-(void)testAnalyzeSwiping_01_Down {
	self.board = [Board createBoardWithBoardData:[NSMutableArray arrayWithArray:@[@[@(0), @(0), @(0), @(0)],
																				  @[@(0), @(2), @(0), @(0)],
																				  @[@(0), @(2), @(0), @(0)],
																				  @[@(0), @(0), @(0), @(0)]]]
									 gamePlaying:YES
										   score:0
								  swipeDirection:0];
	[self.scene startGameFromBoard:self.board animated:YES];
	
	// Before analyzing swipe
	XCTAssertEqual([[self.scene.positionsForNodes allKeys] count], 2, @"positionsForNodes should have %d keys, instead it has %lu keys.", 2, (unsigned long)[[self.scene.positionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nodeForIndexes allKeys] count], 2, @"nodeForIndexes should have %d keys, instead it has %lu keys.", 2, (unsigned long)[[self.scene.nodeForIndexes allKeys] count]);
	TileSKShapeNode *node1 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(1, 1)]];
	TileSKShapeNode *node2 = self.scene.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(2, 1)]];
	
	// Test positionsForNodes is correct (not including the new tiles)
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node1]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:1 andCol:1]]);
	XCTAssertEqualObjects(self.scene.positionsForNodes[[NSValue valueWithNonretainedObject:node2]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:2 andCol:1]]);
	
	// Analyze the swipe, also print out the time used to analyze
	NSDate *start = [NSDate date];
	[self.scene analyzeTilesForSwipeDirection:BoardSwipeGestureDirectionDown completion:nil];
	NSDate *end = [NSDate date];
	NSLog(@"testAnalyzeSwiping_01_Down: analyzing took %f seconds", [end timeIntervalSinceDate:start]);
	
	// After analyzing swipe
	XCTAssertEqual([[self.scene.nextPositionsForNodes allKeys] count], 2, @"nextPositionsForNodes should have %d keys, instead it has %lu keys.", 2, (unsigned long)[[self.scene.nextPositionsForNodes allKeys] count]);
	XCTAssertEqual([[self.scene.positionForNewNodes allKeys] count], 1, @"positionForNewNodes should have %d keys, instead it has %lu keys.", 1, (unsigned long)[[self.scene.positionForNewNodes allKeys] count]);
	XCTAssertEqual([[self.scene.nextNodeForIndexes allKeys] count], 1, @"nextNodeForIndexes should have %d keys, instead it has %lu keys.", 1, (unsigned long)[[self.scene.nextNodeForIndexes allKeys] count]);
	XCTAssertEqual([self.scene.movingNodes count], 2, @"movingNodes should have %d elements, instead it has %lu elements.", 2, (unsigned long)[self.scene.movingNodes count]);
	XCTAssertEqual([self.scene.removingNodes count], 2, @"removingNodes should have %d elements, instead it has %lu elements.", 2, (unsigned long)[self.scene.removingNodes count]);
	
	// Test the array is calculated correctly
	NSMutableArray *theNewData = [NSMutableArray arrayWithArray:@[@[@(0), @(0), @(0), @(0)],
																  @[@(0), @(0), @(0), @(0)],
																  @[@(0), @(0), @(0), @(0)],
																  @[@(0), @(4), @(0), @(0)]]];
	XCTAssertEqualObjects(self.scene.nextData, theNewData);
	
	// Test nextPositionForNodes is correct (not including the new tiles)
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node1]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:1]]);
	XCTAssertEqualObjects(self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node2]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:3 andCol:1]]);
	
	// Test positionForNewNodes is correct
	for (size_t row = 0; row < 4; ++row) {
		for (size_t col = 0; col < 4; ++col) {
			int val = [self.scene.nextData[row][col] intValue];
			if (val == 0) {
				XCTAssertNil(self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]]);
			} else {
				TileSKShapeNode *node = self.scene.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]];
				XCTAssertEqual(node.value, val);
				XCTAssertNotNil(self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]]);
				XCTAssertEqualObjects(self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]], [NSValue valueWithCGPoint:[self.scene getPositionFromRow:row andCol:col]],
									  @"position in nextPositionsForNodes should be (%.0f, %.0f) instead of (%.0f, %.0f)",
									  [self.scene getPositionFromRow:row andCol:col].x,[self.scene getPositionFromRow:row andCol:col].y,
									  [self.scene.positionForNewNodes[[NSValue valueWithNonretainedObject:node]] CGPointValue].x, [self.scene.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node]] CGPointValue].y);
			}
		}
	}
	
}

@end
