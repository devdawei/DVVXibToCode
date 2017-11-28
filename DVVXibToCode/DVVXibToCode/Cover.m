//
//  Cover.m
//  XibToCode
//
//  Created by dawei on 2017/9/30.
//  Copyright © 2017年 dawei. All rights reserved.
//

#import "Cover.h"
#import "XMLDictionary.h"

static NSString * const kViewId = @"_id";
static NSString * const kViewUserLabel = @"_userLabel";
static NSString * const kViewConstraint = @"constraint";

static NSString * const kHorizontalHugging = @"_horizontalHuggingPriority";
static NSString * const kVerticalHugging = @"_verticalHuggingPriority";
static NSString * const kHorizontalCompressionResistance = @"_horizontalCompressionResistancePriority";
static NSString * const kVerticalCompressionResistance = @"_verticalCompressionResistancePriority";

static NSString * const kRootView = @"__root";

static NSString * const kViewType = @"__type";
static NSString * const kViewTypeUIView = @"view";
static NSString * const kViewTypeUILabel = @"label";
static NSString * const kViewTypeUITextField = @"textField";
static NSString * const kViewTypeUITextView = @"textView";
static NSString * const kViewTypeUIButton = @"button";
static NSString * const kViewTypeUIImageView = @"imageView";
static NSString * const kViewTypeUITableView = @"tableView";
static NSString * const kViewTypeUISwitch = @"switch";
static NSString * const kSuperViewID = @"__superViewID";
static NSString * const kSubviews = @"__subviews";

// UILabel、UITextField、UITextView
static NSString * const kText = @"_text";
static NSString * const kTextAlignment = @"_textAlignment";
static NSString * const kTextAlignmentNatural = @"natural";
static NSString * const kTextAlignmentCenter = @"center";
static NSString * const kTextAlignmentRight = @"right";
static NSString * const kTextAlignmentJustified = @"justified";

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

@interface Cover ()

@property (nonatomic, assign) CoverXibType xibType;

@property (nonatomic, copy) NSMutableString *propertiesCode;
@property (nonatomic, copy) NSMutableString *layoutsCode;
@property (nonatomic, copy) NSMutableString *addSubviewsCode;
@property (nonatomic, copy) NSMutableString *gettersCode;

@end

@interface Cover ()

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSDictionary<NSString *, id> *> *viewsInfo;

@end

@implementation Cover

- (NSString *)coverAtPath:(NSString *)path xibType:(CoverXibType)xibType {
    _xibType = xibType;
    
    // 读取 xib 文件
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *data = [fileHandle readDataToEndOfFile];
    // XML数据 转换为 字典
    NSDictionary *root = [NSDictionary dictionaryWithXMLData:data];
    NSDictionary *view = nil;
    switch (_xibType) {
        case CoverXibTypeUIView:
        case CoverXibTypeUIViewController:
            view = root[@"objects"][@"view"];
            break;
        case CoverXibTypeUITableViewCell:
            view = root[@"objects"][@"tableViewCell"][@"tableViewCellContentView"];
            break;
        case CoverXibTypeUICollectionViewCell:
        {
            NSMutableDictionary *collectionViewCellInfo = ((NSDictionary *)(root[@"objects"][@"collectionViewCell"])).mutableCopy;
            NSDictionary *subviews = root[@"objects"][@"collectionViewCell"][@"view"][@"subviews"];
            collectionViewCellInfo[@"subviews"] = subviews;
            view = collectionViewCellInfo;
        }
            break;
            
        default:
            break;
    }
    NSLog(@"root:\n%@", root);
    NSLog(@"view:\n%@", view);
    
    // 寻找到所有的视图
    [self findViewFromDict:view superViewID:view[kViewId] viewType:kViewTypeUIView isRootView:YES];
    // 寻找到子视图
    [self findSubviews];
    NSLog(@"viewsInfo:\n%@", self.viewsInfo);
    
    // 生成属性代码
    [self generatePropertiesCode];
    // 生成添加视图代码
    [self generateAddViewCode];
    // 生成约束代码
    [self generateLayoutCode];
    // 生成Getter代码
    [self generateGetterCode];
    
    NSMutableString *mstr = [NSMutableString string];
    
    [mstr appendString:@"\n\n==============================================================\n"];
    [mstr appendString:_propertiesCode];
    [mstr appendString:@"==============================================================\n\n"];
    
    [mstr appendString:@"\n==============================================================\n"];
    [mstr appendString:_addSubviewsCode];
    [mstr appendString:@"==============================================================\n\n"];
    
    [mstr appendString:@"\n==============================================================\n"];
    [mstr appendString:_layoutsCode];
    [mstr appendString:@"==============================================================\n\n"];
    
    [mstr appendString:@"\n==============================================================\n"];
    [mstr appendString:_gettersCode];
    [mstr appendString:@"==============================================================\n\n"];
    
    return mstr.copy;
}

