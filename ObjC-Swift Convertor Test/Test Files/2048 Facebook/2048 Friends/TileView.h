//
//  TileView.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/8/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TileViewType) {
	TileViewTypeImage = 0,
	TileViewTypeNumber
};

@interface TileView : UIView

-(id)initWithFrame:(CGRect)frame
			 value: (int32_t)val
			  text: (NSString *)text
		 textColor: (UIColor *)textColor
			  type: (TileViewType) type;

@property (nonatomic) TileViewType type;

@property (nonatomic) int32_t val;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIColor *textColor;
@property (nonatomic) BOOL imageTransparent;

-(void)showImageLayerAnimated: (BOOL) animated;
-(void)hideImageLayerAnimated: (BOOL) animated;

@end
