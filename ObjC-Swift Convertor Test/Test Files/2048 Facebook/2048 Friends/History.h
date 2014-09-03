//
//  History.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/6/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Board, GameManager;

@interface History : NSManagedObject

@property (nonatomic) NSTimeInterval createDate;
@property (nonatomic, retain) NSUUID *uuid;
@property (nonatomic, retain) GameManager *gManager;
@property (nonatomic, retain) NSSet *boards;
@end

@interface History (CoreDataGeneratedAccessors)

- (void)addBoardsObject:(Board *)value;
- (void)removeBoardsObject:(Board *)value;
- (void)addBoards:(NSSet *)values;
- (void)removeBoards:(NSSet *)values;

@end
