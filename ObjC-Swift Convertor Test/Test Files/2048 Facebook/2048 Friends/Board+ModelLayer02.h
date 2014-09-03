//
//  Board+ModelLayer02.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/4/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "Board+ModelLayer01.h"

@interface Board (ModelLayer02)

+(Board *)createBoardWithBoardData: (NSMutableArray *) data
					   gamePlaying: (BOOL) gamePLaying
							 score: (int32_t) score
					swipeDirection: (int16_t) swipeDirection;

+(BOOL)removeBoardWithUUID: (NSUUID *) uuid;

+(Board *)findBoardWithUUID: (NSUUID *) uuid;

+(NSArray *)allBoards; // Default createDate in ascending order.

+(Board *)latestBoard;

@end
