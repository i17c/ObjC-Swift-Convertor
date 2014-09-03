//
//  BoardScene.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/19/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "BoardScene.h"
#import "Theme.h"
#import "GameManager+ModelLayer03.h"
#import "History+ModelLayer03.h"
#import "Board+ModelLayer03.h"
#import "Tile+ModelLayer03.h"
#import "TileSKShapeNode.h"
#import "GameViewController.h"
#import "macro.h"

const NSTimeInterval kAnimationDuration_TileContainerPopup = SCALED_ANIMATION_DURATION(0.05f);

@interface BoardScene()

@property (nonatomic, assign) CGFloat scaleFactor;

@end

@implementation BoardScene

#pragma mark - Class Initialization Methods

-(id)initWithSize:(CGSize)size {
	if (self = [super initWithSize:size]) {
		self.uiIdiom = [UIDevice currentDevice].userInterfaceIdiom;
		self.gManager = [GameManager sharedGameManager];
		self.board = [Board latestBoard];
		if (!self.board) {
			self.board = [Board initializeNewBoard];
		}
		self.history = [History latestHistory];
		self.tileType = self.gManager.tileViewType;
		[self updateImagesAndUserIDs];
    }
    return self;
}

-(id)initWithSize:(CGSize)size andTheme:(Theme *)theme {
	BoardScene *res = [self initWithSize:size];
	res.theme = theme;
	self.tileContainers = [NSMutableArray array];
	for (size_t i = 0; i < 4; ++i) {
		self.tileContainers[i] = [NSMutableArray array];
	}
	[self initializePropertyLists];
	[self initializeTileContainers:size];
	
	return res;
}

+(id)sceneWithSize:(CGSize)size andTheme:(Theme *)theme {
	BoardScene *res = [[BoardScene alloc] initWithSize:size andTheme:theme];
	return res;
}

#pragma mark - Overriden Accessors

-(void)setTheme:(Theme *)theme {
	_theme = theme;
	self.backgroundColor = theme.boardColor;
	// Setup SKActions:
	self.scaleToFullSizeAction = [SKAction group:@[[SKAction scaleTo:1.0f duration:kAnimationDuration_TileContainerPopup],
												   [SKAction moveBy:CGVectorMake(-self.theme.tileWidth/2.0f, -self.theme.tileWidth/2.0f) duration:kAnimationDuration_TileContainerPopup]]];
	self.scaleToFullSizeAction_NewTile = [SKAction group:@[[SKAction scaleTo:1.0f duration:kAnimationDuration_TileContainerPopup * 2.0f],
												   [SKAction moveBy:CGVectorMake(-self.theme.tileWidth/2.0f, -self.theme.tileWidth/2.0f) duration:kAnimationDuration_TileContainerPopup * 2.0f]]];
	self.scaleFactor = 1+((self.size.width - 4 * self.theme.tileWidth)/5.0f)/self.theme.tileWidth;
	self.popUpNewTileAction = [SKAction sequence:@[[SKAction group:@[[SKAction scaleTo:self.scaleFactor duration:kAnimationDuration_TileContainerPopup], [SKAction moveBy:CGVectorMake(-self.theme.tileWidth*((self.scaleFactor - 1)/2.0f), -self.theme.tileWidth*((self.scaleFactor - 1)/2)) duration:kAnimationDuration_TileContainerPopup/2.0f], [SKAction fadeInWithDuration:kAnimationDuration_TileContainerPopup]]],
												   [SKAction group:@[[SKAction scaleTo:1.0f duration:kAnimationDuration_TileContainerPopup], [SKAction moveBy:CGVectorMake(self.theme.tileWidth*((self.scaleFactor - 1)/2.0f), self.theme.tileWidth*((self.scaleFactor - 1)/2)) duration:kAnimationDuration_TileContainerPopup]]]]];
	[self updateImagesAndUserIDs];
}

-(void)updateImagesAndUserIDs {
	// Get images and user ids:
	NSMutableDictionary *imagesDictionary = [NSMutableDictionary dictionary];
	NSMutableSet *userIDs = [NSMutableSet set];
	NSArray *tiles = [Tile allTiles];
	for (Tile *tile in tiles) {
		UIImage *image = tile.image;
		if (image) {
			if ((image = [self cropImageToRoundedRect:image]) != nil ) {
				imagesDictionary[@(tile.value)] = image;
			}
		}
		NSString *ID = tile.fbUserID;
		if (ID) {
			[userIDs addObject:ID];
		}
	}
	self.imagesForValues = imagesDictionary;
	self.userIDs = userIDs;
}

#pragma mark - Game Initialization Methods

