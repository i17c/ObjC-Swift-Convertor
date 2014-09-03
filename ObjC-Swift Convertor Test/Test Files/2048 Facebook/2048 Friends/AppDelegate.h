//
//  AppDelegate.h
//  2048 FB
//
//  Created by Shuyang Sun on 3/31/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kAppDelegate_UserDefaultKeyAppFirstTimeLaunch;
extern NSString *const kAppDelegate_CurrentThemeIDKey;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (BOOL)saveContext;

@end
