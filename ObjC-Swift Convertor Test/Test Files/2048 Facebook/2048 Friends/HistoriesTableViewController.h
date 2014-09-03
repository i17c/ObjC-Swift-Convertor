//
//  HistoriesTableViewController.h
//  2048 Friends
//
//  Created by Shuyang Sun on 5/12/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameManager;

@interface HistoriesTableViewController : UITableViewController

@property (nonatomic, strong) GameManager *gManager;
@property (nonatomic, strong) NSArray *histories;

@end
