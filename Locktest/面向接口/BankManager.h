//
//  BankManager.h
//  Locktest
//
//  Created by 方 on 2019/3/27.
//  Copyright © 2019年 田化方. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BankHandleDelegate <NSObject>

- (void)dosomething1;
- (void)dosomething2;

@end


@interface BankManager : NSObject

@property (nonatomic ,weak)id <BankHandleDelegate> delegate; ;

- (void)dothingInOrder;//保证两个方法顺序执行

@end

NS_ASSUME_NONNULL_END
