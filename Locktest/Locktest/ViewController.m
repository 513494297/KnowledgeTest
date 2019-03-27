//
//  ViewController.m
//  Locktest
//
//  Created by 方 on 2019/3/15.
//  Copyright © 2019年 田化方. All rights reserved.
//

#import "ViewController.h"
#import "ChildOfBankManager.h"
#import "Bird.h"
#import "Plane.h"

#import <objc/runtime.h>

@interface ViewController ()//这就是类扩展Extension
@property (nonatomic,strong) NSMutableArray *tickets;
@property (nonatomic,assign) int soldCount;
@property (nonatomic,strong) NSConditionLock *condition;

@property (nonatomic, strong) NSArray        *array;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // [self forTest];//条件锁
    
   //  [self testTwo];//队列
    
   // [self KSmainQueueAsync];//同步异步
    
   // [self serph];//信号量方式
   
   // [self orderRequest];//依次请求
    
  //  [self reverStr];//反转字符串
    
  //  [self testArray];
    
  //  [self protocolTest];//面向接口
    
    [self performSelector:@selector(doesnotExit)];//消息转发
}

//消息转发第一步
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if(sel == @selector(doesnotExit)){
        //"v@:"   v 代表返回值为void，@ 表示self，: 表示_cmd。
        
        // class_addMethod([self class], sel, (IMP)newMethod, "v@:");//*** 这一行是动态的添加不存在的方法，注释掉会执行forwardingTargetForSelector。
        ////如果是C函数方法就用（IMP）newMethod，如果是OC方法就用class_getMethodImplementation **
        return YES;
    }
    
    return [super resolveInstanceMethod:sel];
}

//转发时新添加的方法  C风格的函数方法
void newMethod(id obj,SEL _cmd){
    NSLog(@"%s",__FUNCTION__);
}

//消息转发第二步
- (id)forwardingTargetForSelector:(SEL)aSelector{
    if(aSelector == @selector(doesnotExit)){
       // return [Plane new];//这一行让Plane去处理这个方法
        return nil;//返回nil则进入消息转发第三步
    }
    return [super forwardingTargetForSelector:aSelector];
}

//消息转发第三步

//3.1
//首先它会发送-methodSignatureForSelector:消息获得函数的参数和返回值类型。如果-methodSignatureForSelector:返回nil，Runtime则会发出-doesNotRecognizeSelector:消息，程序这时也就挂掉了。如果返回了一个函数签名，Runtime就会创建一个NSInvocation对象并发送-forwardInvocation:消息给目标对象。

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    if([NSStringFromSelector(aSelector) isEqualToString:@"doesnotExit"]){
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];//进入forwardInvocation
    }
    return [super methodSignatureForSelector:aSelector];
}

//3.2
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    SEL sel = anInvocation.selector;
    Plane * p = [Plane new];
    if([p respondsToSelector:sel]){
        [anInvocation invokeWithTarget:p];
    }
    else{
        [self doesNotRecognizeSelector:sel];
    }
}


- (void)protocolTest{
    ChildOfBankManager * m = [ChildOfBankManager new];
    [m dothingInOrder];
    
    
    
    id <FlyProtocol> flyBehviour = [Bird new];
    [flyBehviour fly];
    flyBehviour = [Plane new];
    [flyBehviour fly];
    
}

- (void)testArray{
    char *  c =   dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
    char * d =  dispatch_queue_get_label(dispatch_get_main_queue());
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    [mutableArray addObject:@"1"];
    
    self.array = [NSArray array];
    self.array = mutableArray;
    
    NSLog(@"array---%@",self.array);
    
    [mutableArray addObject:@"2"];
    
    NSLog(@"array---%@",self.array);
}

extern void
intTest(int a,NSString * b){
    //return a;
}

- (void)reverStr{
     NSMutableString *reverseString = [NSMutableString string];
    NSString * str = @"I am handsome";
    for(NSInteger i = str.length - 1; i>=0;i--){
        UniChar c = [str characterAtIndex:i];
        NSString * s = [NSString stringWithCharacters:&c length:1];
        [reverseString appendString:s];
    }
    NSLog(@"%@",reverseString);
}

