//
//  Tile+ModelLayer03.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/4/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "Tile+ModelLayer03.h"
#import "AppDelegate.h"

// Because tile value is int32_t, we use 14 bits to store info. 2 ^ 14 = 16,384
NSUInteger maxTilePower = 14;

@implementation Tile (ModelLayer03)

// Initialize all the tiles without images. Should be called only once when the app launches, and there is no iCloud data to fetch.
+(BOOL)initializeAllTiles {
	if ([[Tile allTiles] count] <= 0) { // If there is no tiles in data base:
		for (int i = 1; i <= maxTilePower; ++i) {
			int32_t val = (int32_t)pow(2.0f, i);
			Tile *tile = [Tile tileWithValue:val];
			if (i > 1) {
				tile.previousTile = [Tile tileWithValue: val/2];
			}
			if (i < maxTilePower) {
				tile.nextTile = [Tile tileWithValue: val * 2];
			}
		}
	} else {
		return NO;
	}
	
	return YES;
}

// Get images for 2, 4, 8.. tiles respectively.
+(NSArray *)imagesForAllTiles {
	NSArray *tilesArr = [Tile allTiles];
	NSMutableArray *images = [NSMutableArray array];
	for (Tile *tile in tilesArr) {
		[images addObject:tile.image];
	}
	return images;
}

// Pass in an array of images, they are set to tiles with value 2, 4, 8... respectively.
+(BOOL)setImagesForTiles: (NSArray *) images {
	NSArray *tilesArr = [Tile allTiles];
	for (int i = 0; i < [images count] && i < [tilesArr count]; ++i) {
		((Tile *)tilesArr[i]).image = images[i];
	}
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [appDelegate saveContext];
}

+(UIImage *)imageForTileWithValue: (int32_t) value {
	return [Tile tileWithValue:value].image;
}

+(BOOL)setImage: (UIImage *) image forTileWithValue: (int32_t) value {
	Tile *tile = [Tile tileWithValue:value];
	tile.image = image;
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [appDelegate saveContext];
}

+(int32_t) generateRandomInitTileValue {
	return arc4random()%100 < 90 ? 2:4; // 90% chance get 2, 10% get 4
}

@end