-(void)initializePropertyLists{
	self.positionsForNodes = [NSMutableDictionary dictionary];
	self.positionForNewRandomTile = [NSMutableDictionary dictionary];
	self.positionForNewNodes = [NSMutableDictionary dictionary];
	self.indexesForNewNodes = [NSMutableDictionary dictionary];
	self.nodeForIndexes = [NSMutableDictionary dictionary];
	self.nextNodeForIndexes = [NSMutableDictionary dictionary];
	self.nextPositionsForNodes = [NSMutableDictionary dictionary];
	self.indexForNewRandomTile = [NSMutableDictionary dictionary];
	self.movingNodes = [NSMutableSet set];
	self.removingNodes = [NSMutableSet set];
}

-(void)initializeTileContainers:(CGSize) size {
	CGFloat tileWidth = self.theme.tileWidth;
	CGFloat edgeWidth = (size.width - 4 * (tileWidth))/5.0f;
	for (size_t row = 0; row < 4; ++row) {
		for (size_t col = 0; col < 4; col++) {
			SKShapeNode* tileContainer = [SKShapeNode node];
			CGPathRef path = CGPathCreateWithRoundedRect(CGRectMake(0,
																	0,
																	tileWidth,
																	tileWidth),
														 self.theme.tileCornerRadius,
														 self.theme.tileCornerRadius, nil);
			[tileContainer setPath: path];
			tileContainer.strokeColor = tileContainer.fillColor = self.theme.tileContainerColor;
			CGPoint pos = CGPointMake((col + 1) * edgeWidth + (col + 0.5) * tileWidth, (row + 1) * edgeWidth + (row + 0.5) * tileWidth);
			tileContainer.position = pos;
			tileContainer.xScale = tileContainer.yScale = 0.0f;
			[self addChild:tileContainer];
			self.tileContainers[row][col] = tileContainer;
		}
	}
}

// This method pops the tile containers
-(void)popupTileContainersAnimated:(BOOL) animated {
	if (animated) {
		int arr1[] = {0, 1, 2, 3};
		int arr2[] = {3, 1, 0, 2};
		// Shuffle the index array:
		for (size_t i = 0; i < 4; ++i) {
			int tempInd1 = arc4random()%4;
			int tempInd2 = arc4random()%4;
			int temp = arr1[tempInd1];
			arr1[tempInd1] = arr1[tempInd2];
			arr1[tempInd2] = temp;
			temp = arr2[tempInd1];
			arr2[tempInd1] = arr2[tempInd2];
			arr2[tempInd2] = temp;
		}
		// Doing this because we CANNOT reference an array inside block!
		// Maybe we can use recursion to make it prettier (recursive call completion block in another function), but I like this art.
		int a1 = arr1[0];
		int a2 = arr1[1];
		int a3 = arr1[2];
		int a4 = arr1[3];
		int b1 = arr2[0];
		int b2 = arr2[1];
		int b3 = arr2[2];
		int b4 = arr2[3];
		// Please don't remove any awesome comment in this method, that will probably result a compile error. ;)
		[self.tileContainers[a1][b2] runAction:self.scaleToFullSizeAction completion:^{/*                    Painting while Coding                        */
			[self.tileContainers[a2][b3] runAction:self.scaleToFullSizeAction completion:^{/* (The man will probably hit this line of comment.)           */
				[self.tileContainers[a1][b1] runAction:self.scaleToFullSizeAction completion:^{/*                                                         */
					[self.tileContainers[a4][b3] runAction:self.scaleToFullSizeAction completion:^{/*                                                     */
						[self.tileContainers[a2][b2] runAction:self.scaleToFullSizeAction completion:^{/*                                                 */
							[self.tileContainers[a3][b3] runAction:self.scaleToFullSizeAction completion:^{/*                                             */
								[self.tileContainers[a3][b4] runAction:self.scaleToFullSizeAction completion:^{/*                                         */
									[self.tileContainers[a2][b1] runAction:self.scaleToFullSizeAction completion:^{/*                                     */
										[self.tileContainers[a3][b1] runAction:self.scaleToFullSizeAction completion:^{/*                                 */
											[self.tileContainers[a2][b4] runAction:self.scaleToFullSizeAction completion:^{/*                             */
												[self.tileContainers[a4][b2] runAction:self.scaleToFullSizeAction completion:^{/*                         */
													[self.tileContainers[a3][b2] runAction:self.scaleToFullSizeAction completion:^{/*         O           */
														[self.tileContainers[a4][b1] runAction:self.scaleToFullSizeAction completion:^{/*    -|-          */
															[self.tileContainers[a4][b4] runAction:self.scaleToFullSizeAction completion:^{/* /\          */
																[self.tileContainers[a1][b3] runAction:self.scaleToFullSizeAction completion:^{/*         */
																	[self.tileContainers[a1][b4] runAction:self.scaleToFullSizeAction completion:^{/*     */
																		[self startGameFromBoard:self.board animated:animated];
																	}];
																}];
															}];
														}];
													}];
												}];
											}];
										}];
									}];
								}];
							}];
						}];
					}];
				}];
			}];
		}];
	} else {
		for (size_t i = 0; i < 4; ++i) {
			for (size_t j = 0; j < 4; ++j) {
				SKShapeNode *container = self.tileContainers[i][j];
				container.xScale = container.yScale = 1.0f;
				CGPoint point = container.position;
				container.position = CGPointMake(point.x - self.theme.tileWidth/2.0f, point.y - self.theme.tileWidth/2.0f);
			}
		}
		[self startGameFromBoard:[Board latestBoard] animated:animated];
	}
}

