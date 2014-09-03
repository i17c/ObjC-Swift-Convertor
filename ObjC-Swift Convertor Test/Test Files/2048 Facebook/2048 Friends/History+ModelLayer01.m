//
//  History+ModelLayer01.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/6/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "History+ModelLayer01.h"

NSString *const kCoreDataEntityName_History = @"History";

@implementation History (ModelLayer01)

+(History *)createHistoryinManagedObjectContext: (NSManagedObjectContext *) context {
	History *history = nil;
	
	history = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataEntityName_History inManagedObjectContext:context];
	history.uuid = [NSUUID UUID];
	history.createDate = [[NSDate date] timeIntervalSince1970];
	
	return history;
}

+(BOOL)removeHistoryWithUUID: (NSUUID *) uuid inManagedObjectContext: (NSManagedObjectContext *) context {
	[context deleteObject:[self findHistoryWithUUID:uuid inManagedObjectContext:context]];
	return YES;
}

+(History *)findHistoryWithUUID: (NSUUID *) uuid inManagedObjectContext: (NSManagedObjectContext *) context {
	History *history = nil;
	
	// Check if the board already exists
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: (NSString *)kCoreDataEntityName_History];
	request.predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
	NSError *error;
	NSArray *matches = [context executeFetchRequest:request error:&error];
	
	if (error) { // If there is an error:
		NSLog(@"%@", error);
	} else if ([matches count] > 1) {
		NSLog(@"There are %lu duplicated histories with uuid \"%@\" in CoreData database.", (unsigned long)[matches count], uuid);
	} else if ([matches count] == 1) {
		history = [matches lastObject];
	} else { // If there is nothing,
		NSLog(@"There isn't history with uuid \"%@\" in CoreData database.", uuid);
	}
	
	return history;
}

+(NSArray *)allHistoriesInManagedObjectContext: (NSManagedObjectContext *)context {
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:YES];
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kCoreDataEntityName_History];
	fetchRequest.sortDescriptors = @[sortDescriptor];
	NSError *error;
	NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
	if (error) {
		NSLog(@"%@", error);
	}
	return result;
}

@end
