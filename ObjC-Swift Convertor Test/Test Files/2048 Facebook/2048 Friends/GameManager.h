//
//  GameManager.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/6/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface GameManager : NSManagedObject

@property (nonatomic) int16_t tileViewType;
@property (nonatomic) int32_t bestScore;
@property (nonatomic, retain) NSString * currentThemeID;
@property (nonatomic, retain) NSData * maxOccuredTimesOnBoardForEachTile;
@property (nonatomic, retain) NSUUID *uuid;
@property (nonatomic, retain) NSSet *gameHistories;
@end

@interface GameManager (CoreDataGeneratedAccessors)

- (void)addGameHistoriesObject:(NSManagedObject *)value;
- (void)removeGameHistoriesObject:(NSManagedObject *)value;
- (void)addGameHistories:(NSSet *)values;
- (void)removeGameHistories:(NSSet *)values;

@end