-(void)startGameFromBoard:(Board *)board animated:(BOOL)animated {
	if (board) {
		for (NSValue *value in [_positionsForNodes allKeys]) {
			if (value) {
				id tile = [value nonretainedObjectValue];
				if ([tile isKindOfClass:[TileSKShapeNode class]]) {
					[tile removeFromParent];
				}
			}
		}
		[_positionsForNodes removeAllObjects];
		if (animated) {
			[self enableButtonAndGestureInteractions:NO];
			self.board = board;
			self.score = self.board.score;
			self.gamePlaying = self.board.gameplaying;
			self.data = [self.board getBoardDataArray];
			
			CGFloat tileWidth = self.theme.tileWidth;
			void (^completion)() = nil;
			for (size_t row = 0; row < 4; ++row) {
				for (size_t col = 0; col < 4; col++) {
					if ([self.data[row][col] intValue] != 0) { // If it's not zero
						NSNumber *value = self.data[row][col];
						TileSKShapeNode *tile = [TileSKShapeNode node];
						CGPathRef path = CGPathCreateWithRoundedRect(CGRectMake(0,
																				0,
																				tileWidth,
																				tileWidth),
																	 self.theme.tileCornerRadius,
																	 self.theme.tileCornerRadius, nil);
						[tile setPath: path];
						tile.strokeColor = tile.fillColor = self.theme.tileColors[value];
						tile.theme = self.theme;
						[tile setValue:[value intValue]
								  text:[NSString stringWithFormat:@"%d", [value intValue]]
							 textColor:([value intValue] <= 4 ? self.theme.tileTextColor:[UIColor whiteColor])
								  type:self.tileType
								 image:self.imagesForValues[value]];
						CGPoint pos = [self getPositionFromRow:row andCol:col];
						self.positionsForNodes[[NSValue valueWithNonretainedObject:tile]] = [NSValue valueWithCGPoint:pos];
						self.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]] = tile;
						pos = CGPointMake(pos.x+tileWidth/2.0f, pos.y+tileWidth/2.0f);
						tile.position = pos;
						tile.xScale = tile.yScale = 0.0f;
						[self addChild:tile];
						if (self.gamePlaying == NO && row * col == 9) {
							completion = ^void() {
								[self.gameViewController showGameEndView];
							};
						}
						[tile runAction:self.scaleToFullSizeAction completion:completion];
					}
				}
			}
		
		} else {
			self.board = board;
			self.score = self.board.score;
			self.gamePlaying = self.board.gameplaying;
			self.data = [self.board getBoardDataArray];
			
			CGFloat tileWidth = self.theme.tileWidth;
			for (size_t row = 0; row < 4; ++row) {
				for (size_t col = 0; col < 4; col++) {
					if ([self.data[row][col] intValue] != 0) { // If it's not zero
						NSNumber *value = self.data[row][col];
						TileSKShapeNode *tile = [TileSKShapeNode node];
						CGPathRef path = CGPathCreateWithRoundedRect(CGRectMake(0,
																				0,
																				tileWidth,
																				tileWidth),
																	 self.theme.tileCornerRadius,
																	 self.theme.tileCornerRadius, nil);
						[tile setPath: path];
						tile.strokeColor = tile.fillColor = self.theme.tileColors[value];
						tile.theme = self.theme;
						[tile setValue:[value intValue]
								  text:[NSString stringWithFormat:@"%d", [value intValue]]
							 textColor:([value intValue] <= 4 ? self.theme.tileTextColor:[UIColor whiteColor])
								  type:self.tileType
								 image:self.imagesForValues[value]];
						CGPoint pos = [self getPositionFromRow:row andCol:col];
						self.positionsForNodes[[NSValue valueWithNonretainedObject:tile]] = [NSValue valueWithCGPoint:pos];
						self.nodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]] = tile;
						tile.position = pos;
						[self addChild:tile];
						if (self.gamePlaying == NO && row * col == 9) {
							[self.gameViewController showGameEndView];
						}
					}
				}
			}
		}
		if (_gameViewController.mode == GameViewControllerModePlay) {
			[self enableButtonAndGestureInteractions:YES];
		}
		[self updateScoresInView];
	}
}

