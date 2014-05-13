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
    NSString *script =  @"1:%lx, 1M %lx, 2M %lx, 3M %lx, 4M F(          \
                        2:T4L+9M 0, %lx, %lx%@, 5, 0, AR                \
                        3:AL3=                                          \
                        4:T9L-4< F( 1L1-,5= 1M2@                        \
                        5:.                                             \
                        F:FM 7S T2L+EM                                  \
                        E:TEL-E< 3S T3L+EM                              \
                        D:TEL-D< FL)\0";
    return script;
}

- (NSString *)scriptTemplateForTriggerShot
{
    NSString *script = @"1:7ST7D0+1M2:T1L-2<3S.\0";
    return script;
}

- (NSString *)scriptTemplateForUSBTimelapse:(NSString *)ptpCommand1 ptpCommand2:(NSString *)ptpCommand2
{
    NSString *script =  [NSString stringWithFormat:
                         @"1:%%lx, 1M %%lx, 2M T2L+9M F(                \
                         2:0, %%lx, %%lx%%@, 5, 0, AR                   \
                         3:AL3=                                         \
                         4:T9L-4< T2L+9M F( 1L1-, 5= 1M2@               \
                         5:.                                            \
                         F:FM                                           \
                         D:3, 0, B%@P2019?D=2001-E#3, A%@P              \
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
                        @"1:%%lx, 1M %%lx, 2M T2L+9M F(                 \
                        2:0, %%lx, %%lx%%@, 5, 0, AR                    \
                        3:AL3=                                          \
                        4:T9L-4< T2L+9M F( 1L1-, 5= 1M2@                \
                        5:.                                             \
                        F:FM                                            \
                        D:%@P2019?D=                                    \
                        E:FL)\0", ptpCommand1];
    return script;
}

- (NSString *)scriptTemplateForUSBShot:(NSString *)ptpCommand1
{
    NSString *script = [NSString stringWithFormat:@"1:%@P2019?1=.\0", ptpCommand1];
    return script;
}

@end
