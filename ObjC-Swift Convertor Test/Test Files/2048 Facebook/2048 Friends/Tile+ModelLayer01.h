//
//  Tile+tileManagement.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/1/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "Tile.h"

extern NSString *const kCoreDataEntityName_Tile;

@interface Tile (ModelLayer01)

+(Tile *)tileWithValue: (int32_t) value inManagedObjectContext: (NSManagedObjectContext *)context;
+(BOOL)removeTileWithValue: (int32_t) value inManagedObjectContext: (NSManagedObjectContext *)context;

@end
