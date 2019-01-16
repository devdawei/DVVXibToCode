//
//  DVVGenerateAutoLayouts.m
//  DVVXibToCode
//
//  Created by dawei on 2017/12/22.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import "DVVGenerateAutoLayouts.h"
#import "DVVGenerateHandler.h"

@implementation DVVGenerateAutoLayouts

+ (NSString *)generateAutoLayoutsCodeWithViewsOrder:(NSArray<NSString *> *)viewsOrder
                                          viewsInfo:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)viewsInfo
                                            xibType:(DVVCoverXibType)xibType {
    
    __block NSMutableArray<NSString *> *codesArray = [NSMutableArray array];
    [viewsOrder enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary<NSString *, id> *viewInfo = viewsInfo[obj];
        id constraint =  viewInfo[kViewConstraints][kViewConstraint];
        if ([constraint isKindOfClass:[NSArray class]]) {
            [((NSArray<NSDictionary *> *)constraint)  enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull subobj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *str = [self layoutCodeWithConstraintDict:subobj viewInfo:viewInfo viewsInfo:viewsInfo xibType:xibType];
                [codesArray addObject:str];
            }];
        } else if ([constraint isKindOfClass:[NSDictionary class]]) {
            NSString *str = [self layoutCodeWithConstraintDict:constraint viewInfo:viewInfo viewsInfo:viewsInfo xibType:xibType];
            [codesArray addObject:str];
        }
        NSString *str = [self huggingCompressionWithViewInfo:viewInfo xibType:xibType];
        if (str && str.length) {
            [codesArray addObject:str];
        }
    }];
    
    // 整理约束代码顺序
    __block NSMutableArray<NSString *> *codesOrderArray = [NSMutableArray array];
    [viewsOrder enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary<NSString *, id> *viewInfo = viewsInfo[obj];
        NSMutableArray<NSString *> *itemArray = [NSMutableArray array];
        [codesArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj componentsSeparatedByString:@" "].firstObject hasSuffix:viewInfo[kViewUserLabel]]) {
                [itemArray addObject:obj];
            }
        }];
        if (itemArray.count) {
            [codesOrderArray addObject:[itemArray componentsJoinedByString:@"\n"]];
        }
    }];
    
    return [codesOrderArray componentsJoinedByString:@"\n\n"];
}

