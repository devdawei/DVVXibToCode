//
//  DVVGenerateHandler.m
//  DVVXibToCode
//
//  Created by dawei on 2017/12/22.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import "DVVGenerateHandler.h"

@implementation DVVGenerateHandler

+ (instancetype)shared {
    static DVVGenerateHandler *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

@end
