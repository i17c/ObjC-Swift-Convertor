//
//  History+ModelLayer02.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/6/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "History+ModelLayer02.h"
#import "AppDelegate.h"

@implementation History (ModelLayer02)

+(History *)createHistory {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [self createHistoryinManagedObjectContext:appDelegate.managedObjectContext];
}

+(BOOL)removeHistoryWithUUID: (NSUUID *) uuid {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [self removeHistoryWithUUID:uuid inManagedObjectContext:appDelegate.managedObjectContext];
}

+(History *)findHistoryWithUUID: (NSUUID *) uuid {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [self findHistoryWithUUID:uuid inManagedObjectContext:appDelegate.managedObjectContext];
}

+(NSArray *)allHistories {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [self allHistoriesInManagedObjectContext:appDelegate.managedObjectContext];
}

+(History *)latestHistory {
	History *res = [[self allHistories] lastObject];
	return res;
}


@end
