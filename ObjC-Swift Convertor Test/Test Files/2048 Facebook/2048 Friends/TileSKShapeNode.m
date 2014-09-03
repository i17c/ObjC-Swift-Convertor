//
//  TileSKShapeNode.m
//  2048 FB
//
//  Created by Shuyang Sun on 4/20/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import "TileSKShapeNode.h"
#import "Tile+ModelLayer03.h"
#import "Theme.h"
#import "macro.h"
#import "BoardScene.h"

const NSTimeInterval kAnimationDuration_ImageFade = SCALED_ANIMATION_DURATION(0.2f);
const NSTimeInterval kAnimationDuration_ImageTransparent = SCALED_ANIMATION_DURATION(0.15f);
const CGFloat kAnimationImageTransparencyFraction = 0.3f;

@interface TileSKShapeNode()

@property (strong, nonatomic) SKLabelNode *labelNode;

@property (nonatomic, strong, readwrite) UIImage *image; // Read only in header file

@end

@implementation TileSKShapeNode

- (instancetype)init
{
    self = [super init];
    if (self) {
		
    }
    return self;
}

-(void)setValue:(int32_t)val
		   text:(NSString *)text
	  textColor:(UIColor *)textColor
		   type:(TileType)type
		  image:(UIImage *) image{
	self.value = val;
	self.textColor = textColor;
	self.displayText = text;
	self.type = type;
	self.image = image;
	if (self.type == TileTypeImage) {
		[self updateImage:image completion:^{
			[self createImageNode];
		}];
	}
}

#pragma mark - Image Layer Methods
-(BOOL)updateImage:(UIImage *)image completion:(void (^)(void))completion {
	UIImage *imageTemp;
	if (image) {
		imageTemp = image;
		// If the image is not offered, pull it from database.
	} else {
		Tile *tile = nil;
		if (self.value) {
			tile = [Tile tileWithValue:self.value];
		} else {
			return NO;
		}
		imageTemp = tile.image;
		if (!imageTemp) {return NO;}
	}
	self.image = imageTemp;
	[self createImageNode];
	if (completion) {
		completion();
	}
	return YES;
}

-(void)createImageNode {
	if (self.image) {
		[self.imageNode removeFromParent];
		self.imageNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:self.image] size:self.frame.size];
		self.imageNode.position = CGPointMake(self.theme.tileWidth/2.0f, self.theme.tileWidth/2.0f);
		if (self.type == TileTypeNumber) {
			self.imageNode.alpha = 0.0f;
		}
		[self addChild:self.imageNode];
	}
}

-(void)showImageAnimated:(BOOL)animated {
	if (!self.image) {
		[self updateImage:nil completion:^{
			[self createImageNode];
		}];
	}
	if (!self.imageNode) {
		[self createImageNode];
	}
	if (animated) {
		[self.imageNode runAction:[SKAction fadeInWithDuration:kAnimationDuration_ImageFade]];
	} else {
		self.imageNode.alpha = 1.0f;
	}
	self.type = TileTypeImage;
}

-(void)hideImageAnimated:(BOOL)animated {
	if (!self.image) {
		[self updateImage:nil completion:^{
			[self createImageNode];
		}];
	}
	if (!self.imageNode) {
		[self createImageNode];
	}
	if (animated) {
		[self.imageNode runAction:[SKAction fadeOutWithDuration:kAnimationDuration_ImageFade]];
	} else {
		self.imageNode.alpha = 0.0f;
	}
	self.type = TileTypeNumber;
}

-(void)transparentImageAnimated:(BOOL)animated {
	if (!self.image) {
		[self updateImage:nil completion:^{
			[self createImageNode];
		}];
	}
	if (!self.imageNode) {
		[self createImageNode];
	}
	if (animated) {
		[self.imageNode runAction:[SKAction fadeAlphaTo:kAnimationImageTransparencyFraction duration:kAnimationDuration_ImageTransparent]];
	} else {
		self.imageNode.alpha = kAnimationImageTransparencyFraction;
	}
}

-(void)opaqueImageAnimated:(BOOL)animated {
	if (!self.image) {
		[self updateImage:nil completion:^{
			[self createImageNode];
		}];
	}
	if (!self.imageNode) {
		[self createImageNode];
	}
	if (animated) {
		[self.imageNode runAction:[SKAction fadeInWithDuration:kAnimationDuration_ImageTransparent]];
	} else {
		self.imageNode.alpha = 1.0f;
	}
}

#pragma mark - Overridden Accessors

-(void)setDisplayText:(NSString *)displayText {
	_displayText = displayText;
	if (self.labelNode) { [self.labelNode removeFromParent]; }
	self.labelNode = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
	self.labelNode.fontSize = 25.0f;
	self.labelNode.fontColor = self.textColor;
	self.labelNode.text = displayText;
	self.labelNode.position = CGPointMake(self.theme.tileWidth/2.0f, self.theme.tileWidth/2.0f - 10);
	[self addChild:self.labelNode];
}

#pragma mark - Overridden NSObject Methods

-(id)copy {
	TileSKShapeNode *res = [super copy];
	[res setValue:self.value
			 text:self.displayText
		textColor:self.textColor
			 type:self.type
			image:self.image];
	return res;
}

-(void)dealloc {
	self.strokeColor = nil;
	self.fillColor = nil;
}
						  
@end