#pragma mark - 生成属性代码

- (void)generatePropertiesCode {
    
    _propertiesCode = [NSMutableString string];
    
    [self.viewsInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary<NSString *,id> * _Nonnull obj, BOOL * _Nonnull stop) {
        if (!JudgeIsRoot(obj[kViewUserLabel])) {
            [_propertiesCode appendFormat:@"@property (nonatomic, strong) %@ *%@;\n", ViewTypeToClassName(obj[kViewType]), obj[kViewUserLabel]];
        }
    }];
}

#pragma mark - 生成添加视图代码

- (void)generateAddViewCode {
    
    _addSubviewsCode = [NSMutableString string];
    
    [self.viewsInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary<NSString *,id> * _Nonnull obj, BOOL * _Nonnull stop) {
        if (JudgeIsRoot(obj[kViewUserLabel])) {
            [self addViewCodeWithViewID:key];
            *stop = YES;
        }
    }];
}

- (void)addViewCodeWithViewID:(NSString *)viewID {
    
    __block NSMutableArray<NSString *> *subViewArray = [NSMutableArray array];
    // 寻找子视图
    [self.viewsInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary<NSString *,id> * _Nonnull obj, BOOL * _Nonnull stop) {
        if (!JudgeIsRoot(obj[kViewUserLabel]) &&
            obj[kSuperViewID] == viewID) {
            [subViewArray addObject:key];
        }
    }];
    // 添加子视图
    [subViewArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *str = [NSString stringWithFormat:@"[%@ addSubview:%@];", [self handleViewName:self.viewsInfo[viewID][kViewUserLabel]], [self handleViewName:self.viewsInfo[obj][kViewUserLabel]]];
        [self.addSubviewsCode appendFormat:@"%@\n", str];
    }];
    
    // 递归
    [subViewArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addViewCodeWithViewID:obj];
    }];
}

#pragma mark - 生成约束视图代码

- (void)generateLayoutCode {
    
    _layoutsCode = [NSMutableString string];
    
    [self.viewsInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary<NSString *,id> * _Nonnull obj, BOOL * _Nonnull stop) {
        id constraint =  obj[kViewConstraint];
        if ([constraint isKindOfClass:[NSArray class]]) {
            [((NSArray<NSDictionary *> *)constraint)  enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull subobj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *str = [self layoutCodeWithConstraintDict:subobj viewInfo:obj];
                [self.layoutsCode appendFormat:@"%@\n", str];
            }];
        } else if ([constraint isKindOfClass:[NSDictionary class]]) {
            NSString *str = [self layoutCodeWithConstraintDict:constraint viewInfo:obj];
            [self.layoutsCode appendFormat:@"%@\n", str];
        }
    }];
    
    [self.viewsInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary<NSString *,id> * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *str = [self huggingCompressionWithViewInfo:obj];
        if (str && str.length) {
            [self.layoutsCode appendFormat:@"%@\n", str];
        }
    }];
}