#pragma mark - Swiping Animation

-(void)swipeToDirection:(BoardSwipeGestureDirection)direction withFraction:(CGFloat)fraction{
	fraction = MAX(0.0f, fraction);
	fraction = MIN(1.0f, fraction);
	for (TileSKShapeNode *node in self.movingNodes) {
		CGPoint originPos = [self.positionsForNodes[[NSValue valueWithNonretainedObject:node]] CGPointValue];
		CGPoint targetPos = [self.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node]] CGPointValue];
		targetPos.x = originPos.x + (targetPos.x - originPos.x)*fraction;
		targetPos.y = originPos.y + (targetPos.y - originPos.y)*fraction;
		node.position = targetPos;
	}
}

-(void)finishSwipeAnimationWithDuration:(NSTimeInterval) duration {
	// Disable gesture recognizers while finishing up animation
	[self enableGestureRecognizers:NO];
	NSUInteger count1 = 0;
	NSUInteger size1 = [self.movingNodes count];
	for (TileSKShapeNode *movedNode in self.movingNodes) {
		CGPoint targetPos = [self.nextPositionsForNodes[[NSValue valueWithNonretainedObject:movedNode]] CGPointValue];
		SKAction *action = [SKAction moveTo:targetPos duration:duration];
		count1++;
		// completion1: block executed after moving all the tiles.
		void (^completion1)() = nil;
		if (count1 >= size1) {
			completion1 = ^void() {
				NSUInteger count2 = 0;
				NSUInteger size2 = [[self.positionForNewNodes allKeys] count];
				NSArray *mergedTileNSValues = [self.positionForNewNodes allKeys];
				// If there are new merged tiles:
				if ([mergedTileNSValues count]) {
					for (NSValue *value in mergedTileNSValues) {
						TileSKShapeNode *mergedNode = [value nonretainedObjectValue];
						self.score += mergedNode.value;
						count2++;
						// completion2: block executed at after popped up merged tiles.
						void (^completion2)() = nil;
						if (count2 >= size2) {
							completion2 = ^void() {
								for (TileSKShapeNode *node in self.removingNodes) {
									[self.nextPositionsForNodes removeObjectForKey:[NSValue valueWithNonretainedObject:node]];
									[node removeFromParent];
								}
								for (NSValue *value in [self.positionForNewNodes allKeys]) {
									TileSKShapeNode *node = [value nonretainedObjectValue];
									self.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node]] = [NSValue valueWithCGPoint:node.position];
								}
								[self runActionsAfterShownMergedTiles];
							};
						}
						[mergedNode runAction:self.popUpNewTileAction completion:completion2];
					}
				} else {
					[self runActionsAfterShownMergedTiles];
				}
			};
		}
		[movedNode runAction:action completion:completion1];
	}
}

/* Using this method because:
 * If there are new merged tiles, we want to run this inside the completion block.
 * If there is not, we want to run it after tiles get moved.
 * Putting those code into a method reduce duplicated code.
 */
-(void)runActionsAfterShownMergedTiles {
	CGFloat tileWidth = self.theme.tileWidth;
	CGPoint p = [Board generateRandomAvailableCellPoint_Col_Row_FromCells2DArray: self.nextData];
	int row = (int)p.y;
	int col = (int)p.x;
	NSNumber *value = @([Tile generateRandomInitTileValue]);
	self.nextData[row][col] = value;
	
	TileSKShapeNode *tile = [TileSKShapeNode node];
	CGPathRef path = CGPathCreateWithRoundedRect(CGRectMake(0,
															0,
															tileWidth,
															tileWidth),
												 self.theme.tileCornerRadius,
												 self.theme.tileCornerRadius, nil);
	[tile setPath: path];
	CGPathRelease(path);
	tile.strokeColor = self.theme.tileColors[value];
	tile.fillColor = self.theme.tileColors[value];
	tile.theme = self.theme;
	[tile setValue:[value intValue]
			  text:[NSString stringWithFormat:@"%d", [value intValue]]
		 textColor:([value intValue] <= 4 ? self.theme.tileTextColor:[UIColor whiteColor])
			  type:self.tileType
			 image:self.imagesForValues[value]];
	CGPoint pos = [self getPositionFromRow:row andCol:col];
	self.nextPositionsForNodes[[NSValue valueWithNonretainedObject:tile]] = [NSValue valueWithCGPoint:pos];
	pos = CGPointMake(pos.x+tileWidth/2.0f, pos.y+tileWidth/2.0f);
	tile.position = pos;
	tile.xScale = tile.yScale = 0.0f;
	[self addChild:tile];
	// Done for new tile.
	[tile runAction:self.scaleToFullSizeAction_NewTile completion:^{
		self.data = self.nextData;
		self.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row, col)]] = tile;
		self.positionsForNodes = self.nextPositionsForNodes;
		self.nodeForIndexes = self.nextNodeForIndexes;
		[self updateGamePlaying_MaxOccuredDictionary];
		[self enableGestureRecognizers:YES];
		if (self.gamePlaying == NO) {
			[self.gameViewController showGameEndView];
		}
