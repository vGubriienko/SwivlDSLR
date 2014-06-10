//
//  SWConstants.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/12/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#define BATTERY_LOW_LEVEL 15

#define SW_NEED_HIDE_SIDE_BAR_NOTIFICATION @"SW_NEED_HIDE_SIDE_BAR_NOTIFICATION"
#define SW_NEED_SHOW_SIDE_BAR_NOTIFICATION @"SW_NEED_SHOW_SIDE_BAR_NOTIFICATION"

#define IS_IPHONE_4 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height == 480)

typedef NS_ENUM(NSInteger, SWCameraInterface)
{
    SWCameraInterfaceUSB = 0,
    SWCameraInterfaceTrigger,
};

typedef NS_ENUM(NSInteger, SWScriptType)
{
    SWScriptTypeTimelapse = 0,
    SWScriptTypeShot
};

#define SW_PAN_DEGREES_PER_ONE_MOTOR_STEP  (18.0 / 728.0)
#define SW_MOTOR_STEPS_FOR_ONE_DEGREE_PAN  (728.0 / 18.0)
#define SW_TILT_DEGREES_PER_ONE_MOTOR_STEP (18.0 / 2280.0)
#define SW_MOTOR_STEPS_FOR_ONE_DEGREE_TILT (2280.0 / 18.0)