//
//  SWMainControllerTests.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 5/20/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SWMainViewController.h"

@interface SWMainControllerTests : XCTestCase
{
    SWMainViewController *_mainController;
}
@end

@implementation SWMainControllerTests

- (void)setUp
{
    [super setUp];
    
    _mainController = [SWMainViewController new];
    [_mainController viewDidLoad];
}

- (void)tearDown
{
    _mainController = nil;
    
    [super tearDown];
}

- (void)testExample
{
    
}

@end
