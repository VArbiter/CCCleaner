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
    
    /// 只是点击按钮才触发 , 不建议使用单例
//    CCCleaner *cleaner = [CCCleaner sharedCCCleaner];
    CCCleaner *cleaner = [[CCCleaner alloc] init];
    
    /// 获得缓存大小
    NSString *stringCacheSize = [cleaner ccStringGetCacheSizeWithFolderPath:nil
                                                               withSizeUnit:YES
                                                      withCompletionHandler:^(CCCompletionStatus status, id item) {
        
    }];
    NSLog(@"Cache Size : %@",stringCacheSize);
    
    /// 清除缓存
    /*
    [cleaner ccStartCleanCacheWithCompletionHandler:^(CCCompletionStatus status, id item) {
        
    }];
     */
    [cleaner ccStartCleanCacheWithCompletionHandler:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
