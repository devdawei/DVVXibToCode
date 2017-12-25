//
//  DVVGenerateProperties.h
//  DVVXibToCode
//
//  Created by dawei on 2017/12/22.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVVGenerateProperties : NSObject

/**
 生成属性代码
 */
+ (NSString *)generatePropertiesCodeWithViewsOrder:(NSArray<NSString *> *)viewsOrder
                                         viewsInfo:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)viewsInfo;

@end
