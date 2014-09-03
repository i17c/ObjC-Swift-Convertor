//
//  Tile+tileManagement.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/1/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "Tile+ModelLayer01.h"
#import "macro.h"

NSString *const kCoreDataEntityName_Tile = @"Tile";

@implementation Tile (ModelLayer01)

+(Tile *)tileWithValue: (int32_t) value inManagedObjectContext: (NSManagedObjectContext *)context{
	Tile *tile = nil;
	
	// Check if the tile already exists
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: (NSString *)kCoreDataEntityName_Tile];
	request.predicate = [NSPredicate predicateWithFormat:@"value = %d", value];
	NSError *error;
	NSArray *matches = [context executeFetchRequest:request error:&error];
	
	if (error) { // If there is an error:
		NSLog(@"%@", error);
	} else if ([matches count] > 1) {
		NSLog(@"There are %lu duplicated tiles with value \"%d\" in CoreData database.", (unsigned long)[matches count], value);
	} else if ([matches count] == 1) { // If there is one unique tile:
		tile = [matches lastObject]; // Return the tile if it already exists.
	} else { // If there is nothing,
		tile = [NSEntityDescription insertNewObjectForEntityForName: (NSString *)kCoreDataEntityName_Tile inManagedObjectContext: context];
		tile.uuid = [NSUUID UUID];
		tile.text = [NSString stringWithFormat:@"%d", value];
		tile.value = value;
	}
	
	return tile;
}

+(BOOL)removeTileWithValue: (int32_t) value inManagedObjectContext: (NSManagedObjectContext *)context{
	// Check if the tile already exists
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: (NSString *)kCoreDataEntityName_Tile];
	request.predicate = [NSPredicate predicateWithFormat:@"value = %d", value];
	NSError *error;
	NSArray *matches = [context executeFetchRequest:request error:&error];
	
	if (error) { // If there is an error:
		NSLog(@"%@", error);
	} else if ([matches count] > 1) {
		NSLog(@"There are %lu duplicated tiles with value \"%d\" in CoreData database.", (unsigned long)[matches count], value);
	} else if ([matches count] == 1) { // If there is one unique tile:
		[context deleteObject:[matches lastObject]];
		return YES;
	}
	return NO;
}


@end
