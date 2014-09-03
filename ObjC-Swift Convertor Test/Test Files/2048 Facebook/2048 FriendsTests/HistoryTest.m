//
//  HistoryTest.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/7/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GameManager+ModelLayer03.h"
#import "History+ModelLayer03.h"
#import "Board+ModelLayer03.h"
#import "Tile+ModelLayer03.h"

@interface HistoryTest : XCTestCase

@end

@implementation HistoryTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	[GameManager initializeGameManager];
	[Board initializeNewBoard];
	[Tile initializeAllTiles];
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

-(void)testHistoryExists
{
	XCTAssertNotNil([History latestHistory]);
}

-(void)testHistoryCreatedWhenNewBoardInitialized
{
	XCTAssertEqual([[History allHistories] count], 1);
	[Board initializeNewBoard];
	__unused NSArray *arr = [History allHistories];
	XCTAssertEqual([[History allHistories] count], 2);
}

-(void)testHistoryNotCreatedWhenSwipingBoard
{
	[[Board latestBoard] swipedToDirection:BoardSwipeGestureDirectionLeft];
	XCTAssertEqual([[History allHistories] count], 1);
}

-(void)testBoardAddedToHistoryWhenNewBoardInitialized
{
	Board *board = [Board initializeNewBoard];
	XCTAssertTrue([[History latestHistory].boards containsObject:board]);
	board = [Board latestBoard];
	XCTAssertTrue([[History latestHistory].boards containsObject:board]);
}


-(void)testBoardAddedToHistoryWhenSwippingBoard
{
	Board *board = [[Board latestBoard] swipedToDirection:BoardSwipeGestureDirectionUp];
	if (board) {
		XCTAssertTrue([[History latestHistory].boards containsObject:board]);
	}
	board = [Board latestBoard];
	XCTAssertTrue([[History latestHistory].boards containsObject:board]);
}

@end
