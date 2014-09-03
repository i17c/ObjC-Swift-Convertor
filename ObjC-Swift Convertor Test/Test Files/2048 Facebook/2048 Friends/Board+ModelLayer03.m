//
//  Board+ModelLayer03.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/4/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "Board+ModelLayer03.h"
#import "Tile+ModelLayer03.h"
#import "History+ModelLayer03.h"
#import "GameManager+ModelLayer03.h"
#import "AppDelegate.h"

@implementation Board (ModelLayer03)

+(Board *) initializeNewBoard {
	Board *board = nil;
	NSMutableArray *boardData = [NSMutableArray array];
	for (size_t i = 0; i < 4; ++i) { // 17 elements, the last one is swipe gesture info
		boardData[i] = [NSMutableArray array];
		for (size_t j = 0; j < 4; ++j) {
			boardData[i][j] = @(0);
		}
	}
	
	// Generate two random tiles with 2 or 4.
	CGPoint p = CGPointMake(-1.0f, -1.0f);
	for (int i = 0; i < 2; ++i) {
		CGPoint temp = [Board generateRandomAvailableCellPoint_Col_Row_FromCells2DArray:boardData];
		if (!CGPointEqualToPoint(p, temp)) {
			p = temp;
		} else {
			--i;
			continue;
		}
		int32_t val = [Tile generateRandomInitTileValue];
		boardData[(int)p.y][(int)p.x] = @(val);
	}
	[boardData addObject:boardData];
	
	board = [Board createBoardWithBoardData:boardData
									   gamePlaying:YES
											 score:0
									swipeDirection:BoardSwipeGestureDirectionNone];
	[History initializeNewHistory];
	[[History latestHistory] addBoardsObject:board];
	return board;
}

