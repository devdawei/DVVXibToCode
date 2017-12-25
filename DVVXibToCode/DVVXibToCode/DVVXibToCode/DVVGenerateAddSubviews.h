//
//  DVVGenerateAddSubviews.h
//  DVVXibToCode
//
//  Created by 大威 on 2017/12/23.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVVConst.h"

@interface DVVGenerateAddSubviews : NSObject

/**
 生成添加视图代码
 */
+ (NSString *)generateAddViewsCodeWithViewsOrder:(NSArray<NSString *> *)viewsOrder
                                       viewsInfo:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)viewsInfo
                                         xibType:(DVVCoverXibType)xibType;

@end
