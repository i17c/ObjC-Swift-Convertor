//
//  BoardTest.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/5/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GameManager+ModelLayer03.h"
#import "History+ModelLayer03.h"
#import "Board+ModelLayer03.h"
#import "Tile+ModelLayer03.h"

@interface BoardTest : XCTestCase

@property (nonatomic, strong) Board *board;
// Set this parameter to YES if want to see ASCII board info
@property (nonatomic) BOOL printBoard;

@end

@implementation BoardTest

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

-(void)testBoardExist {
	XCTAssertNotNil(self.board);
}

-(void)testBoardGamePLaying {
	XCTAssertTrue(self.board.gameplaying);
	self.board.gameplaying = NO;
	XCTAssertFalse(self.board.gameplaying);
}

-(void)testBoardScore {
	XCTAssertEqual(self.board.score, 0);
	int32_t score = 4;
	self.board.score = score;
	XCTAssertEqual(self.board.score, 4);
}

-(void)testBoardsRemoveBoard {
	NSArray *arr = [Board allBoards];
	for (Board *b in arr) {
		[Board removeBoardWithUUID:b.uuid];
	}
	arr = [Board allBoards];
	NSUInteger count = [arr count];
	XCTAssertTrue(count == 0);
}

-(void)testBoardData {
	id obj = [NSKeyedUnarchiver unarchiveObjectWithData:self.board.boardData];
	XCTAssertTrue([obj isKindOfClass:[NSArray class]]);
	NSArray *arr = obj;
	for (int i = 0; i < 4; ++i) {
		for (int j = 0; j < 4; ++j) {
			int32_t val = [arr[i][j] intValue];
			XCTAssertTrue(val == 0 || val == 2 || val == 4);
		}
		int swipeStateVal = self.board.swipeDirection;
		XCTAssertTrue(swipeStateVal >= 0 && swipeStateVal < 4);
	}
}

-(void)testBoardHistory {
	XCTAssertNotNil(self.board.boardHistory);
	XCTAssertEqual(self.board.boardHistory, [History latestHistory]);
	Board *temp = [Board initializeNewBoard];
	XCTAssertNotNil(temp.boardHistory);
	XCTAssertEqual(self.board.boardHistory, [History allHistories][[[History allHistories] count] - 2]);
	XCTAssertEqual(temp.boardHistory, [History latestHistory]);
}

-(void)testGameEnd {
	NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@[@(0), @(4), @(8), @(16)],
														   @[@(32), @(16), @(2), @(8)],
														   @[@(2), @(4), @(8), @(16)],
														   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	self.board = [self.board swipedToDirection:BoardSwipeGestureDirectionLeft];
	XCTAssertFalse(self.board.gameplaying);
}

-(void)testBoardSwipableLeft {
	NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@[@(2), @(4), @(8), @(16)],
														   @[@(32), @(16), @(2), @(8)],
														   @[@(2), @(4), @(8), @(16)],
														   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionLeft]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(2), @(4), @(0), @(0)],
										   @[@(32), @(16), @(2), @(0)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(0), @(0), @(0), @(0)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionLeft]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(2), @(2), @(8), @(16)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionLeft]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(0), @(2), @(2), @(16)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionLeft]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(2), @(2), @(2), @(16)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionLeft]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(2), @(2), @(4), @(16)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionLeft]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(4), @(2), @(16), @(16)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionLeft]);
}

-(void)testBoardSwipableRight {
	NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@[@(2), @(4), @(8), @(16)],
														   @[@(32), @(16), @(2), @(8)],
														   @[@(2), @(4), @(8), @(16)],
														   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionRight]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(0), @(0), @(8), @(2)],
										   @[@(0), @(16), @(2), @(64)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(0), @(0), @(0), @(0)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionRight]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(2), @(2), @(8), @(16)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionRight]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(16), @(2), @(2), @(0)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionRight]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(16), @(2), @(2), @(2)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionRight]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(16), @(4), @(2), @(2)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionRight]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(2), @(2), @(2), @(2)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionRight]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(16), @(16), @(4), @(2)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionRight]);
}

-(void)testBoardSwipableUp {
	NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@[@(2), @(4), @(8), @(16)],
														   @[@(32), @(16), @(2), @(8)],
														   @[@(2), @(4), @(8), @(16)],
														   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionUp]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(2), @(4), @(4), @(0)],
										   @[@(4), @(0), @(2), @(0)],
										   @[@(2), @(0), @(0), @(0)],
										   @[@(0), @(0), @(0), @(0)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionUp]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(4), @(2), @(8), @(16)],
										   @[@(32), @(2), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionUp]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(16), @(4), @(2), @(8)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(4), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionUp]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(16), @(2), @(2), @(2)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(2), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionUp]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(16), @(4), @(2), @(2)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionUp]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(2), @(4), @(2), @(4)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(2), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionUp]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(16), @(16), @(4), @(2)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionUp]);
}

