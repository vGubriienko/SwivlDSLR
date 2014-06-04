//
//  SWBatteryLevelView.m
//  lecturer
//
//  Created by Zhenya Koval on 5/6/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWBatteryLevelView.h"

@interface SWBatteryLevelView ()
{
    UIView *_batteryLevelView;
    UIImageView *_baseLevelEmtyImg;
    UIImageView *_baseLevelFullImg;
    UILabel *_label;
}

@end

@implementation SWBatteryLevelView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    _baseLevelEmtyImg = [[UIImageView alloc] initWithFrame:self.bounds];
    _baseLevelEmtyImg.image = [UIImage imageNamed:@"battery-0"];
    _baseLevelEmtyImg.contentMode = UIViewContentModeScaleAspectFit;
    _baseLevelEmtyImg.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_baseLevelEmtyImg];
    
    _batteryLevelView = [[UIView alloc] initWithFrame:self.bounds];
    _batteryLevelView.clipsToBounds = YES;
    [self addSubview:_batteryLevelView];
    
    _baseLevelFullImg = [[UIImageView alloc] initWithFrame:self.bounds];
    _baseLevelFullImg.image = [UIImage imageNamed:@"battery-100"];
    _baseLevelFullImg.contentMode = UIViewContentModeScaleAspectFit;
    _baseLevelFullImg.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_batteryLevelView addSubview:_baseLevelFullImg];
    
    CGRect frame = self.bounds;
    frame.origin.x = frame.size.width / 8;
    frame.size.width -= frame.size.width / 4;
    _label = [[UILabel alloc] initWithFrame:frame];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor whiteColor];
    _label.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_label];
}

- (void)setLevel:(NSInteger)level
{
    NSInteger undefinedValue = -1;
    if (level == undefinedValue) {
        _label.text = @"Not available";
    } else {
        _label.text = [NSString stringWithFormat:@"%li%%", (long)level];
    }
    
    level = MIN(100, level);
    level = MAX(0, level);
    
    NSInteger maxViewWidth = _baseLevelFullImg.frame.size.width;
    CGRect frame = _batteryLevelView.frame;
    frame.size.width = (maxViewWidth * level) / 100;
    _batteryLevelView.frame = frame;
}

- (void)setShowPercentages:(BOOL)showPercentages
{
    _showPercentages = showPercentages;
    _label.hidden = !showPercentages;
}

@end
