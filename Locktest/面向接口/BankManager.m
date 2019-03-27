//
//  BankManager.m
//  Locktest
//
//  Created by 方 on 2019/3/27.
//  Copyright © 2019年 田化方. All rights reserved.
//

#import "BankManager.h"

@implementation BankManager

- (void)dothingInOrder{
    [self.delegate dosomething1];
    [self.delegate dosomething2];
}

@end