-(void)testBoardSwipableDown {
	NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@[@(2), @(4), @(8), @(16)],
														   @[@(32), @(16), @(2), @(8)],
														   @[@(2), @(4), @(8), @(16)],
														   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionDown]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(0), @(0), @(2), @(0)],
										   @[@(4), @(0), @(4), @(0)],
										   @[@(2), @(4), @(2), @(0)],
										   @[@(4), @(2), @(4), @(0)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionDown]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(4), @(2), @(8), @(16)],
										   @[@(32), @(2), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionDown]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(16), @(4), @(2), @(8)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(4), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionDown]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(16), @(2), @(2), @(2)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(2), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionDown]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(16), @(4), @(2), @(2)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionDown]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(2), @(4), @(2), @(4)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(2), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionDown]);
	
	arr = [NSMutableArray arrayWithArray:@[@[@(16), @(16), @(4), @(2)],
										   @[@(32), @(16), @(2), @(8)],
										   @[@(2), @(4), @(8), @(16)],
										   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionDown]);
}

-(void)testBoardSwipableMix {
	NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@[@(2), @(4), @(8), @(16)],
														   @[@(32), @(16), @(2), @(8)],
														   @[@(2), @(4), @(8), @(16)],
														   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionLeft]);
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionRight]);
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionUp]);
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionDown]);
	
	NSMutableArray *arr2 = [NSMutableArray arrayWithArray:@[@[@(0), @(4), @(8), @(16)],
														   @[@(32), @(16), @(2), @(8)],
														   @[@(2), @(4), @(8), @(16)],
														   @[@(64), @(8), @(2), @(4)]]];
	self.board = [Board createBoardWithBoardData:arr2
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionLeft]);
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionRight]);
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionUp]);
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionDown]);
	
	NSMutableArray *arr3 = [NSMutableArray arrayWithArray:@[@[@(2), @(4), @(8), @(16)],
															@[@(32), @(16), @(2), @(8)],
															@[@(2), @(4), @(8), @(16)],
															@[@(64), @(8), @(2), @(0)]]];
	self.board = [Board createBoardWithBoardData:arr3
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionLeft]);
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionRight]);
	XCTAssertFalse([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionUp]);
	XCTAssertTrue([self.board canBeSwipedIntoDirection:BoardSwipeGestureDirectionDown]);
}

/// Swipping tests:
-(void)testSwipeBoardLeft {
	if (self.printBoard) { NSLog(@"Swipe Left Tests"); }
	Board *temp;
	// NOTE: We are always printing the previouse board!
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionLeft];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionLeft);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionLeft];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionLeft);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionLeft];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionLeft);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionLeft];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionLeft);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionLeft];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionLeft);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionLeft];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionLeft);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	
	if (self.printBoard) { [self.board printBoard]; }
}

-(void)testSwipeBoardRight {
	if (self.printBoard) { NSLog(@"Swipe Right Tests"); }
	Board *temp;
	// NOTE: We are always printing the previouse board!
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionRight];
		if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionRight);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionRight];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionRight);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionRight];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionRight);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionRight];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionRight);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionRight];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionRight);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionRight];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionRight);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	if (self.printBoard) { [self.board printBoard]; }
}

-(void)testSwipeBoardUp {
	if (self.printBoard) { NSLog(@"Swipe Up Tests"); }
	Board *temp;
	// NOTE: We are always printing the previouse board!
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionUp];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionUp);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionUp];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionUp);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionUp];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionUp);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionUp];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionUp);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionUp];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionUp);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionUp];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionUp);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);

	if (self.printBoard) { [self.board printBoard]; }
}

-(void)testSwipeBoardDown {
	if (self.printBoard) { NSLog(@"Swipe Down Tests"); }
	Board *temp;
	// NOTE: We are always printing the previouse board!
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionDown];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionDown);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionDown];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionDown);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionDown];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionDown);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionDown];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionDown);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionDown];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionDown);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionDown];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionDown);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	
	
	if (self.printBoard) { [self.board printBoard]; }
}

-(void)testSwipeBoardMix {
	if (self.printBoard) { printf("Swipe Mix Tests\n"); }
	Board *temp;
	// NOTE: We are always printing the previouse board!
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionLeft];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionLeft);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	// 3.
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionLeft];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionLeft);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	// 4
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionRight];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionRight);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	// 5
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionUp];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionUp);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	// 6
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionDown];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionDown);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	// 7
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionRight];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionRight);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	// 8.
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionLeft];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionLeft);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	// 9.
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionLeft];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionLeft);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	// 10
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionRight];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionRight);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	// 11
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionUp];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionUp);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	// 12
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionDown];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionDown);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
	// 13
	temp = [self.board swipedToDirection:BoardSwipeGestureDirectionRight];
	if (temp) {
		XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionRight);
		if (self.printBoard) { [self.board printBoard]; }
		self.board = temp;
	}
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);

	// 14
	if (self.printBoard) { [self.board printBoard]; }
	XCTAssertEqual(self.board.swipeDirection, BoardSwipeGestureDirectionNone);
}

@end
