//
//  SWScript+Template.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 5/12/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWScript.h"

@interface SWScript (Template)

- (NSString *)scriptTemplateForTriggerShot;
- (NSString *)scriptTemplateForTriggerTimelapse;

- (NSString *)scriptTemplateForUSBShot:(NSString *)ptpCommand;
- (NSString *)scriptTemplateForUSBShot:(NSString *)ptpCommand1 ptpCommand2:(NSString *)ptpCommand2;

- (NSString *)scriptTemplateForUSBTimelapse:(NSString *)ptpCommand;
- (NSString *)scriptTemplateForUSBTimelapse:(NSString *)ptpCommand1 ptpCommand2:(NSString *)ptpCommand2;

@end
