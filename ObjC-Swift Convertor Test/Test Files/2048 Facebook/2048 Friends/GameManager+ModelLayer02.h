//
//  GameManager+ModelLayer02.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/4/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "GameManager+ModelLayer01.h"

@interface GameManager (ModelLayer02)

+(GameManager *)createGameManagerWithBestScore: (int32_t) bestScore
								currentThemeID: (NSString *) currentThemeID
			 maxOccuredTimesOnBoardForEachTile: (NSMutableDictionary *) occurTimeDictionary;

+(BOOL)removeGameManagerWithUUID: (NSUUID *) uuid;
+(GameManager *) findGameManagerWithUUID: (NSUUID *) uuid;
+(NSArray *)allGameManagers;

@end