-(Board *) swipedToDirection: (BoardSwipeGestureDirection) direction newTileValue: (int32_t *) newVal newTilePos: (CGPoint *) newPos {
	Board *nextBoard = nil;
	if (self.gameplaying && [self canBeSwipedIntoDirection:direction]) {
		self.swipeDirection = direction; // Set the direction for current last board
		// Data for the next board:
		NSMutableArray *arr = [self getBoardDataArray];
		BOOL gamePLaying = NO;
		int32_t score = self.score;
		
		if (direction == BoardSwipeGestureDirectionLeft) {
			for (int row = 0; row < 4; ++row) {
				NSMutableArray *rowArr = arr[row];
				int col1 = 0;
				int col2 = 0;
				int col3 = 1;
				
				while (col1 < 4 && col2 < 4 && col3 < 4) {
					if ([rowArr[col2] intValue] == 0) {
						++col2;
						++col3;
						continue;
					}
					if ([rowArr[col3] intValue] == 0) {
						++col3;
						continue;
					}
					// If both formerTileInd and nextTileInd are not zero, the following code get executed.
					int newVal = 0;
					if ([rowArr[col2] intValue] == [rowArr[col3] intValue] && col2 != col3) {
						newVal = 2 * [rowArr[col2] intValue];
						score += newVal;
						rowArr[col2] = @(0);
						rowArr[col3] = @(0);
						col2++;
						col3++;
					} else {
						newVal = [rowArr[col2] intValue];
						rowArr[col2] = @(0);
						col2 = col3++;
					}
					rowArr[col1++] = @(newVal);
				}
				while (col1 < 4 && col2 < 4) {
					int newVal = [rowArr[col2] intValue];
					if (newVal != 0 && [arr[row][col1] intValue] == 0) {
						rowArr[col1++] = @(newVal);
						rowArr[col2] = @(0);
					}
					col2++;
				}
			}
		} else if (direction == BoardSwipeGestureDirectionRight) {
			for (int row = 0; row < 4; ++row) {
				NSMutableArray *rowArr = arr[row];
				int col1 = 3;
				int col2 = 3;
				int col3 = 2;
				
				while (col1 >= 0 && col2 >= 0 && col3 >= 0) {
					if ([rowArr[col2] intValue] == 0) {
						--col2;
						--col3;
						continue;
					}
					if ([rowArr[col3] intValue] == 0) {
						--col3;
						continue;
					}
					// If both formerTileInd and nextTileInd are not zero, the following code get executed.
					int newVal = 0;
					if ([rowArr[col2] intValue] == [rowArr[col3] intValue] && col2 != col3) {
						newVal = 2 * [rowArr[col2] intValue];
						score += newVal;
						rowArr[col2] = @(0);
						rowArr[col3] = @(0);
						col2--;
						col3--;
					} else {
						newVal = [rowArr[col2] intValue];
						rowArr[col2] = @(0);
						col2 = col3--;
					}
					rowArr[col1--] = @(newVal);
				}
				while (col1 >= 0 && col2 >= 0) {
					int newVal = [rowArr[col2] intValue];
					if (newVal != 0 && [arr[row][col1] intValue] == 0) {
						rowArr[col1--] = @(newVal);
						rowArr[col2] = @(0);
					}
					col2--;
				}
			}
		} else if (direction == BoardSwipeGestureDirectionUp) {
			for (int col = 0; col < 4; ++col) {
				int row1 = 0;
				int row2 = 0;
				int row3 = 1;
				while (row1 < 4 && row2 < 4 && row3 < 4) {
					if ([arr[row2][col] intValue] == 0) {
						++row2;
						++row3;
						continue;
					}
					if ([arr[row3][col] intValue] == 0) {
						++row3;
						continue;
					}
					// If both formerTileInd and nextTileInd are not zero, the following code get executed.
					int newVal = 0;
					if ([arr[row2][col] intValue] == [arr[row3][col] intValue] && row2 != row3) {
						newVal = 2 * [arr[row2][col] intValue];
						score += newVal;
						arr[row2][col] = @(0);
						arr[row3][col] = @(0);
						row2++;
						row3++;
					} else {
						newVal = [arr[row2][col] intValue];
						arr[row2][col] = @(0);
						row2 = row3++;
					}
					arr[row1++][col] = @(newVal);
				}
				while (row1 < 4 && row2 < 4) {
					int newVal = [arr[row2][col] intValue];
					if (newVal != 0 && [arr[row1][col] intValue] == 0) {
						arr[row1++][col] = @(newVal);
						arr[row2][col] = @(0);
					}
					row2++;
				}
			}
		} else if (direction == BoardSwipeGestureDirectionDown) {
			for (int col = 0; col < 4; ++col) {
				int row1 = 3;
				int row2 = 3;
				int row3 = 2;
				while (row1 >= 0 && row2 >= 0 && row3 >= 0) {
					if ([arr[row2][col] intValue] == 0) {
						--row2;
						--row3;
						continue;
					}
					if ([arr[row3][col] intValue] == 0) {
						--row3;
						continue;
					}
					// If both formerTileInd and nextTileInd are not zero, the following code get executed.
					int newVal = 0;
					if ([arr[row2][col] intValue] == [arr[row3][col] intValue] && row2 != row3) {
						newVal = 2 * [arr[row2][col] intValue];
						score += newVal;
						arr[row2][col] = @(0);
						arr[row3][col] = @(0);
						row2--;
						row3--;
					} else {
						newVal = [arr[row2][col] intValue];
						arr[row2][col] = @(0);
						row2 = row3--;
					}
					arr[row1--][col] = @(newVal);
				}
				while (row1 >= 0 && row2 >= 0) {
					int newVal = [arr[row2][col] intValue];
					if (newVal != 0 && [arr[row1][col] intValue] == 0) {
						arr[row1--][col] = @(newVal);
						arr[row2][col] = @(0);
					}
					row2--;
				}
			}
		}
		
		// Generate a new random tile
		CGPoint p = [Board generateRandomAvailableCellPoint_Col_Row_FromCells2DArray: arr];
		if (newPos) {*newPos = p;}
		NSNumber *val = @([Tile generateRandomInitTileValue]);
		arr[(int)p.y][(int)p.x] = val;
		if (newVal) {*newVal = (int32_t)[val intValue];}
		
		// Check to see if the game is still playing and update onboard tiles.
		gamePLaying = [Board gameEndFrom2DArray:arr];
		
		// Update info for new board:
		nextBoard = [Board createBoardWithBoardData:arr
										gamePlaying:gamePLaying
											  score:score
									 swipeDirection:BoardSwipeGestureDirectionNone];
		
		// Add this board to history
		[[History latestHistory] addBoardsObject:nextBoard];
		
		// Update Best score
		GameManager *gManager = [GameManager sharedGameManager];
		if (score > gManager.bestScore) {
			gManager.bestScore = score;
		}
		
		NSMutableDictionary *maxOccuredDictionary = [[[GameManager sharedGameManager]getMaxOccuredDictionary] mutableCopy];
		NSMutableDictionary *occurTimeDictionary = [NSMutableDictionary dictionary];
		for (int i = 0; i < maxTilePower; ++i) {
			occurTimeDictionary[@((NSInteger)pow(2.0f, i + 1))] = @(0);
		}
		
		for (size_t i = 0; i < 4; ++i) {
			for (size_t j = 0; j < 4; ++j) {
				if ([arr[i][j] intValue] != 0) {
					occurTimeDictionary[arr[i][j]] = @([occurTimeDictionary[arr[i][j]] intValue] + 1);
				}
			}
		}
		
		for (int i = 0; i < maxTilePower; ++i) {
			if ([occurTimeDictionary[@((NSInteger)pow(2.0f, i + 1))] intValue] > [maxOccuredDictionary[@((NSInteger)pow(2.0f, i + 1))] intValue]) {
				maxOccuredDictionary[@((NSInteger)pow(2.0f, i + 1))] = occurTimeDictionary[@((NSInteger)pow(2.0f, i + 1))];
			}
		}
		
		[[GameManager sharedGameManager] setMaxOccuredDictionary:[maxOccuredDictionary copy]];
	}
	return nextBoard;

}

