//
//  DVVGenerateAddSubviews.m
//  DVVXibToCode
//
//  Created by 大威 on 2017/12/23.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import "DVVGenerateAddSubviews.h"
#import "DVVGenerateHandler.h"

@implementation DVVGenerateAddSubviews

+ (NSString *)generateAddViewsCodeWithViewsOrder:(NSArray<NSString *> *)viewsOrder
                                       viewsInfo:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)viewsInfo
                                         xibType:(DVVCoverXibType)xibType {
    
    __block NSMutableArray *codesArray = [NSMutableArray array];
    
    [viewsOrder enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary<NSString *, id> *viewInfo = viewsInfo[obj];
        if (!JudgeIsRoot(viewInfo[kViewUserLabel])) {
            NSString *code = [NSString stringWithFormat:@"[%@ addSubview:%@];", ViewNameAppendSelfPrefix(viewsInfo[viewInfo[kSuperViewID]][kViewUserLabel], xibType), ViewNameAppendSelfPrefix(viewsInfo[obj][kViewUserLabel], xibType)];
            [codesArray addObject:code];
        }
    }];
    
    return [codesArray componentsJoinedByString:@"\n"];
}

@end
