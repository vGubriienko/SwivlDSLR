//
//  SWAppDelegate.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/4/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <UIKit/UIKit.h>
//Analitycs for all classes
#import "Countly.h"

typedef NS_ENUM(NSInteger, SWScriptState) {
    SWScriptStateNone = 0,
    SWScriptStatePreparing,
    SWScriptStateRunning,
};

@class SWScript;
@class SWDSLRConfiguration;
@class SWAppDelegate;
@class SwivlCommonLib;

extern SWAppDelegate *swAppDelegate;

@interface SWAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) SwivlCommonLib *swivl;

@property (nonatomic, strong) SWScript *script;
@property (nonatomic, readonly) SWScriptState scriptState;
@property (nonatomic, assign) SWCameraInterface currentCameraInterface;
@property (nonatomic, strong) SWDSLRConfiguration *currentDSLRConfiguration;
@property (nonatomic, readonly) NSArray *availableDSLRConfigurations;

@end
