//
//  Tile+ModelLayer02.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/3/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "Tile+ModelLayer02.h"
#import "AppDelegate.h"

@interface Tile()

+(NSManagedObjectContext *)getManagedObjectContext;

@end

@implementation Tile (ModelLayer02)

+(Tile *)tileWithValue: (int32_t) value {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [Tile tileWithValue:value inManagedObjectContext:appDelegate.managedObjectContext];
}

+(BOOL)removeTileWithValue: (int32_t) value {
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [Tile removeTileWithValue:value inManagedObjectContext:appDelegate.managedObjectContext];
}

+(NSArray *)allTiles {
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES];
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kCoreDataEntityName_Tile];
	fetchRequest.sortDescriptors = @[sortDescriptor];
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	NSError *error;
	NSArray *result = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		NSLog(@"%@", error);
	}
	return result;
}

@end
