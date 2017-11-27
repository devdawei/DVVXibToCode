//
//  Cover.h
//  XibToCode
//
//  Created by dawei on 2017/9/30.
//  Copyright © 2017年 dawei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CoverXibType) {
    /* UIView */
    CoverXibTypeUIView,
    /* UIViewController */
    CoverXibTypeUIViewController,
    /* UITableViewCell */
    CoverXibTypeUITableViewCell,
    /* UICollectionViewCell */
    CoverXibTypeUICollectionViewCell,
};

@interface Cover : NSObject

- (NSString *)coverAtPath:(NSString *)path xibType:(CoverXibType)xibType;

@end
