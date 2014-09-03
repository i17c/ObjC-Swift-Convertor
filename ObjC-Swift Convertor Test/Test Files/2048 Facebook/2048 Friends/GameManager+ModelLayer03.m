//
//  GameManager+ModelLayer03.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/4/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "GameManager+ModelLayer03.h"
#import "History+ModelLayer03.h"
#import "Board+ModelLayer03.h"
#import "Tile+ModelLayer03.h"
#import "AppDelegate.h"
#import "Theme.h"

@implementation GameManager (ModelLayer03)

+(GameManager *) initializeGameManager {
	GameManager *gManager = nil;
	// If there is not a game manager in data base:
	if ([[GameManager allGameManagers] count] <= 0) {
		NSMutableDictionary *maxOccuredDictionary = [NSMutableDictionary dictionary];
		for (int i = 0; i < maxTilePower; ++i) {
			maxOccuredDictionary[@((NSInteger)pow(2.0f, i + 1))] = @(0);
		}
		gManager = [GameManager createGameManagerWithBestScore:0
															 currentThemeID:kThemeID_Default
										  maxOccuredTimesOnBoardForEachTile:maxOccuredDictionary];
	}
	
	return gManager;
}

+(GameManager *) sharedGameManager {
	GameManager *gManager = [[self allGameManagers] lastObject];
	if (!gManager) {
		gManager = [GameManager initializeGameManager];
	}
	return gManager;
}

-(NSDictionary *) getMaxOccuredDictionary {
	return [NSKeyedUnarchiver unarchiveObjectWithData:self.maxOccuredTimesOnBoardForEachTile];
}

-(BOOL) setMaxOccuredDictionary:(NSDictionary *)dictionary {
	NSData *dictionaryData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
	self.maxOccuredTimesOnBoardForEachTile = dictionaryData;
	return YES;
}

-(NSUInteger) getMaxOccuredTimeForTileWithValue: (NSInteger) value {
	NSData *dictionaryData = self.maxOccuredTimesOnBoardForEachTile;
	NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:dictionaryData];
	return [(NSNumber *)dictionary[@(value)] unsignedIntegerValue];
}

-(BOOL) setMaxOccuredTime: (NSUInteger) count ForTileWithValue: (NSInteger) value {
	NSData *dictionaryData = self.maxOccuredTimesOnBoardForEachTile;
	NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:dictionaryData];
	NSMutableDictionary *mutableDictionary = [dictionary mutableCopy];
	mutableDictionary[@(value)] = @(count);
	NSData *resultDictionaryData = [NSKeyedArchiver archivedDataWithRootObject:[mutableDictionary copy]];
	self.maxOccuredTimesOnBoardForEachTile = resultDictionaryData;
	
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [appDelegate saveContext];
}

@end
