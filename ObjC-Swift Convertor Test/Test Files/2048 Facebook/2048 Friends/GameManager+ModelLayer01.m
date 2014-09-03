//
//  GameManager+ModelLayer01.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/3/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "GameManager+ModelLayer01.h"
#import "macro.h"
#import "TileView.h"

NSString *const kCoreDataEntityName_GameManager = @"GameManager";

@implementation GameManager (ModelLayer01)

+(GameManager *)createGameManagerWithBestScore: (int32_t) bestScore
								currentThemeID: (NSString *) currentThemeID
			 maxOccuredTimesOnBoardForEachTile: (NSMutableDictionary *) occurTimeDictionary
						inManagedObjectContext: (NSManagedObjectContext *) context {
	
	GameManager *gManager = nil;
	gManager.tileViewType = TileViewTypeImage;
	gManager = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataEntityName_GameManager inManagedObjectContext:context];

	gManager.uuid = [NSUUID UUID];
	gManager.bestScore = bestScore;
	gManager.currentThemeID = currentThemeID;
	gManager.maxOccuredTimesOnBoardForEachTile = [NSKeyedArchiver archivedDataWithRootObject:occurTimeDictionary];
	
	return gManager;
}

+(BOOL)removeGameManagerWithUUID: (NSUUID *) uuid inManagedObjectContext: (NSManagedObjectContext *) context {
	// Check if the board already exists
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: (NSString *)kCoreDataEntityName_GameManager];
	request.predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
	NSError *error;
	NSArray *matches = [context executeFetchRequest:request error:&error];
	
	if (error) { // If there is an error:
		NSLog(@"%@", error);
	} else if ([matches count] > 1) {
		NSLog(@"There are %lu duplicated game managers with uuid \"%@\" in CoreData database.", (unsigned long)[matches count], uuid);
	} else if ([matches count] == 1) {
		[context deleteObject:[matches lastObject]];
	} else { // If there is nothing,
		NSLog(@"There isn't game manager with uuid \"%@\" in CoreData database.", uuid);
	}
	
	return YES;
}

+(GameManager *) findGameManagerWithUUID: (NSUUID *) uuid inManagedObjectContext: (NSManagedObjectContext *)context {
	GameManager *gManager = nil;
	
	// Check if the board already exists
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: (NSString *)kCoreDataEntityName_GameManager];
	request.predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
	NSError *error;
	NSArray *matches = [context executeFetchRequest:request error:&error];
	
	if (error) { // If there is an error:
		NSLog(@"%@", error);
	} else if ([matches count] > 1) {
		NSLog(@"There are %lu duplicated game managers with uuid \"%@\" in CoreData database.", (unsigned long)[matches count], uuid);
	} else if ([matches count] == 1) {
		gManager = [matches lastObject];
	} else { // If there is nothing,
		NSLog(@"There isn't game manager with uuid \"%@\" in CoreData database.", uuid);
	}
	
	return gManager;
}

+(NSArray *)allGameManagersInManagedObjectContext: (NSManagedObjectContext *)context {
	// Check if the board already exists
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: (NSString *)kCoreDataEntityName_GameManager];
	NSError *error;
	NSArray *matches = [context executeFetchRequest:request error:&error];
	if (error) {
		NSLog(@"%@", error);
	}
	return matches;
}

@end
