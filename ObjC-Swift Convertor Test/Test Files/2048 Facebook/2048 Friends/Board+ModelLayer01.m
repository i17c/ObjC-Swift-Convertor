//
//  Board+gameManagement.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/1/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "Board+ModelLayer01.h"
#import "macro.h"

NSString *const kCoreDataEntityName_Board = @"Board";

@implementation Board (ModelLayer01)

+(Board *)createBoardWithBoardData: (NSMutableArray *) data
					   gamePlaying: (BOOL) gamePLaying
							 score: (int32_t) score
					swipeDirection: (int16_t) swipeDirection
			inManagedObjectContext: (NSManagedObjectContext *) context {
	Board *board = nil;
	
	board = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataEntityName_Board inManagedObjectContext:context];
	board.uuid = [NSUUID UUID];
	board.boardData = [NSKeyedArchiver archivedDataWithRootObject:data];
	board.gameplaying = gamePLaying;
	board.score = score;
	board.swipeDirection = swipeDirection;
	board.createDate = [[NSDate date] timeIntervalSince1970];
	
	return board;
}

+(BOOL)removeBoardWithUUID: (NSUUID *) uuid inManagedObjectContext: (NSManagedObjectContext *) context {
	[context deleteObject:[self findBoardWithUUID:uuid inManagedObjectContext:context]];
	return YES;
}

+(Board *)findBoardWithUUID: (NSUUID *) uuid inManagedObjectContext: (NSManagedObjectContext *) context {
	Board *board = nil;
	
	// Check if the board already exists
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: (NSString *)kCoreDataEntityName_Board];
	request.predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
	NSError *error;
	NSArray *matches = [context executeFetchRequest:request error:&error];
	
	if (error) { // If there is an error:
		NSLog(@"%@", error);
	} else if ([matches count] > 1) {
		NSLog(@"There are %lu duplicated boards with uuid \"%@\" in CoreData database.", (unsigned long)[matches count], uuid);
	} else if ([matches count] == 1) {
		board = [matches lastObject];
	} else { // If there is nothing,
		NSLog(@"There isn't board with uuid \"%@\" in CoreData database.", uuid);
	}
	
	return board;
}

+(NSArray *)allBoardsInManagedObjectContext: (NSManagedObjectContext *)context {
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:YES];
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kCoreDataEntityName_Board];
	fetchRequest.sortDescriptors = @[sortDescriptor];
	NSError *error;
	NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
	if (error) {
		NSLog(@"%@", error);
	}
	return result;
}

@end
