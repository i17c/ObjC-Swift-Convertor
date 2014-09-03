//
//  History+ModelLayer01.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/6/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "History.h"

extern NSString *const kCoreDataEntityName_History;

@interface History (ModelLayer01)

+(History *)createHistoryinManagedObjectContext: (NSManagedObjectContext *) context;
+(BOOL)removeHistoryWithUUID: (NSUUID *) uuid inManagedObjectContext: (NSManagedObjectContext *) context;
+(History *)findHistoryWithUUID: (NSUUID *) uuid inManagedObjectContext: (NSManagedObjectContext *) context;
+(NSArray *)allHistoriesInManagedObjectContext: (NSManagedObjectContext *)context;

@end
