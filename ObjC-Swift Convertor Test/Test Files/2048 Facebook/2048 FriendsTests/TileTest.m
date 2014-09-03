//
//  TileTest.m
//  2048 Friends
//
//  Created by Shuyang Sun on 4/7/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import "Tile+ModelLayer03.h"

@interface TileTest : XCTestCase

@end

@implementation TileTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	[Tile initializeAllTiles];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
	NSArray *arr = [Tile allTiles];
	for (Tile *t in arr) {
		[Tile removeTileWithValue:t.value];
	}
}

- (void)testInitialize
{
	for (size_t i = 1; i <= maxTilePower; ++i) {
		Tile *t = [Tile tileWithValue:(int32_t)pow(2.0f, i)];
		XCTAssertNotNil(t);
	}
}

- (void)testTileRelationships
{
	for (size_t i = 1; i <= maxTilePower; ++i) {
		Tile *t = [Tile tileWithValue:(int32_t)pow(2.0f, i)];
		if (i <= 1) {
			XCTAssertEqual(t.nextTile.value, (int32_t)pow(2.0f, i + 1));
		} else if (i >= maxTilePower) {
			XCTAssertEqual(t.previousTile.value, (int32_t)pow(2.0f, i - 1));
		} else {
			XCTAssertEqual(t.nextTile.value, (int32_t)pow(2.0f, i + 1));
			XCTAssertEqual(t.previousTile.value, (int32_t)pow(2.0f, i - 1));
		}
		
	}
}

-(void)testTileSavingImage
{
	UIImage *image = [[UIImage alloc] init];
	Tile *t = [Tile tileWithValue:2];
	t.image = image;
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	NSError *error;
	[appDelegate.managedObjectContext save:&error];
	XCTAssertNil(error); // Should not have an error
	if (error) {
		NSLog(@"%@", error);
	}
	UIImage *fetchedImage = [Tile tileWithValue:2].image;
	XCTAssertEqual(fetchedImage, image);
}

-(void)testTileText
{
	for (size_t i = 1; i <= maxTilePower; ++i) {
		Tile *t = [Tile tileWithValue:(int32_t)pow(2.0f, i)];
		NSString *temp = [NSString stringWithFormat:@"%d", t.value];
		XCTAssertEqualObjects(t.text, temp);
	}
}

@end
