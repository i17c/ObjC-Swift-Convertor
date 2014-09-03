//
//  GameManager+ModelLayer02.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/4/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "GameManager+ModelLayer02.h"
#import "AppDelegate.h"
#import "Tile+ModelLayer02.h"

@implementation GameManager (ModelLayer02)

+(GameManager *)createGameManagerWithBestScore: (int32_t) bestScore
								currentThemeID: (NSString *) currentThemeID
			 maxOccuredTimesOnBoardForEachTile: (NSMutableDictionary *) occurTimeDictionary {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [self createGameManagerWithBestScore:bestScore
								 currentThemeID:currentThemeID
			  maxOccuredTimesOnBoardForEachTile:occurTimeDictionary
						 inManagedObjectContext:appDelegate.managedObjectContext];
}

+(BOOL)removeGameManagerWithUUID: (NSUUID *) uuid {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [self removeGameManagerWithUUID:uuid inManagedObjectContext:appDelegate.managedObjectContext];
}

+(GameManager *) findGameManagerWithUUID: (NSUUID *) uuid {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [self findGameManagerWithUUID:uuid inManagedObjectContext:appDelegate.managedObjectContext];
}

+(NSArray *)allGameManagers {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [self allGameManagersInManagedObjectContext:appDelegate.managedObjectContext];
}

@end
