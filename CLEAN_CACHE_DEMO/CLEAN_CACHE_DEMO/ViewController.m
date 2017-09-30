//
//  ViewController.m
//  CLEAN_CACHE_DEMO
//
//  Created by 冯明庆 on 16/11/16.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import "ViewController.h"

#import "CCCleaner.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    CCCleaner *cleaner = [CCCleaner sharedCCCleaner];
    CCCleaner *cleaner = CCCleaner.shared.ccEnableLog; // 开启错误日志输出
    
    /// 获得缓存大小
    NSString *stringCacheSize = [cleaner ccMutiCacheSize:nil
                                                sizeUnit:YES
                                              completion:^(CCCompletionStatus status, id item) {
        
    }];
    NSLog(@"Cache Size : %@",stringCacheSize);
    
    /// 清除缓存
    /*
    [cleaner ccStartCleanCacheByDefault:^(CCCompletionStatus status, id item) {
        
    }];
     */
    [cleaner ccStartCleanCacheByDefault:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