- (void)orderRequest{
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore=dispatch_semaphore_create(1);
    
    
    for (int i=0; i<4; i++) {
        
        dispatch_sync(queue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            
            if (i==0) {
                sleep(3);
                NSLog(@"AAAAAAA");  //请求A
            }else if (i==1){
                sleep(5);
                NSLog(@"BBBBBBB"); //请求B
                
            }else if (i==2){
                sleep(4);
                NSLog(@"CCCCCCC"); //请求C
                
            }else if (i==3){
                sleep(2);
                NSLog(@"DDDDDDD");  //请求D
                
            }
            
            dispatch_semaphore_signal(semaphore);
            
        });
    }
      NSLog(@"所有请求完毕");
}

- (void)serph{
     dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    void(^block)(NSString *) = ^(NSString * str){
        sleep(3);
        NSLog(@"%@", str);
        dispatch_semaphore_signal(semaphore);
    };
    block(@"aa");
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"h执行完毕了");
}

- (void)testTwo{
  //  dispatch_queue_t DiapatchQueue = dispatch_queue_create("com.test.ser", DISPATCH_QUEUE_SERIAL);//串行队列
    
    dispatch_queue_t dDiapatchQueue = dispatch_queue_create("com.test.ser", DISPATCH_QUEUE_CONCURRENT);//并发队列
    
    dispatch_async(dDiapatchQueue, ^{
        NSLog(@"11111a11111");
    });
    
    dispatch_async(dDiapatchQueue, ^{
        //sleep(3);
        NSLog(@"22222222");
    });
    
    dispatch_async(dDiapatchQueue, ^{
          // sleep(3);
        NSLog(@"333333333");
    });
    
    NSLog(@"ffffffuckk");
    
}

- (void)forTest
{
    self.tickets = [NSMutableArray arrayWithCapacity:1];
    self.condition = [[NSConditionLock alloc]initWithCondition:0];
    NSThread *windowOne = [[NSThread alloc]initWithTarget:self selector:@selector(soldTicketOne) object:nil];
    [windowOne start];
    
    NSThread *windowTwo = [[NSThread alloc]initWithTarget:self selector:@selector(soldTicketTwo) object:nil];
    [windowTwo start];
    
    NSThread *windowTuiPiao = [[NSThread alloc]initWithTarget:self selector:@selector(tuiPiao) object:nil];
    [windowTuiPiao start];
    
    NSThread *windowtest = [[NSThread alloc]initWithTarget:self selector:@selector(test) object:nil];
    [windowtest start];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
    });
    
   
    
   
}

- (void)test{
    NSLog(@"test");
}

//一号窗口
-(void)soldTicketOne
{
    while (YES) {
        if(![self.condition tryLockWhenCondition:1]){
            NSLog(@"====一号窗口没票了，等别人退票");
        }
        [self.condition lockWhenCondition:1];
        NSLog(@"====在一号窗口买了一张票,%@",[self.tickets objectAtIndex:0]);
        [self.tickets removeObjectAtIndex:0];
        [self.condition unlockWithCondition:0];
//        [self.condition unlock]
    }
}
//二号窗口
-(void)soldTicketTwo
{
    while (YES) {
        NSLog(@"====二号窗口没票了，等别人退票");
        [self.condition lockWhenCondition:2];
        NSLog(@"====在二号窗口买了一张票,%@",[self.tickets objectAtIndex:0]);
        [self.tickets removeObjectAtIndex:0];
        [self.condition unlockWithCondition:0];
    }
}
- (void)tuiPiao
{
    while (YES) {
        sleep(3);
        [self.condition lockWhenCondition:0];
        [self.tickets addObject:@"南京-北京（退票）"];
        int x = arc4random() % 2;
        if (x == 1) {
            NSLog(@"====有人退票了，赶快去一号窗口买");
            [self.condition unlockWithCondition:1];
        }else
        {
            NSLog(@"====有人退票了，赶快去二号窗口买");
            [self.condition unlockWithCondition:2];
        }
    }
    
}


- (void)KSmainQueueAsync {
    NSLog(@"test start");
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(mainQueue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"block1 %@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(mainQueue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"block2 %@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(mainQueue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"block3 %@", [NSThread currentThread]);
        }
    });
    
    NSLog(@"test over");
}

@end
