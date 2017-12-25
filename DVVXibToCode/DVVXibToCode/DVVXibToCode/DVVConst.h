//
//  DVVConst.h
//  DVVXibToCode
//
//  Created by dawei on 2017/12/22.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DVVCoverXibType) {
    /* UIView */
    DVVCoverXibTypeUIView,
    /* UIViewController */
    DVVCoverXibTypeUIViewController,
    /* UITableViewCell */
    DVVCoverXibTypeUITableViewCell,
    /* UICollectionViewCell */
    DVVCoverXibTypeUICollectionViewCell,
};

static NSString * const kRootView = @"__root__";
static NSString * const kViewType = @"__type__";
static NSString * const kSuperViewID = @"__superViewID__";
static NSString * const kSubviews = @"__subviews__";

static NSString * const kViewId = @"_id";
static NSString * const kViewUserLabel = @"_userLabel";
static NSString * const kViewConstraints = @"constraints";
static NSString * const kViewConstraint = @"constraint";

static NSString * const kHorizontalHugging = @"_horizontalHuggingPriority";
static NSString * const kVerticalHugging = @"_verticalHuggingPriority";
static NSString * const kHorizontalCompressionResistance = @"_horizontalCompressionResistancePriority";
static NSString * const kVerticalCompressionResistance = @"_verticalCompressionResistancePriority";

static NSString * const kViewTypeUIView = @"view";
static NSString * const kViewTypeUILabel = @"label";
static NSString * const kViewTypeUITextField = @"textField";
static NSString * const kViewTypeUITextView = @"textView";
static NSString * const kViewTypeUIButton = @"button";
static NSString * const kViewTypeUIImageView = @"imageView";
static NSString * const kViewTypeUISwitch = @"switch";
static NSString * const kViewTypeUITableView = @"tableView";
static NSString * const kViewTypeUIScrollView = @"scrollView";

// UILabel、UITextField、UITextView
static NSString * const kText = @"_text";
static NSString * const kColorInfo = @"color";
static NSString * const kFontDescription = @"fontDescription";
static NSString * const kTextAlignment = @"_textAlignment";
static NSString * const kTextAlignmentNatural = @"natural";
static NSString * const kTextAlignmentCenter = @"center";
static NSString * const kTextAlignmentRight = @"right";
static NSString * const kTextAlignmentJustified = @"justified";
static NSString * const kTextNumberOfLines = @"_numberOfLines";

// UITextField
static NSString * const kTextFieldPlaceholder = @"_placeholder";

// UITextView
static NSString * const kTextViewString = @"string";
static NSString * const kTextViewText = @"__text";

// UIButton
static NSString * const kUIButtonState = @"state";
static NSString * const kUIButtonTitle = @"_title";

static NSString * const kUIImageViewImage = @"_image";

// UITableView
static NSString * const kUITableViewStyle = @"_style";


/**
 判断是否为根视图

 @param obj kViewUserLabel的值
 @return YES: 是根视图  NO: 不是根视图
 */
static BOOL (^JudgeIsRoot)(NSString *obj) = ^(NSString *obj) {
    if ([obj isEqualToString:kRootView]) {
        return YES;
    } else {
        return NO;
    }
};

/**
 根据视图类型，获取对应的类名

 @param viewType kViewType的值
 @return 对应的类名
 */
static NSString * (^ViewTypeToClassName)(NSString *viewType) = ^(NSString *viewType) {
    if ([viewType isEqualToString:kViewTypeUIView]) {
        return @"UIView";
    } else if ([viewType isEqualToString:kViewTypeUILabel]) {
        return @"UILabel";
    } else if ([viewType isEqualToString:kViewTypeUITextField]) {
        return @"UITextField";
    } else if ([viewType isEqualToString:kViewTypeUITextView]) {
        return @"UITextView";
    } else if ([viewType isEqualToString:kViewTypeUIButton]) {
        return @"UIButton";
    } else if ([viewType isEqualToString:kViewTypeUIImageView]) {
        return @"UIImageView";
    } else if ([viewType isEqualToString:kViewTypeUISwitch]) {
        return @"UISwitch";
    } else if ([viewType isEqualToString:kViewTypeUITableView]) {
        return @"UITableView";
    } else if ([viewType isEqualToString:kViewTypeUIScrollView]) {
        return @"UIScrollView";
    }
    return @"UntreatedViewType"; // 未处理的视图类型
};

/**
 获取带有 self. 方式的视图名称

 @param viewName kViewUserLabel的值
 @return 处理后的视图名称
 */
static NSString * (^ViewNameAppendSelfPrefix)(NSString *obj, DVVCoverXibType xibType) = ^(NSString *obj, DVVCoverXibType xibType) {
    
    if (JudgeIsRoot(obj)) {
        switch (xibType) {
            case DVVCoverXibTypeUIView:
                return @"self";
                break;
            case DVVCoverXibTypeUIViewController:
                return @"self.view";
                break;
            case DVVCoverXibTypeUITableViewCell:
            case DVVCoverXibTypeUICollectionViewCell:
                return @"self.contentView";
                break;
                
            default:
                return @"self";
                break;
        }
    } else {
        return [NSString stringWithFormat:@"self.%@", obj];
    }
};

@interface DVVConst : NSObject

@end