- (NSString *)layoutCodeWithConstraintDict:(NSDictionary<NSString *, id> *)constraintDict viewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    static NSString *kFirstAttribute = @"_firstAttribute";
    static NSString *kSecondAttribute = @"_secondAttribute";
    static NSString *kFirstItem = @"_firstItem";
    static NSString *kSecondItem = @"_secondItem";
    static NSString *kConstant = @"_constant";
    static NSString *kMultiplier = @"_multiplier";
    
    static NSString * (^ConvertAttributeName)(NSString *attributeName) = ^(NSString *attributeName) {
        if ([attributeName isEqualToString:@"leading"]) {
            return @"ALEdgeLeft";
        } else if ([attributeName isEqualToString:@"trailing"]) {
            return @"ALEdgeRight";
        } else if ([attributeName isEqualToString:@"top"]) {
            return @"ALEdgeTop";
        } else if ([attributeName isEqualToString:@"bottom"]) {
            return @"ALEdgeBottom";
        } else if ([attributeName isEqualToString:@"centerX"]) {
            return @"ALAxisVertical";
        } else if ([attributeName isEqualToString:@"centerY"]) {
            return @"ALAxisHorizontal";
        } else if ([attributeName isEqualToString:@"width"]) {
            return @"ALDimensionWidth";
        } else if ([attributeName isEqualToString:@"height"]) {
            return @"ALDimensionHeight";
        }
        return @"";
    };
    
    NSMutableString *layoutStr = nil;
    
    NSString *viewName = nil;
    NSString *ofViewName = nil;
    NSString *firstAttributeName = ConvertAttributeName(constraintDict[kFirstAttribute]);
    NSString *secondAttributeName = ConvertAttributeName(constraintDict[kSecondAttribute]);
    BOOL toSuper = NO;
    
    NSString * (^GetViewName)(NSString *viewID) = ^(NSString *viewID) {
        return [self handleViewName:self.viewsInfo[constraintDict[viewID]][kViewUserLabel]];
    };
    
    NSString * (^HandleMultiplier)(NSString *multiplier) = ^(NSString *multiplier) {
        NSArray<NSString *> *array = [multiplier componentsSeparatedByString:@":"];
        return [NSString stringWithFormat:@"%.2f/%.2f",array.firstObject.floatValue, array.lastObject.floatValue];
    };
    
    if ([firstAttributeName isEqualToString:@"ALEdgeLeft"] ||
        [firstAttributeName isEqualToString:@"ALEdgeRight"] ||
        [firstAttributeName isEqualToString:@"ALEdgeTop"] ||
        [firstAttributeName isEqualToString:@"ALEdgeBottom"]) {
        if ([constraintDict[kSecondItem] isEqualToString:viewInfo[kViewId]]) { // secondItem 是自己
            if ([viewInfo[kSubviews] containsObject:constraintDict[kFirstItem]]) {
                toSuper = YES;
                viewName = GetViewName(kFirstItem);
            } else {
                toSuper = NO;
                viewName = GetViewName(kFirstItem);
                ofViewName = GetViewName(kSecondItem);
            }
        } else {  // secondItem 不是自己
            if ([firstAttributeName isEqualToString:secondAttributeName]) {
                toSuper = YES;
                viewName = GetViewName(kSecondItem);
            } else {
                toSuper = NO;
                viewName = GetViewName(kFirstItem);
                ofViewName = GetViewName(kSecondItem);
            }
        }
        
        if (toSuper) {
            layoutStr = [NSMutableString stringWithFormat:@"[%@ autoPinEdgeToSuperviewEdge:%@", viewName, firstAttributeName];
            if (constraintDict[kConstant]) {
                [layoutStr appendFormat:@" withInset:%@", constraintDict[kConstant]];
            }
        } else {
            layoutStr = [NSMutableString stringWithFormat:@"[%@ autoPinEdge:%@ toEdge:%@ ofView:%@", viewName, firstAttributeName, secondAttributeName, ofViewName];
            if (constraintDict[kConstant]) {
                [layoutStr appendFormat:@" withOffset:%@", constraintDict[kConstant]];
            }
        }
        [layoutStr appendString:@"];"];
    } else if ([firstAttributeName isEqualToString:@"ALAxisVertical"] ||
               [firstAttributeName isEqualToString:@"ALAxisHorizontal"]) {
        if ([viewInfo[kSubviews] containsObject:constraintDict[kFirstItem]]) {
            toSuper = YES;
        }
        viewName = GetViewName(kFirstItem);
        ofViewName = GetViewName(kSecondItem);
        if (toSuper &&
            !constraintDict[kConstant] && !constraintDict[kMultiplier]) {
            layoutStr = [NSMutableString stringWithFormat:@"[%@ autoAlignAxisToSuperviewAxis:%@];", viewName, firstAttributeName];
        } else {
            NSMutableString *multiplierString = nil;
            NSMutableString *constantString = nil;
            if (!constraintDict[kMultiplier] &&
                !constraintDict[kConstant]) {
                layoutStr = [NSMutableString stringWithFormat:@"[%@ autoAlignAxis:%@ toSameAxisOfView:%@];", viewName, firstAttributeName, ofViewName];
            } else {
                if (constraintDict[kMultiplier]) {
                    multiplierString = [NSMutableString stringWithFormat:@"[%@ autoAlignAxis:%@ toSameAxisOfView:%@ withMultiplier:%@];", viewName, firstAttributeName, ofViewName, HandleMultiplier(constraintDict[kMultiplier])];
                }
                if (constraintDict[kConstant]) {
                    constantString = [NSMutableString stringWithFormat:@"[%@ autoAlignAxis:%@ toSameAxisOfView:%@ withOffset:%@];", viewName, firstAttributeName, ofViewName, constraintDict[kConstant]];
                }
                
                if (!layoutStr) {
                    layoutStr = [NSMutableString string];
                }
                if (multiplierString) {
                    [layoutStr appendFormat:@"%@", multiplierString];
                }
                if (constantString) {
                    if (multiplierString) {
                        [layoutStr appendFormat:@"\n%@", constantString];
                    } else {
                        [layoutStr appendFormat:@"%@", constantString];
                    }
                }
            }
        }
    } else if ([firstAttributeName isEqualToString:@"ALDimensionWidth"] ||
               [firstAttributeName isEqualToString:@"ALDimensionHeight"]) {
        NSMutableString *multiplierString = nil;
        NSMutableString *constantString = nil;
        if (!constraintDict[kFirstItem] &&
            !constraintDict[kSecondItem]) { // 没有 firstItem、secondItem
            viewName = [self handleViewName:viewInfo[kViewUserLabel]];
            ofViewName = nil;
            layoutStr = [NSMutableString stringWithFormat:@"[%@ autoSetDimension:%@ toSize:%@];", viewName, firstAttributeName, constraintDict[kConstant]];
        } else {
            if (constraintDict[kFirstItem]) { // 有 firstItem、secondItem
                viewName = GetViewName(kFirstItem);
                ofViewName = GetViewName(kSecondItem);
                
            } else { // 有 secondItem (Aspect Ratio)
                viewName = [self handleViewName:viewInfo[kViewUserLabel]];
                ofViewName = viewName;
            }
            
            if (!constraintDict[kMultiplier] &&
                !constraintDict[kConstant]) {
                layoutStr = [NSMutableString stringWithFormat:@"[%@ autoMatchDimension:%@ toDimension:%@ ofView:%@];", viewName, firstAttributeName, secondAttributeName, ofViewName];
            } else {
                if (constraintDict[kMultiplier]) {
                    multiplierString = [NSMutableString stringWithFormat:@"[%@ autoMatchDimension:%@ toDimension:%@ ofView:%@ withMultiplier:%@];", viewName, firstAttributeName, secondAttributeName, ofViewName, HandleMultiplier(constraintDict[kMultiplier])];
                }
                if (constraintDict[kConstant]) {
                    constantString = [NSMutableString stringWithFormat:@"[%@ autoMatchDimension:%@ toDimension:%@ ofView:%@ withOffset:%@];", viewName, firstAttributeName, secondAttributeName, ofViewName, constraintDict[kConstant]];
                }
                
                if (!layoutStr) {
                    layoutStr = [NSMutableString string];
                }
                if (multiplierString) {
                    [layoutStr appendFormat:@"%@", multiplierString];
                }
                if (constantString) {
                    if (multiplierString) {
                        [layoutStr appendFormat:@"\n%@", constantString];
                    } else {
                        [layoutStr appendFormat:@"%@", constantString];
                    }
                }
            }
        }
    }
    
    return layoutStr;
}

