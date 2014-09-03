//
//  GameManager+ModelLayer03.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/4/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "GameManager+ModelLayer02.h"

@interface GameManager (ModelLayer03)

// Initialize one game manager for the game. Should be called only once when the app launches, and there is no iCloud data to fetch.
+(GameManager *) initializeGameManager;
+(GameManager *) sharedGameManager;
-(NSDictionary *) getMaxOccuredDictionary;
-(BOOL) setMaxOccuredDictionary: (NSDictionary *) dictionary;
-(NSUInteger) getMaxOccuredTimeForTileWithValue: (NSInteger) value;
-(BOOL) setMaxOccuredTime: (NSUInteger) count ForTileWithValue: (NSInteger) value;

@end
