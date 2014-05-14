//
//  SWCameraConfiguration.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 5/12/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWDSLRConfiguration : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *ptpCommands;

@property (nonatomic, copy) NSDictionary *dictionary;

+ (instancetype)configurationWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)configurationsWithDictionaries:(NSArray *)dictionaries;

@end
