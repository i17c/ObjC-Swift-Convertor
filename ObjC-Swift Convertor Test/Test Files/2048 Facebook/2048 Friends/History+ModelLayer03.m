//
//  History+ModelLayer03.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/6/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "History+ModelLayer03.h"
#import "GameManager+ModelLayer03.h"

@implementation History (ModelLayer03)

//
+(History *)initializeNewHistory {
	History *history = nil;
	history = [History createHistory];
	GameManager *gManager = [GameManager sharedGameManager];
	[gManager addGameHistoriesObject:history];
	return history;
}

@end