/// HuggingPriority、CompressionResistancePriority
- (NSString *)huggingCompressionWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSString *viewName = [self handleViewName:viewInfo[kViewUserLabel]];
    
    NSMutableArray *array = [NSMutableArray array];
    if (viewInfo[kHorizontalHugging]) {
        [array addObject:[NSString stringWithFormat:@"[%@ setContentHuggingPriority:%@ forAxis:UILayoutConstraintAxisVertical];", viewName, viewInfo[kHorizontalHugging]]];
    }
    if (viewInfo[kVerticalHugging]) {
        [array addObject:[NSString stringWithFormat:@"[%@ setContentHuggingPriority:%@ forAxis:UILayoutConstraintAxisVertical];", viewName, viewInfo[kVerticalHugging]]];
    }
    if (viewInfo[kHorizontalCompressionResistance]) {
        [array addObject:[NSString stringWithFormat:@"[%@ setContentHuggingPriority:%@ forAxis:UILayoutConstraintAxisVertical];", viewName, viewInfo[kHorizontalCompressionResistance]]];
    }
    if (viewInfo[kVerticalCompressionResistance]) {
        [array addObject:[NSString stringWithFormat:@"[%@ setContentHuggingPriority:%@ forAxis:UILayoutConstraintAxisVertical];", viewName, viewInfo[kVerticalCompressionResistance]]];
    }
    return [array componentsJoinedByString:@"\n"];
}

