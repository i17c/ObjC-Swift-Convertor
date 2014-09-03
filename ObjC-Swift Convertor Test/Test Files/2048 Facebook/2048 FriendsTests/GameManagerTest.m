//
//  GameManagerTest.m
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

@interface GameManagerTest : XCTestCase

@property (nonatomic, strong) GameManager *gManager;

@end

@implementation GameManagerTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	[GameManager initializeGameManager];
	[Board initializeNewBoard];
	[Tile initializeAllTiles];
	self.gManager = [GameManager sharedGameManager];
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

-(void)testGameManagerExists
{
	XCTAssertNotNil(self.gManager);
}

-(void)testGameManagerUnique
{
	XCTAssertEqual([[GameManager allGameManagers] count], 1);
}

-(void)testHighScoreZero
{
	XCTAssertEqual(self.gManager.bestScore, 0);
}

-(void)testMaxOccuredTimeForEachTileZero
{
	NSDictionary *maxOccuredTimeDictionary = [self.gManager getMaxOccuredDictionary];
	for (int i = 0; i < maxTilePower; ++i) {
		XCTAssertEqualObjects(maxOccuredTimeDictionary[@((NSInteger)pow(2.0f, i + 1))], @(0));
	}
}

-(void)testMaxOccuredTimeForEachTile
{
	NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@[@(2), @(4), @(2), @(8)],
														   @[@(4), @(2), @(4), @(0)],
														   @[@(8), @(8), @(32), @(32)],
														   @[@(32), @(256), @(512), @(1024)]]];
	Board *board = [Board createBoardWithBoardData:arr
									 gamePlaying:YES
										   score:0
								  swipeDirection:BoardSwipeGestureDirectionNone];
	[board swipedToDirection:BoardSwipeGestureDirectionDown];
	
	NSDictionary *maxOccuredTimeDictionary = [self.gManager getMaxOccuredDictionary];
	XCTAssertTrue([maxOccuredTimeDictionary[@(2)] intValue] == 3 || [maxOccuredTimeDictionary[@(2)] intValue] == 4);
	XCTAssertTrue([maxOccuredTimeDictionary[@(4)] intValue] == 3 || [maxOccuredTimeDictionary[@(4)] intValue] == 4);
	XCTAssertEqualObjects(maxOccuredTimeDictionary[@(8)], @(3));
	XCTAssertEqualObjects(maxOccuredTimeDictionary[@(32)], @(3));
	XCTAssertEqualObjects(maxOccuredTimeDictionary[@(256)], @(1));
	XCTAssertEqualObjects(maxOccuredTimeDictionary[@(512)], @(1));
	XCTAssertEqualObjects(maxOccuredTimeDictionary[@(1024)], @(1));
}

@end
