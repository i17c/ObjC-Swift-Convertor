//
//  Tile+ModelLayer03.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/4/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "Tile+ModelLayer02.h"

// The maximum power of 2 the player can play.
extern NSUInteger maxTilePower;

typedef NS_ENUM(NSUInteger, TileType) {
	TileTypeImage = 0,
	TileTypeNumber
};

@interface Tile (ModelLayer03)

// Initialize all the tiles without images. Should be called only once when the app launches, and there is no iCloud data to fetch.
+(BOOL)initializeAllTiles;
// Get images for 2, 4, 8.. tiles respectively.
+(NSArray *)imagesForAllTiles;
// Pass in an array of images, they are set to tiles with value 2, 4, 8... respectively.
+(BOOL)setImagesForTiles: (NSArray *) images;
+(UIImage *)imageForTileWithValue: (int32_t) value;
+(BOOL)setImage: (UIImage *) image forTileWithValue: (int32_t) value;
+(int32_t) generateRandomInitTileValue;
@end