#ifdef DEBUG
		[self.board printBoard];
#endif
	}];
}

-(void)reverseSwipeAnimationWithDuration:(NSTimeInterval)duration {
	for (TileSKShapeNode *node in self.movingNodes) {
		CGPoint originPos = [self.positionsForNodes[[NSValue valueWithNonretainedObject:node]] CGPointValue];
		SKAction *action = [SKAction moveTo:originPos duration:duration];
		[node runAction:action];
	}
}

#pragma mark - Scale Animation

-(void)animateTileScaleToDirection:(BoardSwipeGestureDirection)direction withFraction: (CGFloat) fraction {
	fraction = MAX(0.0f, fraction);
	fraction = MIN(self.scaleFactor, fraction);
	CGFloat width = self.theme.tileWidth;
	CGFloat percentage = (self.scaleFactor - 1.0f) * fraction;
	percentage /= 3.0f;
	CGFloat scale = 1.0f + percentage;
	CGFloat posDiff = percentage * width;
	if (direction == BoardSwipeGestureDirectionLeft) {
		for (NSValue *value in [self.positionsForNodes allKeys]) {
			TileSKShapeNode *node = [value nonretainedObjectValue];
			CGPoint pos = [self.positionsForNodes[value] CGPointValue];
			node.position = CGPointMake(pos.x - posDiff, pos.y);
			node.xScale = scale;
		}
	} else if (direction == BoardSwipeGestureDirectionRight) {
		for (NSValue *value in [self.positionsForNodes allKeys]) {
			TileSKShapeNode *node = [value nonretainedObjectValue];
			node.xScale = scale;
		}
	} else if (direction == BoardSwipeGestureDirectionUp) {
		for (NSValue *value in [self.positionsForNodes allKeys]) {
			TileSKShapeNode *node = [value nonretainedObjectValue];
			node.yScale = scale;
		}
	} else if (direction == BoardSwipeGestureDirectionDown) {
		for (NSValue *value in [self.positionsForNodes allKeys]) {
			TileSKShapeNode *node = [value nonretainedObjectValue];
			CGPoint pos = [self.positionsForNodes[value] CGPointValue];
			node.position = CGPointMake(pos.x, pos.y - posDiff);
			node.yScale = scale;;
		}
	}
}

-(void)reverseTileScaleAnimationWithDuration:(NSTimeInterval)duration {
	[self enableGestureRecognizers:NO];
	NSUInteger size = [[self.positionsForNodes allKeys] count];
	NSUInteger count = 0;
	void(^completion)() = nil;
	for (NSValue *value in [self.positionsForNodes allKeys]) {
		count++;
		TileSKShapeNode *node = [value nonretainedObjectValue];
		CGPoint pos = [self.positionsForNodes[value] CGPointValue];
		SKAction *restoreAction = [SKAction group:@[[SKAction moveTo:pos duration:duration],
											  [SKAction scaleTo:1.0f duration:duration]]];
		if (count >= size) {
			completion = ^(void){
				[self enableGestureRecognizers:YES];
			};
		}
		[node runAction:restoreAction completion:completion];
	}
}

#pragma mark - Analysis Algorithm

