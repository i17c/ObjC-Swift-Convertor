//
//  History+ModelLayer02.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/6/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "History+ModelLayer01.h"

@interface History (ModelLayer02)

+(History *)createHistory;

+(BOOL)removeHistoryWithUUID: (NSUUID *) uuid;

+(History *)findHistoryWithUUID: (NSUUID *) uuid;

+(NSArray *)allHistories; // Default createDate in ascending order.

+(History *)latestHistory;

@end
