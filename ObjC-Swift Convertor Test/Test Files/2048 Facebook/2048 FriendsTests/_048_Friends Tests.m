//
//  _048_FBTests.m
//  2048 FBTests
//
//  Created by Shuyang Sun on 3/31/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GameManager+ModelLayer03.h"
#import "History+ModelLayer03.h"
#import "Board+ModelLayer03.h"
#import "Tile+ModelLayer03.h"

@interface _048_FriendsTests : XCTestCase

@property (nonatomic, strong) Board *board;
// Set this parameter to YES if want to see ASCII board info
@property (nonatomic) BOOL printBoard;

@end

@implementation _048_FriendsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	[GameManager initializeGameManager];
	[Board initializeNewBoard];
	[Tile initializeAllTiles];
	self.board = [[Board allBoards] lastObject];
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

-(void)testInitState
{
	XCTAssertNotNil([GameManager sharedGameManager]);
	XCTAssertNotNil([History latestHistory]);
	XCTAssertNotNil([Board latestBoard]);
	for (size_t i = 1; i <= maxTilePower; ++i) {
		XCTAssertNotNil([Tile tileWithValue:(int16_t)pow(2.0f, i)]);
	}
}

@end