-(BOOL)analyzeTilesForSwipeDirection:(BoardSwipeGestureDirection) direction completion:(void (^)(void))completion {
	BOOL res = YES;
	if (self.gamePlaying && [self dataCanBeSwippedToDirection:direction]) {
		[self resetAnalyzedData];
		self.nextDirection = direction; // Set the direction for current last board
		if (direction == BoardSwipeGestureDirectionLeft) {
			for (int row = 0; row < 4; ++row) {
				NSMutableArray *rowArr = self.nextData[row];
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

						rowArr[col2] = @(0);
						rowArr[col3] = @(0);
						// Deals merging tile:
						[self processNewMergedTilesWithNewVal:newVal Row1:row Row2:row Row3:row Col1:col1 Col2:col2 Col3:col3];
						col2++;
						col3++;
					} else {
						newVal = [rowArr[col2] intValue];
						rowArr[col2] = @(0);
						// Deals moving tile:
						[self processMoveOneTileWithRow1:row Row2:row Col1:col1 Col2:col2];
						col2 = col3++;
					}
					rowArr[col1++] = @(newVal);
				}
				while (col1 < 4 && col2 < 4) {
					int newVal = [rowArr[col2] intValue];
					if (newVal != 0 && [self.nextData[row][col1] intValue] == 0) {
						// Deals moving tile:
						[self processMoveOneTileWithRow1:row Row2:row Col1:col1 Col2:col2];
						rowArr[col1++] = @(newVal);
						rowArr[col2] = @(0);
					}
					col2++;
				}
			}
		} else if (direction == BoardSwipeGestureDirectionRight) {
			for (int row = 0; row < 4; ++row) {
				NSMutableArray *rowArr = self.nextData[row];
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
						rowArr[col2] = @(0);
						rowArr[col3] = @(0);
						// Deals merging tile:
						[self processNewMergedTilesWithNewVal:newVal Row1:row Row2:row Row3:row Col1:col1 Col2:col2 Col3:col3];
						col2--;
						col3--;
					} else {
						newVal = [rowArr[col2] intValue];
						rowArr[col2] = @(0);
						// Deals moving tile:
						[self processMoveOneTileWithRow1:row Row2:row Col1:col1 Col2:col2];
						col2 = col3--;
					}
					rowArr[col1--] = @(newVal);
				}
				while (col1 >= 0 && col2 >= 0) {
					int newVal = [rowArr[col2] intValue];
					if (newVal != 0 && [self.nextData[row][col1] intValue] == 0) {
						// Deals moving tile:
						[self processMoveOneTileWithRow1:row Row2:row Col1:col1 Col2:col2];
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
					if ([self.nextData[row2][col] intValue] == 0) {
						++row2;
						++row3;
						continue;
					}
					if ([self.nextData[row3][col] intValue] == 0) {
						++row3;
						continue;
					}
					// If both formerTileInd and nextTileInd are not zero, the following code get executed.
					int newVal = 0;
					if ([self.nextData[row2][col] intValue] == [self.nextData[row3][col] intValue] && row2 != row3) {
						newVal = 2 * [self.nextData[row2][col] intValue];
						self.nextData[row2][col] = @(0);
						self.nextData[row3][col] = @(0);
						// Deals merging tile:
						[self processNewMergedTilesWithNewVal:newVal Row1:row1 Row2:row2 Row3:row3 Col1:col Col2:col Col3:col];
						row2++;
						row3++;
					} else {
						newVal = [self.nextData[row2][col] intValue];
						self.nextData[row2][col] = @(0);
						// Deals moving tile:
						[self processMoveOneTileWithRow1:row1 Row2:row2 Col1:col Col2:col];
						row2 = row3++;
					}
					self.nextData[row1++][col] = @(newVal);
				}
				while (row1 < 4 && row2 < 4) {
					int newVal = [self.nextData[row2][col] intValue];
					if (newVal != 0 && [self.nextData[row1][col] intValue] == 0) {
						// Deals moving tile:
						[self processMoveOneTileWithRow1:row1 Row2:row2 Col1:col Col2:col];
						self.nextData[row1++][col] = @(newVal);
						self.nextData[row2][col] = @(0);
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
					if ([self.nextData[row2][col] intValue] == 0) {
						--row2;
						--row3;
						continue;
					}
					if ([self.nextData[row3][col] intValue] == 0) {
						--row3;
						continue;
					}
					// If both formerTileInd and nextTileInd are not zero, the following code get executed.
					int newVal = 0;
					if ([self.nextData[row2][col] intValue] == [self.nextData[row3][col] intValue] && row2 != row3) {
						newVal = 2 * [self.nextData[row2][col] intValue];
						self.nextData[row2][col] = @(0);
						self.nextData[row3][col] = @(0);
						// Deals merging tile:
						[self processNewMergedTilesWithNewVal:newVal Row1:row1 Row2:row2 Row3:row3 Col1:col Col2:col Col3:col];
						row2--;
						row3--;
					} else {
						newVal = [self.nextData[row2][col] intValue];
						self.nextData[row2][col] = @(0);
						// Deals moving tile:
						[self processMoveOneTileWithRow1:row1 Row2:row2 Col1:col Col2:col];
						row2 = row3--;
					}
					self.nextData[row1--][col] = @(newVal);
				}
				while (row1 >= 0 && row2 >= 0) {
					int newVal = [self.nextData[row2][col] intValue];
					if (newVal != 0 && [self.nextData[row1][col] intValue] == 0) {
						// Deals moving tile:
						[self processMoveOneTileWithRow1:row1 Row2:row2 Col1:col Col2:col];
						self.nextData[row1--][col] = @(newVal);
						self.nextData[row2][col] = @(0);
					}
					row2--;
				}
			}
		}
		
	} else {
		res = NO;
	}
	// Run the completion block passed in
	if (completion) {
		completion();
	}
	return res;
}

