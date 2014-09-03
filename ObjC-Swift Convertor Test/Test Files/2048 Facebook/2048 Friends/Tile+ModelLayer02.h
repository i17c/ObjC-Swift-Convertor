//
//  Tile+ModelLayer02.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/3/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "Tile+ModelLayer01.h"

@interface Tile (ModelLayer02)

+(Tile *)tileWithValue: (int32_t) value;
+(BOOL)removeTileWithValue: (int32_t) value;

+(NSArray *)allTiles; // Default value in ascending order.

@end
