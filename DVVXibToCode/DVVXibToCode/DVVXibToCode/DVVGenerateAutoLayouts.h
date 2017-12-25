//
//  DVVGenerateAutoLayouts.h
//  DVVXibToCode
//
//  Created by dawei on 2017/12/22.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVVConst.h"

@interface DVVGenerateAutoLayouts : NSObject

/**
 生成自动布局代码
 */
+ (NSString *)generateAutoLayoutsCodeWithViewsOrder:(NSArray<NSString *> *)viewsOrder
                                          viewsInfo:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)viewsInfo
                                            xibType:(DVVCoverXibType)xibType;

@end
