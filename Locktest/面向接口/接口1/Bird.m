//
//  Bird.m
//  Locktest
//
//  Created by 方 on 2019/3/27.
//  Copyright © 2019年 田化方. All rights reserved.
//

#import "Bird.h"

@implementation Bird

- (void)fly{
    NSLog(@"%@Fly:%s", NSStringFromClass([self class]), __FUNCTION__);
}

@end
