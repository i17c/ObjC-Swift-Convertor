//
//  Board+ModelLayer02.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/4/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "Board+ModelLayer02.h"
#import "AppDelegate.h"
#import "History+ModelLayer03.h"

@implementation Board (ModelLayer02)

+(Board *)createBoardWithBoardData: (NSMutableArray *) data
					   gamePlaying: (BOOL) gamePLaying
							 score: (int32_t) score
					swipeDirection: (int16_t) swipeDirection {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	NSMutableArray *dataCopy = [NSMutableArray array];
	for (size_t i = 0; i < 4; ++i) {
		dataCopy[i] = [data[i] mutableCopy];
	}
	return [Board createBoardWithBoardData:dataCopy
							   gamePlaying:gamePLaying
									 score:score
							swipeDirection:swipeDirection
					inManagedObjectContext:appDelegate.managedObjectContext];
}

+(BOOL)removeBoardWithUUID: (NSUUID *) uuid {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [Board removeBoardWithUUID: uuid inManagedObjectContext:appDelegate.managedObjectContext];
}

+(Board *)findBoardWithUUID: (NSUUID *) uuid {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [Board findBoardWithUUID:uuid inManagedObjectContext:appDelegate.managedObjectContext];
}

+(NSArray *)allBoards {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [self allBoardsInManagedObjectContext:appDelegate.managedObjectContext];
}

+(Board *)latestBoard {
	History *histories = [History latestHistory];
	NSSet *boardSet = histories.boards;
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:YES];
	NSArray *boardArr = [boardSet sortedArrayUsingDescriptors:@[sortDescriptor]];
	return [boardArr lastObject];
}

@end