#pragma mark - 生成Getter代码

- (void)generateGetterCode {
    
    _gettersCode = [NSMutableString string];
    
    [self.viewsInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary<NSString *,id> * _Nonnull obj, BOOL * _Nonnull stop) {
        if (!JudgeIsRoot(obj[kViewUserLabel])) {
            NSMutableString *mstr = [NSMutableString stringWithString:[self methodBeginLinesWithViewInfo:obj]];
            if ([obj[kViewType] isEqualToString:kViewTypeUIView]) {
                [mstr appendFormat:@"        _%@ = [[%@ alloc] init];\n", obj[kViewUserLabel], ViewTypeToClassName(obj[kViewType])];
            } else if ([obj[kViewType] isEqualToString:kViewTypeUILabel] ||
                       [obj[kViewType] isEqualToString:kViewTypeUITextField] ||
                       [obj[kViewType] isEqualToString:kViewTypeUITextView]) {
                if ([obj[kViewType] isEqualToString:kViewTypeUILabel]) {
                    [mstr appendFormat:@"        _%@ = [[%@ alloc] init];\n", obj[kViewUserLabel], ViewTypeToClassName(obj[kViewType])];
                    if (obj[kText]) {
                        [mstr appendFormat:@"        _%@.text = @\"%@\";\n", obj[kViewUserLabel], obj[kText]];
                    }
                } else if ([obj[kViewType] isEqualToString:kViewTypeUITextField]) {
                    [mstr appendFormat:@"        _%@ = [[%@ alloc] init];\n", obj[kViewUserLabel], ViewTypeToClassName(obj[kViewType])];
                    if (obj[kTextFieldPlaceholder]) {
                        [mstr appendFormat:@"        _%@.placeholder = @\"%@\";\n", obj[kViewUserLabel], obj[kTextFieldPlaceholder]];
                    }
                } else if ([obj[kViewType] isEqualToString:kViewTypeUITextView]) {
                    [mstr appendFormat:@"        _%@ = [[%@ alloc] init];\n", obj[kViewUserLabel], ViewTypeToClassName(obj[kViewType])];
                    if (obj[kTextViewString]) {
                        [mstr appendFormat:@"        _%@.text = @\"%@\";\n", obj[kViewUserLabel], obj[kTextViewString][kTextViewText]];
                    }
                }
                if (obj[kTextAlignment]) {
                    [mstr appendFormat:@"        _%@.textAlignment = %@;\n", obj[kViewUserLabel], obj[kTextAlignment]];
                }
            } else if ([obj[kViewType] isEqualToString:kViewTypeUIButton]) {
                [mstr appendFormat:@"        _%@ = [%@ buttonWithType:UIButtonTypeSystem];\n", obj[kViewUserLabel], ViewTypeToClassName(obj[kViewType])];
                if (obj[kUIButtonState]) {
                    if (obj[kUIButtonState][kUIButtonTitle]) {
                        [mstr appendFormat:@"        [_%@ setTitle:@\"%@\" forState:UIControlStateNormal];\n", obj[kViewUserLabel], obj[kUIButtonState][kUIButtonTitle]];
                    }
                }
            } else if ([obj[kViewType] isEqualToString:kViewTypeUIImageView]) {
                [mstr appendFormat:@"        _%@ = [[%@ alloc] init];\n", obj[kViewUserLabel], ViewTypeToClassName(obj[kViewType])];
                if (obj[kUIImageViewImage]) {
                    if (obj[kUIImageViewImage]) {
                        [mstr appendFormat:@"        _%@.image = [UIImage imageNamed:@\"%@\"];\n", obj[kViewUserLabel], obj[kUIImageViewImage]];
                    }
                }
            } else if ([obj[kViewType] isEqualToString:kViewTypeUITableView]) {
                [mstr appendFormat:@"        _%@ = [[UITableView alloc] initWithFrame:CGRectZero style:%@];\n", obj[kViewUserLabel], obj[kUITableViewStyle]];
            } else if ([obj[kViewType] isEqualToString:kViewTypeUISwitch]) {
                [mstr appendFormat:@"        _%@ = [[%@ alloc] init];\n", obj[kViewUserLabel], ViewTypeToClassName(obj[kViewType])];
            }
            [mstr appendFormat:@"%@\n", [self methodEndLinesWithViewInfo:obj]];
            [self.gettersCode appendFormat:@"%@", mstr];
        }
    }];
}