// This makes a copy of the previouse
-(Board *) swipedToDirection: (BoardSwipeGestureDirection) direction {
	return [self swipedToDirection:direction newTileValue:nil newTilePos:nil];
}

-(NSMutableArray *)getBoardDataArray {
	NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:self.boardData];
	return array;
}

-(BOOL)setBoardDataArray: (NSMutableArray *) array {
	NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:array];
	self.boardData = arrayData;
	
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [appDelegate saveContext];
}

// Return all available cells with CGPoint, take the 2D array as data source
+(NSArray *)availableCellPointsFromCells2DArray: (NSArray *) arr {
	NSMutableArray *mutableArr = [NSMutableArray array];
	for (int row = 0; row < 4; ++row) {
		for (int col = 0; col < 4; ++col) {
			if ([arr[row][col] intValue] == 0) {
				[mutableArr addObject:[NSValue valueWithCGPoint:CGPointMake(col, row)]];
			}
		}
	}
	return mutableArr;
}

-(NSArray *)availableCellPoints {
	NSArray *arr = [self getBoardDataArray];
	return [Board availableCellPointsFromCells2DArray:arr];
}

+(BOOL) boardCanBeSwipedIntoDirection: (BoardSwipeGestureDirection) direction from2DArray: (NSArray *) arr {
	BOOL res = NO;
	if (direction == BoardSwipeGestureDirectionLeft) {
		for (size_t i = 0; i < 4; ++i) {
			if (res == NO) {
				NSArray *rowArr = arr[i];
				int j = 3;
				// Loop to the first none zero element
				while (j >= 0 && [rowArr[j] intValue] == 0) {
					--j;
				}
				if (j < 0) {
					continue;
				} else {
					while (j >= 0) {
						// If there is a 0 between two numbers (e.g. @[2, 0, 4, 0]) or there are repeated adjacent numbers: (e.g. @[2, 4, 4, 0])
						if ([rowArr[j] intValue] == 0 || (j - 1 >= 0 && [rowArr[j] intValue] == [rowArr[j - 1] intValue])) {
							res = YES;
							break;
						} else {
							--j;
						}
					}
				}
				
			} else {
				break;
			}
		}
	} else if (direction == BoardSwipeGestureDirectionRight) {
		for (size_t i = 0; i < 4; ++i) {
			if (res == NO) {
				NSArray *rowArr = arr[i];
				int j = 0;
				// Loop to the first none zero element
				while (j < 4 && [rowArr[j] intValue] == 0) {
					++j;
				}
				if (j > 3) {
					continue;
				} else {
					while (j < 4) {
						// If there is a 0 between two numbers (e.g. @[0, 4, 0, 2]) or there are repeated adjacent numbers: (e.g. @[0, 2, 4, 4])
						if ([rowArr[j] intValue] == 0 || (j + 1 < 4 && [rowArr[j] intValue] == [rowArr[j + 1] intValue])) {
							res = YES;
							break;
						} else {
							++j;
						}
					}
				}
				
			} else {
				break;
			}
		}
	} else if (direction == BoardSwipeGestureDirectionUp) {
		for (size_t j = 0; j < 4; ++j) {
			if (res == NO) {
				NSArray *colArr = @[arr[0][j], arr[1][j], arr[2][j], arr[3][j]];
				int j = 3;
				// Loop to the first none zero element
				while (j >= 0 && [colArr[j] intValue] == 0) {
					--j;
				}
				if (j < 0) {
					continue;
				} else {
					while (j >= 0) {
						// If there is a 0 between two numbers (e.g. @[2, 0, 4, 0]) or there are repeated adjacent numbers: (e.g. @[2, 4, 4, 0])
						if ([colArr[j] intValue] == 0 || (j - 1 >= 0 && [colArr[j] intValue] == [colArr[j - 1] intValue])) {
							res = YES;
							break;
						} else {
							--j;
						}
					}
				}
				
			} else {
				break;
			}
		}
	} else if (direction == BoardSwipeGestureDirectionDown) {
		for (size_t j = 0; j < 4; ++j) {
			if (res == NO) {
				NSArray *colArr = @[arr[0][j], arr[1][j], arr[2][j], arr[3][j]];
				int j = 0;
				// Loop to the first none zero element
				while (j < 4 && [colArr[j] intValue] == 0) {
					++j;
				}
				if (j > 3) {
					continue;
				} else {
					while (j < 4) {
						// If there is a 0 between two numbers (e.g. @[0, 4, 0, 2]) or there are repeated adjacent numbers: (e.g. @[0, 2, 4, 4])
						if ([colArr[j] intValue] == 0 || (j + 1 < 4 && [colArr[j] intValue] == [colArr[j + 1] intValue])) {
							res = YES;
							break;
						} else {
							++j;
						}
					}
				}
				
			} else {
				break;
			}
		}
	}
	return res;
}

