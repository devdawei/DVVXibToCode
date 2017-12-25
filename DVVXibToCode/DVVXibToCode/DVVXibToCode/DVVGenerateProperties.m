//
//  DVVGenerateProperties.m
//  DVVXibToCode
//
//  Created by dawei on 2017/12/22.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import "DVVGenerateProperties.h"
#import "DVVConst.h"
#import "DVVGenerateHandler.h"

@implementation DVVGenerateProperties

+ (NSString *)generatePropertiesCodeWithViewsOrder:(NSArray<NSString *> *)viewsOrder
                                         viewsInfo:(NSDictionary<NSString *,NSDictionary<NSString *,id> *> *)viewsInfo {
    
    __block NSMutableArray *codesArray = [NSMutableArray array];
    
    [viewsOrder enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary<NSString *, id> *viewInfo = viewsInfo[obj];
        if (!JudgeIsRoot(viewInfo[kViewUserLabel])) {
            NSString *code = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@;", ViewTypeToClassName(viewInfo[kViewType]), viewInfo[kViewUserLabel]];
            [codesArray addObject:code];
        }
    }];
    
    return [codesArray componentsJoinedByString:@"\n"];
}

@end