- (NSString *)methodBeginLinesWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableString *mstr = [NSMutableString string];
    NSString *first = [NSString stringWithFormat:@"- (%@ *)%@ {", ViewTypeToClassName(viewInfo[kViewType]), viewInfo[kViewUserLabel]];
    NSString *second = [NSString stringWithFormat:@"    if (!_%@) {", viewInfo[kViewUserLabel]];
    [mstr appendFormat:@"%@\n", first];
    [mstr appendFormat:@"%@\n", second];
    return mstr;
}

- (NSString *)methodEndLinesWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableString *mstr = [NSMutableString string];
    NSString *first = @"    }";
    NSString *second = [NSString stringWithFormat:@"    return _%@;", viewInfo[kViewUserLabel]];
    NSString *third = @"}";
    [mstr appendFormat:@"%@\n", first];
    [mstr appendFormat:@"%@\n", second];
    [mstr appendFormat:@"%@\n", third];
    return mstr;
}

#pragma mark -

- (NSString *)handleViewName:(NSString *)viewName {
    if (JudgeIsRoot(viewName)) {
        switch (self.xibType) {
            case CoverXibTypeUIView:
                return @"self";
                break;
            case CoverXibTypeUIViewController:
                return @"self.view";
                break;
            case CoverXibTypeUITableViewCell:
            case CoverXibTypeUICollectionViewCell:
                return @"self.contentView";
                break;
                
            default:
                return @"self";
                break;
        }
    } else {
        return [NSString stringWithFormat:@"self.%@", viewName];
    }
}

static BOOL (^JudgeIsRoot)(NSString *obj) = ^(NSString *obj) {
    if ([obj isEqualToString:kRootView]) {
        return YES;
    } else {
        return NO;
    }
};

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
    } else if ([viewType isEqualToString:kViewTypeUITableView]) {
        return @"UITableView";
    } else if ([viewType isEqualToString:kViewTypeUISwitch]) {
        return @"UISwitch";
    }
    return @"UntreatedViewType"; // 未处理的视图类型
};

#pragma mark -

- (void)findSubviews {
    
    [self.viewsInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary<NSString *,id> * _Nonnull obj, BOOL * _Nonnull stop) {
        if (JudgeIsRoot(obj[kViewUserLabel])) {
            [self findSubviewsWithViewID:key];
            *stop = YES;
        }
    }];
}

- (void)findSubviewsWithViewID:(NSString *)viewID {
    
    __block NSMutableArray<NSString *> *subViewArray = [NSMutableArray array];
    // 寻找子视图
    [self.viewsInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary<NSString *,id> * _Nonnull obj, BOOL * _Nonnull stop) {
        if (!JudgeIsRoot(obj[kViewUserLabel]) &&
            obj[kSuperViewID] == viewID) {
            [subViewArray addObject:key];
        }
    }];
    // 添加子视图
    NSMutableDictionary *viewInfo = ((NSMutableDictionary *)(self.viewsInfo[viewID]));
    [viewInfo setObject:subViewArray forKey:kSubviews];
    
    // 递归
    [subViewArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self findSubviewsWithViewID:obj];
    }];
}

#pragma mark -

