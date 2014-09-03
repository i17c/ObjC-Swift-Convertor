//
//  Board+gameManagement.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/1/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "Board.h"

extern NSString *const kCoreDataEntityName_Board;

@interface Board (ModelLayer01)

+(Board *)createBoardWithBoardData: (NSMutableArray *) data
					   gamePlaying: (BOOL) gamePLaying
							 score: (int32_t) score
					swipeDirection: (int16_t) swipeDirection
			inManagedObjectContext: (NSManagedObjectContext *) context;

+(BOOL)removeBoardWithUUID: (NSUUID *) uuid inManagedObjectContext: (NSManagedObjectContext *) context;
+(Board *)findBoardWithUUID: (NSUUID *) uuid inManagedObjectContext: (NSManagedObjectContext *) context;
+(NSArray *)allBoardsInManagedObjectContext: (NSManagedObjectContext *)context;

@end