-(BOOL)dataCanBeSwippedToDirection:(BoardSwipeGestureDirection) direction {
	if (direction == BoardSwipeGestureDirectionLeft) {
		for (size_t i = 0; i < 4; ++i) {
			NSArray *rowArr = self.data[i];
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
						return YES;
					} else {
						--j;
					}
				}
			}
		}
	} else if (direction == BoardSwipeGestureDirectionRight) {
		for (size_t i = 0; i < 4; ++i) {
			NSArray *rowArr = self.data[i];
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
						return YES;
					} else {
						++j;
					}
				}
			}
		}
	} else if (direction == BoardSwipeGestureDirectionUp) {
		for (size_t j = 0; j < 4; ++j) {
			NSArray *colArr = @[self.data[0][j], self.data[1][j], self.data[2][j], self.data[3][j]];
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
						return YES;
					} else {
						--j;
					}
				}
			}
		}
	} else if (direction == BoardSwipeGestureDirectionDown) {
		for (size_t j = 0; j < 4; ++j) {
			NSArray *colArr = @[self.data[0][j], self.data[1][j], self.data[2][j], self.data[3][j]];
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
						return YES;
					} else {
						++j;
					}
				}
			}
		}
	}
	return NO;
}

#pragma mark - Helper Methods

-(UIImage *)cropImageToRoundedRect:(UIImage *)image {
	UIImage *ret = nil;
	
    // This calculates the crop area.
	
    float originalWidth  = image.size.width;
    float originalHeight = image.size.height;
	
    float edge = fminf(originalWidth, originalHeight);
	
    float posX = (originalWidth   - edge) / 2.0f;
    float posY = (originalHeight  - edge) / 2.0f;
	
	
    CGRect cropSquare = CGRectZero;
	
	// If orientation indicates a change to portrait.
	if(image.imageOrientation == UIImageOrientationLeft ||
	   image.imageOrientation == UIImageOrientationRight) {
		cropSquare = CGRectMake(posY, posX, edge, edge);
	} else {
		cropSquare = CGRectMake(posX, posY, edge, edge);
	}
	
    // This performs the image cropping.
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropSquare);
	
    ret = [UIImage imageWithCGImage:imageRef
                              scale:image.scale
                        orientation:image.imageOrientation];
	
    CGImageRelease(imageRef);
	
	UIGraphicsBeginImageContextWithOptions(ret.size, NO, 0);
	
	// Add a clip before drawing anything, in the shape of an rounded rect
    CGRect rect = CGRectMake(0, 0, ret.size.width, ret.size.height);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.theme.tileCornerRadius * 4] addClip];
	
    // Draw your image
    [ret drawInRect:rect];
	
    // Get the image, here setting the UIImageView image
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
	
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
	
    return roundedImage;
}

-(CGPoint)getPositionFromRow:(size_t)row andCol: (size_t)col {
	SKShapeNode *container = self.tileContainers[(int)(3 - row)][(int)col];
	return container.position;
}

-(void)processMoveOneTileWithRow1:(int)row1 Row2:(int)row2 Col1:(int)col1 Col2:(int)col2 {
	if (col2 != col1 || row2 != row1) {
		NSValue *node = self.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row2, col2)]];
		[self.nextNodeForIndexes removeObjectForKey:[NSValue valueWithCGPoint:CGPointMake(row2, col2)]];
		self.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row1, col1)]] = node;
		self.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node]] = [NSValue valueWithCGPoint:[self getPositionFromRow:row1 andCol:col1]];
		[self.movingNodes addObject:node];
	}
}

