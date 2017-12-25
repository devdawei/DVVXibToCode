//
//  DVVGenerateGetters.h
//  DVVXibToCode
//
//  Created by 大威 on 2017/12/23.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVVGenerateGetters : NSObject

/**
 生成Getter方法代码
 */
+ (NSString *)generateGettersCodeWithViewsOrder:(NSArray<NSString *> *)viewsOrder
                                      viewsInfo:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)viewsInfo;

@end
