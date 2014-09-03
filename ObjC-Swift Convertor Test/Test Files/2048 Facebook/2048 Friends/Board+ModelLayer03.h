//
//  Board+ModelLayer03.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/4/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "Board+ModelLayer02.h"

#ifdef DEBUG
#define DEBUG_BOARD
#endif

typedef NS_OPTIONS(NSUInteger, BoardSwipeGestureDirection) {
	BoardSwipeGestureDirectionNone = 0x0,
	BoardSwipeGestureDirectionLeft = 0x1 << 0,
	BoardSwipeGestureDirectionRight = 0x1 << 1,
	BoardSwipeGestureDirectionUp = 0x1 << 2,
	BoardSwipeGestureDirectionDown = 0x1 << 3
};

@interface Board (ModelLayer03)

// Every time initializing a new board, a new history is created automatically, later boards created are added into latest history
+(Board *) initializeNewBoard;
// Swipe the board to the given direction, the two pointers variables are for getting the newTile information.
-(Board *) swipedToDirection: (BoardSwipeGestureDirection) direction newTileValue: (int32_t *) newVal newTilePos: (CGPoint *) newPos;
-(Board *) swipedToDirection: (BoardSwipeGestureDirection) direction;

-(NSMutableArray *)getBoardDataArray;
-(BOOL)setBoardDataArray: (NSMutableArray *) array;

// Return all available cells with CGPoint, take the 2D array as data source
+(NSArray *)availableCellPointsFromCells2DArray: (NSArray *) arr;
-(NSArray *)availableCellPoints;

// Determine if the board can be swiped into given direction
+(BOOL) boardCanBeSwipedIntoDirection: (BoardSwipeGestureDirection) direction from2DArray: (NSArray *) arr;
-(BOOL) canBeSwipedIntoDirection: (BoardSwipeGestureDirection) direction;

// Determine if the game is end.
+(BOOL) gameEndFrom2DArray: (NSArray *)arr;
+(CGPoint) generateRandomAvailableCellPoint_Col_Row_FromCells2DArray: (NSArray *) arr;

// Some helper method:
+(NSString *)directionStringFromDirection:(BoardSwipeGestureDirection)direction;

#ifdef DEBUG_BOARD
-(void)printBoard;
#endif

@end
