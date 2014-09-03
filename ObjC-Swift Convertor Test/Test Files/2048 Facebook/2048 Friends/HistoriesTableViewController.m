//
//  HistoriesTableViewController.m
//  2048 Friends
//
//  Created by Shuyang Sun on 5/12/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "HistoriesTableViewController.h"
#import "GameManager+ModelLayer03.h"
#import "History+ModelLayer03.h"
#import "GameViewController.h"

@interface HistoriesTableViewController ()

@property (nonatomic, strong) History *selectedHistory;

@end

@implementation HistoriesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_histories) {
		return [_histories count];
	}
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    
	// The front histories in the array should display at the bottom, so use reversed index for cells.
	History *history = [_histories objectAtIndex:([_histories count] - 1 - indexPath.row)];
	NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:history.createDate];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateStyle = NSDateFormatterShortStyle;
	formatter.timeStyle = NSDateFormatterShortStyle;
	formatter.locale = [NSLocale currentLocale];
	
	cell.textLabel.text = [NSString stringWithFormat:@"Game %02lu", (NSUInteger)([_histories count] - 1 - indexPath.row) + 1];
	cell.detailTextLabel.text = [formatter stringFromDate:createDate];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	self.selectedHistory = [_histories objectAtIndex:([_histories count] - 1 - indexPath.row)];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	UIViewController *destController = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"HistoriesToGameViewControllerSegue"]) {
		GameViewController *gViewController = (GameViewController *)destController;
		gViewController.mode = GameViewControllerModeReplay;
		if (_selectedHistory) {
			NSArray *boards = [_selectedHistory.boards allObjects];
			NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:YES];
			boards = [boards sortedArrayUsingDescriptors:@[sortDescriptor]];
			gViewController.replayBoards = boards;
		}
	}
}


@end
