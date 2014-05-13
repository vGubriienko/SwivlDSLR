//
//  SWCameraConfiguration.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 5/12/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWCameraConfiguration.h"

@implementation SWCameraConfiguration

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super init])) {
        _name = [dictionary[@"name"] copy];
        _ptpCommands = [dictionary[@"commands"] copy];
        _dictionary = [dictionary copy];
        
        NSAssert(_ptpCommands.count == 1 || _ptpCommands.count == 2, @"SWCameraConfiguration init failed: Invalid PTP commands count");
    }
    return self;
}

+ (instancetype)configurationWithDictionary:(NSDictionary *)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

+ (NSArray *)configurationsWithDictionaries:(NSArray *)dictionaries
{
    NSMutableArray *array = [@[] mutableCopy];
    for (NSDictionary *dictionary in dictionaries) {
        SWCameraConfiguration *conf = [SWCameraConfiguration configurationWithDictionary:dictionary];
        if (conf) {
            [array addObject:conf];
        }
    }
    return array;
}

@end
