//
//  Board.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/25/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class History;

@interface Board : NSManagedObject

@property (nonatomic, retain) NSData *boardData;
@property (nonatomic) NSTimeInterval createDate;
@property (nonatomic) BOOL gameplaying;
@property (nonatomic) int32_t score;
@property (nonatomic) int16_t swipeDirection;
@property (nonatomic, retain) NSUUID *uuid;
@property (nonatomic, retain) History *boardHistory;

@end
