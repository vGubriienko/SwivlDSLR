//
//  SWScript+Template.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 5/12/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWScript+Template.h"

@implementation SWScript (Template)

- (NSString *)scriptTemplateForTriggerTimelapse
{
    
    NSString *script =  @"1:%lx,0M                                              \
                        %lx,1M                                                  \
                        %@,2M                                                   \
                        %lx,3M                                                  \
                        %@,4M                                                    \
                        %@,5M                                                  \
                        %lx,6M                                                  \
                        %lx,7M                                                  \
                        1L3L4L6,1,9R                                            \
                        2:9L2= T3E8+8M                                          \
                        3:T8L-3< F(                                             \
                                   4:0L7= T1L+8M 1L3L2L5,0,9R 1L3L5L5,1,CR      \
                                   5:9L5= CL5=                                  \
                                   6:T8L-6< F( 0L1-0M4@                         \
                                              7:.                               \
                                              F:FM 7S T6L+8M                    \
                                              E:T8L-E< 3S T7L+8M                \
                                              D:T8L-D< FL)\0";
    
    return script;
}

- (NSString *)scriptTemplateForTriggerShot
{
    NSString *script = @"1:7ST7D0+1M2:T1L-2<3S.\0";
    return script;
}

- (NSString *)scriptTemplateForUSBTimelapse:(NSString *)ptpCommand1 ptpCommand2:(NSString *)ptpCommand2
{
    NSString *script = [NSString stringWithFormat:
                        @"1:%%lx,0M                                     \
                        %%lx,1M                                         \
                        %%@,2M                                          \
                        %%lx,3M                                         \
                        %%@,4M                                           \
                        %%@,5M                                         \
                        1L3L4L6,1,9R                                    \
                        2:9L2= T3E8+8M                                  \
                        3:T8L-3< T1L+8M F(                              \
                        4:0L7= 1L3L2L5,0,9R 1L3L5L5,1,CR                \
                        5:9L5= CL5=                                     \
                        6:T8L-6< T1L+8M F( 0L1-0M4@                     \
                        7:.                                             \
                        F:FM                                            \
                        D:3, 0, B%@P2019?D=2001-E#3, A%@P               \
                        E:FL)\0", ptpCommand1, ptpCommand2];
    
    return script;
}

- (NSString *)scriptTemplateForUSBShot:(NSString *)ptpCommand1 ptpCommand2:(NSString *)ptpCommand2
{
    NSString *script = [NSString stringWithFormat:@"1:3,0,B%@P2019?1=2001-2#3,A%@P2:.\0", ptpCommand1, ptpCommand2];
    return script;
}

- (NSString *)scriptTemplateForUSBTimelapse:(NSString *)ptpCommand1
{
    NSString *script = [NSString stringWithFormat:
                        @"1:%%lx,0M                         \
                        %%lx,1M                             \
                        %%@,2M                              \
                        %%lx,3M                             \
                        %%@,4M                               \
                        %%@,5M                             \
                        1L3L4L6,1,9R                        \
                        2:9L2= T3E8+8M                      \
                        3:T8L-3< T1L+8M F(                  \
                        4:0L7= 1L3L2L5,0,9R 1L3L5L5,1,CR    \
                        5:9L5= CL5=                         \
                        6:T8L-6< T1L+8M F( 0L1-0M4@         \
                        7:.                                 \
                        F:FM                                \
                        D:%@P2019?D=FL)\0", ptpCommand1];
    return script;
}

- (NSString *)scriptTemplateForUSBShot:(NSString *)ptpCommand1
{
    NSString *script = [NSString stringWithFormat:@"1:%@P2019?1=.\0", ptpCommand1];
    return script;
}

@end
