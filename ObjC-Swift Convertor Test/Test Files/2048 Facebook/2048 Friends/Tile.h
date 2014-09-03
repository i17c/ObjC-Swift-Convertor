//
//  Tile.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/7/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tile;

@interface Tile : NSManagedObject

@property (nonatomic, retain) NSString * fbUserID;
@property (nonatomic, retain) NSString * fbUserName;
@property (nonatomic, retain) UIImage * image;
@property (nonatomic, retain) NSUUID * uuid;
@property (nonatomic) int32_t value;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Tile *nextTile;
@property (nonatomic, retain) Tile *previousTile;

@end