-(void)processNewMergedTilesWithNewVal:(int32_t)newVal Row1:(int)row1 Row2:(int)row2 Row3:(int)row3 Col1:(int)col1 Col2:(int)col2 Col3:(int)col3 {
	CGFloat tileWidth = self.theme.tileWidth;
	TileSKShapeNode *node1 = self.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row2, col2)]];
	TileSKShapeNode *node2 = self.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row3, col3)]];
	
	[self.nextNodeForIndexes removeObjectForKey:[NSValue valueWithCGPoint:CGPointMake(row2, col2)]];
	[self.nextNodeForIndexes removeObjectForKey:[NSValue valueWithCGPoint:CGPointMake(row3, col3)]];
	
	/* Create new tile */
	TileSKShapeNode *node = [TileSKShapeNode node];
	CGPathRef path = CGPathCreateWithRoundedRect(CGRectMake(0,
															0,
															tileWidth,
															tileWidth),
												 self.theme.tileCornerRadius,
												 self.theme.tileCornerRadius, nil);
	[node setPath: path];
	CGPathRelease(path);
	node.strokeColor = node.fillColor = self.theme.tileColors[@(newVal)];
	node.theme = self.theme;
	[node setValue:newVal
			  text:[NSString stringWithFormat:@"%d", newVal]
		 textColor:(newVal <= 4 ? self.theme.tileTextColor:[UIColor whiteColor])
			  type:self.tileType
			 image:self.imagesForValues[@(newVal)]];
	CGPoint pos = [self getPositionFromRow:row1 andCol:col1];
	self.indexesForNewNodes[[NSValue valueWithNonretainedObject:node]] = [NSValue valueWithCGPoint:CGPointMake(row1, col1)];
	self.positionForNewNodes[[NSValue valueWithNonretainedObject:node]] = [NSValue valueWithCGPoint:pos];
	self.nextNodeForIndexes[[NSValue valueWithCGPoint:CGPointMake(row1, col1)]] = node;
	node.alpha = 0.0f; // Not visible for now
	node.position = pos;
	[self addChild:node];
	/* Done creating new tile */
	
	self.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node1]] = [NSValue valueWithCGPoint:[self getPositionFromRow:row1 andCol:col1]];
	self.nextPositionsForNodes[[NSValue valueWithNonretainedObject:node2]] = [NSValue valueWithCGPoint:[self getPositionFromRow:row1 andCol:col1]];
	
	if (col2 != col1 || row1 != row2) {[self.movingNodes addObject: node1];}
	[self.movingNodes addObject:node2];
	
	[self.removingNodes addObject:node1];
	[self.removingNodes addObject:node2];
}
-(void)resetAnalyzedData {
	self.nextDirection = BoardSwipeGestureDirectionNone; // Set the direction for current last board
	self.gamePlaying = YES;
	self.nextData = [NSMutableArray array];
	for (size_t row = 0; row < 4; ++row) {
		self.nextData[row] = [NSMutableArray array];
		for (size_t col = 0; col < 4; ++col) {
			self.nextData[row][col] = self.data[row][col];
		}
	}
	self.nextNodeForIndexes = [self.nodeForIndexes mutableCopy];
	self.nextPositionsForNodes = [self.positionsForNodes mutableCopy];
	self.movingNodes = [NSMutableSet set];
	self.removingNodes = [NSMutableSet set];
	self.positionForNewNodes = [NSMutableDictionary dictionary];
	self.indexesForNewNodes = [NSMutableDictionary dictionary];
	self.positionForNewRandomTile = [NSMutableDictionary dictionary];
	self.indexForNewRandomTile = [NSMutableDictionary dictionary];
}

-(void)updateGamePlaying_MaxOccuredDictionary {
	// Check to see if the game is still playing and update onboard tiles.
	self.gamePlaying = [Board gameEndFrom2DArray:self.data];
	self.board.swipeDirection = self.nextDirection;
	self.board = [Board createBoardWithBoardData:self.nextData
									 gamePlaying:self.gamePlaying
										   score:self.score
								  swipeDirection:BoardSwipeGestureDirectionNone];
	
	// Add this board to history
	[self.history addBoardsObject:self.board];
	
	// Update Best score
	GameManager *gManager = [GameManager sharedGameManager];
	if (self.score > gManager.bestScore) {
		gManager.bestScore = self.score;
	}
	
	NSMutableDictionary *maxOccuredDictionary = [[self.gManager getMaxOccuredDictionary] mutableCopy];
	NSMutableDictionary *occurTimeDictionary = [NSMutableDictionary dictionary];
	for (int i = 0; i < maxTilePower; ++i) {
		occurTimeDictionary[@((NSInteger)pow(2.0f, i + 1))] = @(0);
	}
	
	for (size_t i = 0; i < 4; ++i) { 
		for (size_t j = 0; j < 4; ++j) {
			if ([self.nextData[i][j] intValue] != 0) {
				occurTimeDictionary[self.nextData[i][j]] = @([occurTimeDictionary[self.nextData[i][j]] intValue] + 1);
			}
		}
	}
	
	for (int i = 0; i < maxTilePower; ++i) {
		if ([occurTimeDictionary[@((NSInteger)pow(2.0f, i + 1))] intValue] > [maxOccuredDictionary[@((NSInteger)pow(2.0f, i + 1))] intValue]) {
			maxOccuredDictionary[@((NSInteger)pow(2.0f, i + 1))] = occurTimeDictionary[@((NSInteger)pow(2.0f, i + 1))];
		}
	}
	
	[self.gManager setMaxOccuredDictionary:[maxOccuredDictionary copy]];
	[self updateScoresInView];
}

-(void)updateScoresInView {
	self.gameViewController.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
	self.gameViewController.bestScoreLabel.text = [NSString stringWithFormat:@"%d", self.gManager.bestScore];
}

-(void)enableGestureRecognizers:(BOOL)enabled {
	[self.gameViewController enableGestureRecognizers:enabled];
}

-(void)enableButtonAndGestureInteractions:(BOOL)enabled {
	[self.gameViewController enableButtonAndGestureInteractions:enabled];
}

@end

