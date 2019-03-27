//
//  ChildOfBankManager.m
//  Locktest
//
//  Created by 方 on 2019/3/27.
//  Copyright © 2019年 田化方. All rights reserved.
//

#import "ChildOfBankManager.h"

@implementation ChildOfBankManager
- (instancetype)init{
    if (self = [super init]) {
        self.delegate = self;
    }
    return self;
}

- (void)dosomething1{
    NSLog(@"子类执行1");
}

- (void)dosomething2{
    NSLog(@"子类执行2");
}


@end
