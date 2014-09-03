//
//  TileSKShapeNode.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/20/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Tile+ModelLayer03.h"

extern const NSTimeInterval kAnimationDuration_ImageFade;
extern const NSTimeInterval kAnimationDuration_ImageTransparent;
extern const CGFloat kAnimationImageTransparencyFraction;

@class Theme;

@interface TileSKShapeNode : SKShapeNode <NSCopying>

@property (nonatomic) int32_t value;
@property (strong, nonatomic) NSString *displayText;
@property (strong, nonatomic) SKColor *textColor;
@property (nonatomic) TileType type;
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong) SKSpriteNode *imageNode;

@property (nonatomic, strong) Theme *theme;

-(void)setValue:(int32_t)val
		   text:(NSString *)text
	  textColor:(UIColor *)textColor
		   type:(TileType)type
		  image:(UIImage *) image;

-(BOOL)updateImage:(UIImage *)image completion:(void (^)(void))completion;
-(void)showImageAnimated:(BOOL)animated;
-(void)hideImageAnimated:(BOOL)animated;
-(void)transparentImageAnimated:(BOOL)animated;
-(void)opaqueImageAnimated:(BOOL)animated;

@end
