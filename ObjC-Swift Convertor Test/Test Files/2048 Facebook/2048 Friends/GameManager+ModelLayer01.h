//
//  GameManager+ModelLayer01.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/3/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "GameManager.h"

extern NSString *const kCoreDataEntityName_GameManager;

@interface GameManager (ModelLayer01)

+(GameManager *)createGameManagerWithBestScore: (int32_t) bestScore
								currentThemeID: (NSString *) currentThemeID
			 maxOccuredTimesOnBoardForEachTile: (NSMutableDictionary *) occurTimeDictionary
						inManagedObjectContext: (NSManagedObjectContext *) context;

+(BOOL)removeGameManagerWithUUID: (NSUUID *) uuid inManagedObjectContext: (NSManagedObjectContext *) context;
+(NSArray *)allGameManagersInManagedObjectContext: (NSManagedObjectContext *)context;
+(GameManager *) findGameManagerWithUUID: (NSUUID *) uuid inManagedObjectContext: (NSManagedObjectContext *)context;

@end

