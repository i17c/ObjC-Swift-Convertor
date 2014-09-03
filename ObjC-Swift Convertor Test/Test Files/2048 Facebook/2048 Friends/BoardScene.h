//
//  BoardScene.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/19/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Board+ModelLayer03.h"
#import "TileSKShapeNode.h"

extern const NSTimeInterval kAnimationDuration_TileContainerPopup;

@class Theme;
@class Board;
@class GameViewController;
@class GameManager, History, Board;

@interface BoardScene : SKScene

#pragma mark - Scene Properties
@property (nonatomic, strong) Theme          * theme;
@property (nonatomic, strong) GameViewController *gameViewController;
@property (nonatomic, strong) NSMutableArray * data;
@property (nonatomic        ) int32_t        score;
@property (nonatomic        ) BOOL           gamePlaying;
@property (nonatomic, assign) TileType tileType;
@property (nonatomic        ) UIUserInterfaceIdiom       uiIdiom;
@property (nonatomic, strong) NSMutableDictionary *imagesForValues; // @(2):UIImage*
@property (nonatomic, strong) NSMutableSet *userIDs;

+(instancetype)sceneWithSize:(CGSize)size andTheme: (Theme *)theme;
-(instancetype)initWithSize:(CGSize)size andTheme: (Theme *)theme;
-(void)initializePropertyLists;

-(void)startGameFromBoard:(Board *)board animated:(BOOL)animated;

#pragma mark - Swipping Algorithm Properties
/// Animation phase 1
// NSValue(CGPoint): SKnode
@property (nonatomic, strong) NSMutableDictionary        *nodeForIndexes;// Tiles for current indexes (CGPoint(row, col))
@property (nonatomic, strong) NSMutableDictionary        *nextNodeForIndexes;// Tiles for indexes (CGPoint(row, col)) after swipe (not including the new random tile, but DO include the merged tiles) (technically this belongs to layer 2)

// SKNode: NSValue(CGPoint) dictionaries
@property (nonatomic, strong) NSMutableDictionary        *positionsForNodes;// Postion on board for all current tiles
@property (nonatomic, strong) NSMutableDictionary        *nextPositionsForNodes;// Position on board for all tiles after swipe (not including the new random tile or merged tile)

@property (nonatomic, strong) NSMutableSet               *movingNodes;// Set of all nodes will be moving
@property (nonatomic, strong) NSMutableSet               *removingNodes;// Set of all nodes will be moved after merging

/// Animation phase 2
@property (nonatomic, strong) NSMutableDictionary        *positionForNewNodes;// Position for merged new tiles
@property (nonatomic, strong) NSMutableDictionary        *indexesForNewNodes;// Position for merged new tiles

/// Animation phase 3
@property (nonatomic, strong) NSMutableDictionary        *positionForNewRandomTile;// Postion on board for the new random tile
@property (nonatomic, strong) NSMutableDictionary        *indexForNewRandomTile;// Get a CGPoint(row, col) from the new random tile

@property (nonatomic, strong) NSMutableArray             *tileContainers;// A 2d array of tile containers

// For Core Data
@property (nonatomic, strong) NSMutableArray             *nextData;
@property (nonatomic        ) BoardSwipeGestureDirection nextDirection;
@property (nonatomic        ) GameManager                *gManager;
@property (nonatomic        ) History                    *history;
@property (nonatomic, strong) Board                      *board;

// Frequently used SKActions:
@property (nonatomic, strong) SKAction                   *scaleToFullSizeAction;
@property (nonatomic, strong) SKAction                   *scaleToFullSizeAction_NewTile;
@property (nonatomic, strong) SKAction                   *popUpNewTileAction;

-(void)updateImagesAndUserIDs;

#pragma mark - Swipping Algorithm Methods

// For algorithms
-(CGPoint)getPositionFromRow:(size_t)row andCol: (size_t)col;
-(BOOL)dataCanBeSwippedToDirection:(BoardSwipeGestureDirection) direction;

-(void)swipeToDirection:(BoardSwipeGestureDirection)direction
		   withFraction:(CGFloat)fraction;
-(void)finishSwipeAnimationWithDuration:(NSTimeInterval) duration;
-(void)reverseSwipeAnimationWithDuration:(NSTimeInterval)duration;

-(void)resetAnalyzedData;
-(BOOL)analyzeTilesForSwipeDirection:(BoardSwipeGestureDirection) direction
						  completion:(void (^)(void))completion;

-(void)animateTileScaleToDirection:(BoardSwipeGestureDirection)direction withFraction: (CGFloat) fraction;
-(void)reverseTileScaleAnimationWithDuration:(NSTimeInterval)duration;

-(void)popupTileContainersAnimated:(BOOL) animated;

#pragma mark - Helper Methods
-(UIImage *)cropImageToRoundedRect:(UIImage *)image;

@end
