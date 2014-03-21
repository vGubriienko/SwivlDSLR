//
//  SWAppDelegate.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/4/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWScript;
@class SWAppDelegate;
@class SwivlCommonLib;

extern SWAppDelegate *swAppDelegate;

@interface SWAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) SwivlCommonLib *swivl;

@property (nonatomic, strong) SWScript *script;
@property (nonatomic, assign) SWCameraInterface currentCameraInterface;

@end
