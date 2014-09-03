//
//  Theme.h
//  2048 FB
//
//  Created by Shuyang Sun on 4/2/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

// Change the order of this enum to change the order of themes in settings table.
typedef NS_ENUM(NSUInteger, ThemeType) {
	ThemeTypeDefault = 0,
	ThemeTypeNight,
	ThemeTypeLightBlue
};

extern const NSUInteger kglowingStartPowValueDefault;
extern const CGFloat kBoardCornerRadiusDefault_iPhone;
extern const CGFloat kBoardCornerRadiusDefault_iPad;
extern const CGFloat kTileCornerRadiusDefault_iPhone;
extern const CGFloat kTileCornerRadiusDefault_iPad;
extern const CGFloat kTileWidthDefault_iPhone;
extern const CGFloat kTileWidthDefault_iPad;
extern const CGFloat kButtonCornerRadiusDefault_iPhone;
extern const CGFloat kButtonCornerRadiusDefault_iPad;

extern NSString *const kThemePriceKey_Free;
extern NSString *const kThemePriceKey_Paid;

extern NSString *const kThemeIDDelimiter;
extern NSString *const kThemeID_Default;
extern NSString *const kThemeID_Night;
extern NSString *const kThemeID_LightBlue;

@interface Theme : NSObject

@property (nonatomic) ThemeType themeType;
@property (nonatomic, strong) NSString * uuid;
@property (nonatomic, strong) NSString * name;
@property (nonatomic) BOOL paid; // Indicate if the user need to pay to use the theme.
@property (nonatomic, readonly) NSInteger index; // Corresponding to ThemeType

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIColor *boardColor;
@property (nonatomic, strong) UIImage *boardImage;
@property (nonatomic, strong) UIColor *foldAnimationBackgroundColor;
@property (nonatomic, strong) UIColor *settingsPageColor;
@property (nonatomic, strong) UIImage *settingsPageImage;
@property (nonatomic, strong) UIColor *tileContainerColor;
@property (nonatomic, strong) UIColor *tileTextColor;
@property (nonatomic, strong) UIImage *tileContainerImage;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *buttonColor;
// This dictionary is using @{ (NSNumber *) tileValue : (UIColor *) tileColor}
@property (nonatomic, strong) NSDictionary *tileColors;
// Tile's image is stored in "Tile" object.
// Where does the glowing start.
@property (nonatomic) NSUInteger glowingStartPowValue;

// Corner radius.
@property (nonatomic) CGFloat boardCornerRadius;
@property (nonatomic) CGFloat tileCornerRadius;
@property (nonatomic) CGFloat tileWidth;
@property (nonatomic) CGFloat buttonCornerRadius;

+(Theme *)sharedThemeWithID: (NSString *)uuid;
+(Theme *)sharedThemeWithIndex: (NSUInteger)index;

// Return how many theme types are there.
+(NSUInteger)themeTypeCount;

@end
