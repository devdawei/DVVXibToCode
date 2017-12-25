//
//  DVVCover.h
//  DVVXibToCode
//
//  Created by dawei on 2017/12/22.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVVConst.h"

@interface DVVCover : NSObject

- (NSString *)coverAtPath:(NSString *)path xibType:(DVVCoverXibType)xibType;

@end