+ (NSString *)layoutCodeWithConstraintDict:(NSDictionary<NSString *, id> *)constraintDict
                                  viewInfo:(NSDictionary<NSString *, id> *)viewInfo
                                 viewsInfo:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)viewsInfo
                                   xibType:(DVVCoverXibType)xibType {
    
    static NSString *kFirstAttribute = @"_firstAttribute";
    static NSString *kSecondAttribute = @"_secondAttribute";
    static NSString *kFirstItem = @"_firstItem";
    static NSString *kSecondItem = @"_secondItem";
    static NSString *kConstant = @"_constant";
    static NSString *kMultiplier = @"_multiplier";
    static NSString *kRelation = @"_relation";
    
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
    
    static NSString * (^ConvertRelation)(NSString *relation) = ^(NSString *relation) {
        if ([relation isEqualToString:@"greaterThanOrEqual"]) {
            return @"NSLayoutRelationGreaterThanOrEqual";
        } else if ([relation isEqualToString:@"lessThanOrEqual"]) {
            return @"NSLayoutRelationLessThanOrEqual";
        }
        // NSLayoutRelationEqual
        return @"";
    };
    
    NSMutableString *layoutStr = nil;
    
    NSString *viewName = nil;
    NSString *ofViewName = nil;
    NSString *firstAttributeName = ConvertAttributeName(constraintDict[kFirstAttribute]);
    NSString *secondAttributeName = ConvertAttributeName(constraintDict[kSecondAttribute]);
    
    BOOL toSuper = NO;
    
    NSString * (^GetViewName)(NSString *viewID) = ^(NSString *viewID) {
        return ViewNameAppendSelfPrefix(viewsInfo[constraintDict[viewID]][kViewUserLabel], xibType);
    };
    
    NSString * (^HandleMultiplier)(NSString *multiplier) = ^(NSString *multiplier) {
        NSArray<NSString *> *array = [multiplier componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":/"]];
        if (array.count == 1) {
            return [NSString stringWithFormat:@"%.2f",array.firstObject.floatValue];
        } else {
            return [NSString stringWithFormat:@"%.2f/%.2f",array.firstObject.floatValue, array.lastObject.floatValue];
        }
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
                if (constraintDict[kFirstItem] && constraintDict[kSecondItem]) {
                    toSuper = NO;
                    viewName = GetViewName(kFirstItem);
                    ofViewName = GetViewName(kSecondItem);
                } else {
                    toSuper = YES;
                    viewName = GetViewName(kSecondItem);
                }
            } else {
                toSuper = NO;
                viewName = GetViewName(kFirstItem);
                ofViewName = GetViewName(kSecondItem);
            }
        }
        
        if (toSuper) {
            layoutStr = [NSMutableString stringWithFormat:@"[%@ autoPinEdgeToSuperviewEdge:%@", viewName, firstAttributeName];
            if (constraintDict[kConstant]) {
                [layoutStr appendFormat:@" withInset:%@", [self handleAutoLayoutInsert:constraintDict[kConstant]]];
            }
        } else {
            layoutStr = [NSMutableString stringWithFormat:@"[%@ autoPinEdge:%@ toEdge:%@ ofView:%@", viewName, firstAttributeName, secondAttributeName, ofViewName];
            if (constraintDict[kConstant]) {
                [layoutStr appendFormat:@" withOffset:%@", [self handleAutoLayoutOffset:constraintDict[kConstant]]];
            }
        }
        if (constraintDict[kRelation]) {
            [layoutStr appendFormat:@" relation:%@", ConvertRelation(constraintDict[kRelation])];
        }
        [layoutStr appendString:@"];"];
    } else if ([firstAttributeName isEqualToString:@"ALAxisVertical"] ||
               [firstAttributeName isEqualToString:@"ALAxisHorizontal"]) {
        if ([viewInfo[kSubviews] containsObject:constraintDict[kFirstItem]] && [constraintDict[kSecondItem] isEqualToString:viewInfo[kViewId]]) {
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
                    constantString = [NSMutableString stringWithFormat:@"[%@ autoAlignAxis:%@ toSameAxisOfView:%@ withOffset:%@];", viewName, firstAttributeName, ofViewName, [self handleAutoLayoutOffset:constraintDict[kConstant]]];
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
            viewName = ViewNameAppendSelfPrefix(viewInfo[kViewUserLabel], xibType);
            ofViewName = nil;
            layoutStr = [NSMutableString stringWithFormat:@"[%@ autoSetDimension:%@ toSize:%@];", viewName, firstAttributeName, [self handleAutoLayoutSize:constraintDict[kConstant]]];
        } else {
            if (constraintDict[kFirstItem]) { // 有 firstItem、secondItem
                viewName = GetViewName(kFirstItem);
                ofViewName = GetViewName(kSecondItem);
                
            } else { // 有 secondItem (Aspect Ratio)
                viewName = ViewNameAppendSelfPrefix(viewInfo[kViewUserLabel], xibType);
                ofViewName = viewName;
            }
            
            if (!constraintDict[kMultiplier] &&
                !constraintDict[kConstant]) {
                layoutStr = [NSMutableString stringWithFormat:@"[%@ autoMatchDimension:%@ toDimension:%@ ofView:%@];", viewName, firstAttributeName, secondAttributeName, ofViewName];
            } else {
                if (constraintDict[kMultiplier]) {
                    multiplierString = [NSMutableString stringWithFormat:@"[%@ autoMatchDimension:%@ toDimension:%@ ofView:%@ withMultiplier:%@", viewName, firstAttributeName, secondAttributeName, ofViewName, HandleMultiplier(constraintDict[kMultiplier])];
                    if (constraintDict[kRelation]) {
                        [multiplierString appendFormat:@" relation:%@", ConvertRelation(constraintDict[kRelation])];
                    }
                    [multiplierString appendString:@"];"];
                }
                if (constraintDict[kConstant]) {
                    constantString = [NSMutableString stringWithFormat:@"[%@ autoMatchDimension:%@ toDimension:%@ ofView:%@ withOffset:%@", viewName, firstAttributeName, secondAttributeName, ofViewName, [self handleAutoLayoutOffset:constraintDict[kConstant]]];
                    if (constraintDict[kRelation]) {
                        [constantString appendFormat:@" relation:%@", ConvertRelation(constraintDict[kRelation])];
                    }
                    [constantString appendString:@"];"];
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
+ (NSString *)huggingCompressionWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo
                                     xibType:(DVVCoverXibType)xibType {
    
    NSString *viewName = ViewNameAppendSelfPrefix(viewInfo[kViewUserLabel], xibType);
    
    NSMutableArray *codesArray = [NSMutableArray array];
    if (viewInfo[kHorizontalHugging]) {
        [codesArray addObject:[NSString stringWithFormat:@"[%@ setContentHuggingPriority:%@ forAxis:UILayoutConstraintAxisHorizontal];", viewName, viewInfo[kHorizontalHugging]]];
    }
    if (viewInfo[kVerticalHugging]) {
        [codesArray addObject:[NSString stringWithFormat:@"[%@ setContentHuggingPriority:%@ forAxis:UILayoutConstraintAxisVertical];", viewName, viewInfo[kVerticalHugging]]];
    }
    if (viewInfo[kHorizontalCompressionResistance]) {
        [codesArray addObject:[NSString stringWithFormat:@"[%@ setContentCompressionResistancePriority:%@ forAxis:UILayoutConstraintAxisHorizontal];", viewName, viewInfo[kHorizontalCompressionResistance]]];
    }
    if (viewInfo[kVerticalCompressionResistance]) {
        [codesArray addObject:[NSString stringWithFormat:@"[%@ setContentCompressionResistancePriority:%@ forAxis:UILayoutConstraintAxisVertical];", viewName, viewInfo[kVerticalCompressionResistance]]];
    }
    return [codesArray componentsJoinedByString:@"\n"];
}

#pragma mark -

+ (NSString *)handleAutoLayoutInsert:(NSString *)insert {
    
    DVVGenerateHandler *handler = [DVVGenerateHandler shared];
    if (handler.delegate && [handler.delegate respondsToSelector:@selector(handleAutoLayoutInsert:)]) {
        return [handler.delegate handleAutoLayoutInsert:insert];
    } else {
        return insert;
    }
}

+ (NSString *)handleAutoLayoutOffset:(NSString *)offset {
    
    DVVGenerateHandler *handler = [DVVGenerateHandler shared];
    if (handler.delegate && [handler.delegate respondsToSelector:@selector(handleAutoLayoutOffset:)]) {
        return [handler.delegate handleAutoLayoutOffset:offset];
    } else {
        return offset;
    }
}

+ (NSString *)handleAutoLayoutSize:(NSString *)size {
    
    DVVGenerateHandler *handler = [DVVGenerateHandler shared];
    if (handler.delegate && [handler.delegate respondsToSelector:@selector(handleAutoLayoutSize:)]) {
        return [handler.delegate handleAutoLayoutSize:size];
    } else {
        return size;
    }
}

@end