- (void)findViewFromDict:(NSDictionary<NSString *, id> *)dict superViewID:(NSString *)superViewID viewType:(NSString *)viewType isRootView:(BOOL)isRootView {
    
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    NSString *_id = (NSString *)dict[kViewId];
    d[kViewId] = _id;
    if (isRootView) {
        d[kViewUserLabel] = kRootView;
    } else {
        if (dict[kViewUserLabel]) {
            d[kViewUserLabel] = dict[kViewUserLabel];
        } else {
            d[kViewUserLabel] = viewType;
        }
    }
    d[kViewConstraint] = dict[@"constraints"][@"constraint"];
    d[kSuperViewID] = superViewID;
    d[kViewType] = viewType;
    self.viewsInfo[_id] = d;
    
    if (dict[kHorizontalHugging]) {
        d[kHorizontalHugging] = dict[kHorizontalHugging];
    }
    if (dict[kVerticalHugging]) {
        d[kVerticalHugging] = dict[kVerticalHugging];
    }
    if (dict[kHorizontalCompressionResistance]) {
        d[kHorizontalCompressionResistance] = dict[kHorizontalCompressionResistance];
    }
    if (dict[kVerticalCompressionResistance]) {
        d[kVerticalCompressionResistance] = dict[kVerticalCompressionResistance];
    }
    
    if ([viewType isEqualToString:kViewTypeUILabel] ||
        [viewType isEqualToString:kViewTypeUITextField] ||
        [viewType isEqualToString:kViewTypeUITextView]) {
        if (dict[kTextAlignment]) {
            if ([dict[kTextAlignment] isEqualToString:kTextAlignmentNatural]) {
                /*
                 d[kTextAlignment] = @"NSTextAlignmentNatural"; // 默认对齐方式
                 */
            } else if ([dict[kTextAlignment] isEqualToString:kTextAlignmentCenter]) {
                d[kTextAlignment] = @"NSTextAlignmentCenter";
            } else if ([dict[kTextAlignment] isEqualToString:kTextAlignmentRight]) {
                d[kTextAlignment] = @"NSTextAlignmentRight";
            } else if ([dict[kTextAlignment] isEqualToString:kTextAlignmentJustified]) {
                d[kTextAlignment] = @"NSTextAlignmentJustified";
            }
        }
        
        if ([viewType isEqualToString:kViewTypeUILabel]) {
            if (dict[kText]) {
                d[kText] = dict[kText];
            }
        }
        
        if ([viewType isEqualToString:kViewTypeUITextField]) {
            if (dict[kTextFieldPlaceholder]) {
                d[kTextFieldPlaceholder] = dict[kTextFieldPlaceholder];
            }
        }
        
        if ([viewType isEqualToString:kViewTypeUITextView]) {
            if (dict[kTextViewString]) {
                d[kTextViewString] = dict[kTextViewString];
            }
        }
    }
    
    if ([viewType isEqualToString:kViewTypeUIImageView]) {
        if (dict[kUIImageViewImage]) {
            d[kUIImageViewImage] = dict[kUIImageViewImage];
        }
    }
    
    if ([viewType isEqualToString:kViewTypeUIButton]) {
        if (dict[kUIButtonState]) {
            d[kUIButtonState] = dict[kUIButtonState];
        }
    }
    
    if ([viewType isEqualToString:kViewTypeUITableView]) {
        if ([dict[kUITableViewStyle] isEqualToString:@"plain"]) {
            d[kUITableViewStyle] = @"UITableViewStylePlain";
        }  else if ([dict[kUITableViewStyle] isEqualToString:@"grouped"]) {
            d[kUITableViewStyle] = @"UITableViewStyleGrouped";
        }
    }
    
    if ([dict objectForKey:@"subviews"]) {
        [self findSubviewsFromDict:dict[@"subviews"] superViewID:dict[kViewId]];
    }
}

- (void)findSubviewsFromDict:(NSDictionary<NSString *, id> *)dict superViewID:(NSString *)superViewID {
    
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [self findViewFromDict:obj superViewID:superViewID viewType:key isRootView:NO];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            [((NSArray<NSDictionary<NSString *, id> *> *)obj) enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self findViewFromDict:obj superViewID:superViewID viewType:key isRootView:NO];
            }];
        }
    }];
}

#pragma mark - Getter

- (NSMutableDictionary<NSString *,NSDictionary<NSString *,id> *> *)viewsInfo {
    if (!_viewsInfo) {
        _viewsInfo = [NSMutableDictionary dictionary];
    }
    return _viewsInfo;
}

@end