-(BOOL) canBeSwipedIntoDirection: (BoardSwipeGestureDirection) direction {
	return [Board boardCanBeSwipedIntoDirection:direction from2DArray:[self getBoardDataArray]];
}

// Determine if the game is end.
+(BOOL) gameEndFrom2DArray: (NSArray *)arr {
	if ([Board boardCanBeSwipedIntoDirection:BoardSwipeGestureDirectionLeft from2DArray:arr]) {return YES;}
	if ([Board boardCanBeSwipedIntoDirection:BoardSwipeGestureDirectionRight from2DArray:arr]) {return YES;}
	if ([Board boardCanBeSwipedIntoDirection:BoardSwipeGestureDirectionUp from2DArray:arr]) {return YES;}
	if ([Board boardCanBeSwipedIntoDirection:BoardSwipeGestureDirectionDown from2DArray:arr]) {return YES;}
	return NO;
}

/* Helper Methods:  */

// Generate a random available cell from cell data array, take the 2D array as data source
+(CGPoint) generateRandomAvailableCellPoint_Col_Row_FromCells2DArray: (NSArray *) arr {
	CGPoint res = CGPointMake(-1.0f, -1.0f);
	NSArray *arr2 = [self availableCellPointsFromCells2DArray:arr];
	if ([arr count]) {
		int ind = arc4random()%[arr2 count];
		res = [arr2[ind] CGPointValue];
	}
	return res;
}

-(CGPoint) generateRandomAvailableCellPoint {
	NSArray *arr = [self getBoardDataArray];
	return [Board generateRandomAvailableCellPoint_Col_Row_FromCells2DArray:arr];
}

-(NSString *)description {
	NSMutableString *str = [NSMutableString stringWithString:@"\n"];
	NSMutableArray *mutableArr = [self getBoardDataArray];
	[str appendString:@"--------------------\n"];
	for (int row = 0; row < 4; ++row) {
		[str appendString:@"|"];
		for (int col = 0; col < 4; ++col) {
			[str appendFormat:@"%-4d|", [mutableArr[row][col] intValue]];
		}
		[str appendString:@"\n--------------------\n"];
	}
	
	NSString *directionString = nil;
	switch (self.swipeDirection) {
		case BoardSwipeGestureDirectionNone:
			directionString = @"NONE";
			break;
		case BoardSwipeGestureDirectionLeft:
			directionString = @"LEFT";
			break;
		case BoardSwipeGestureDirectionRight:
			directionString = @"RIGHT";
			break;
		case BoardSwipeGestureDirectionUp:
			directionString = @"UP";
			break;
		case BoardSwipeGestureDirectionDown:
			directionString = @"DOWN";
			break;
		default:
			directionString = @"NONE";
			break;
	}
	[str appendFormat:@"Direction: %@\n", directionString];
	[str appendFormat:@"Score: %d\n", self.score];
	[str appendFormat:@"Game Playing: %@", (self.gameplaying ? @"YES":@"NO")];
	return str;
}

+(NSString *)directionStringFromDirection:(BoardSwipeGestureDirection)direction {
	NSString *swipeDirectionString = @"";
	switch (direction) {
		case BoardSwipeGestureDirectionNone:
			swipeDirectionString = @"NONE";
			break;
		case BoardSwipeGestureDirectionLeft:
			swipeDirectionString = @"LEFT";
			break;
		case BoardSwipeGestureDirectionRight:
			swipeDirectionString = @"RIGHT";
			break;
		case BoardSwipeGestureDirectionUp:
			swipeDirectionString = @"UP";
			break;
		case BoardSwipeGestureDirectionDown:
			swipeDirectionString = @"DOWN";
			break;
		default:
			break;
	}
	return swipeDirectionString;
}

#ifdef DEBUG_BOARD
-(void)printBoard {
	NSLog(@"%@", [self description]);
}

#endif

@end
