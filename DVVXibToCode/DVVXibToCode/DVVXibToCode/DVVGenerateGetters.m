//
//  DVVGenerateGetters.m
//  DVVXibToCode
//
//  Created by 大威 on 2017/12/23.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import "DVVGenerateGetters.h"
#import "DVVConst.h"
#import "DVVGenerateHandler.h"

@implementation DVVGenerateGetters

+ (NSString *)generateGettersCodeWithViewsOrder:(NSArray<NSString *> *)viewsOrder
                                      viewsInfo:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)viewsInfo {
    
    __block NSMutableArray<NSString *> *codesArray = [NSMutableArray array];
    [viewsOrder enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary<NSString *, id> *viewInfo = viewsInfo[obj];
        if (!JudgeIsRoot(viewInfo[kViewUserLabel])) {
            __block NSMutableArray<NSString *> *tempArray = [NSMutableArray array];
            if ([viewInfo[kViewType] isEqualToString:kViewTypeUIView]) {
                // UIView
                [tempArray addObject:[NSString stringWithFormat:@"_%@ = [[%@ alloc] init];", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])]];
                [tempArray addObjectsFromArray:[self viewCodeWithViewInfo:viewInfo]];
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUILabel]) {
                // UILabel
                [tempArray addObjectsFromArray:[self labelCodeWithViewInfo:viewInfo]];
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUITextField]) {
                // UITextField
                [tempArray addObjectsFromArray:[self textFieldCodeWithViewInfo:viewInfo]];
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUITextView]) {
                // UITextView
                [tempArray addObjectsFromArray:[self textViewCodeWithViewInfo:viewInfo]];
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUIButton]) {
                // UIButton
                [tempArray addObjectsFromArray:[self buttonCodeWithViewInfo:viewInfo]];
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUIImageView]) {
                // UIImageView
                [tempArray addObjectsFromArray:[self imageViewCodeWithViewInfo:viewInfo]];
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUISwitch]) {
                // UISwitch
                [tempArray addObjectsFromArray:[self switchCodeWithViewInfo:viewInfo]];
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUITableView]) {
                // UITableView
                [tempArray addObjectsFromArray:[self tableViewCodeWithViewInfo:viewInfo]];
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUIScrollView]) {
                // UIScrollView
                [tempArray addObjectsFromArray:[self scrollViewCodeWithViewInfo:viewInfo]];
            }
            NSMutableArray *array = [NSMutableArray array];
            [tempArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [array addObject:[NSString stringWithFormat:@"    %@", obj]];
            }];
            [array insertObject:[self methodBeginLinesWithViewInfo:viewInfo] atIndex:0];
            [array addObject:[self methodEndLinesWithViewInfo:viewInfo]];
            [codesArray addObject:[array componentsJoinedByString:@"\n"]];
        }
    }];
    return [codesArray componentsJoinedByString:@"\n\n"];
}

+ (NSString *)methodBeginLinesWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableString *mstr = [NSMutableString string];
    NSString *first = [NSString stringWithFormat:@"- (%@ *)%@ {", ViewTypeToClassName(viewInfo[kViewType]), viewInfo[kViewUserLabel]];
    NSString *second = [NSString stringWithFormat:@"    if (!_%@) {", viewInfo[kViewUserLabel]];
    [mstr appendFormat:@"%@\n", first];
    [mstr appendString:second];
    return mstr;
}

+ (NSString *)methodEndLinesWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableString *mstr = [NSMutableString string];
    NSString *first = @"    }";
    NSString *second = [NSString stringWithFormat:@"    return _%@;", viewInfo[kViewUserLabel]];
    NSString *third = @"}";
    [mstr appendFormat:@"%@\n", first];
    [mstr appendFormat:@"%@\n", second];
    [mstr appendString:third];
    return mstr;
}

+ (NSString *)fontWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSDictionary *fontDescDict = viewInfo[kFontDescription];
    if (!fontDescDict) {
        return nil;
    }
    
    if ([fontDescDict[@"_type"] isEqualToString:@"boldSystem"]) {
        return [NSString stringWithFormat:@"[UIFont boldSystemFontOfSize:%@]", [self handleGetterFontSize:fontDescDict[@"_pointSize"]]];
    } else if ([fontDescDict[@"_type"] isEqualToString:@"system"]) {
        return [NSString stringWithFormat:@"[UIFont systemFontOfSize:%@]", [self handleGetterFontSize:fontDescDict[@"_pointSize"]]];
    } else {
        return nil;
    }
}

+ (NSString *)backgroundColorWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSString *str = [self colorWithKey:@"backgroundColor" colorInfo:viewInfo[kColorInfo]];
    if (str) {
        return [NSString stringWithFormat:@"_%@.backgroundColor = %@;", viewInfo[kViewUserLabel], str];
    } else {
        return nil;
    }
}

+ (NSString *)textColorWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSString *str = [self colorWithKey:@"textColor" colorInfo:viewInfo[kColorInfo]];
    if (str) {
        return [NSString stringWithFormat:@"_%@.textColor = %@;", viewInfo[kViewUserLabel], str];
    } else {
        return nil;
    }
}

+ (NSString *)titleColorWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSString *str = [self colorWithKey:@"titleColor" colorInfo:viewInfo[kUIButtonState][kColorInfo]];
    if (str) {
        return [NSString stringWithFormat:@"[_%@ setTitleColor:%@ forState:UIControlStateNormal];", viewInfo[kViewUserLabel], str];
    } else {
        return nil;
    }
}

+ (NSString *)colorWithKey:(NSString *)key colorInfo:(id)colorInfo {
    
    if (!key || !colorInfo) {
        return nil;
    }
    
    __block NSString *str = nil;
    
    NSString *kKey = @"_key";
    
    if ([colorInfo isKindOfClass:[NSDictionary class]]) {
        NSDictionary *colorDict = colorInfo;
        if ([colorDict[kKey] isEqualToString:key]) {
            str = [self colorWithDict:colorDict];
        }
    } if ([colorInfo isKindOfClass:[NSArray class]]) {
        NSArray<NSDictionary<NSString *, id> *> *colorsArray = colorInfo;
        [colorsArray enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull colorDict, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([colorDict[kKey] isEqualToString:key]) {
                str = [self colorWithDict:colorDict];
                *stop = YES;
            }
        }];
    }
    
    return str;
}

+ (NSString *)colorWithDict:(NSDictionary *)colorDict {
    
    NSString *kColorSpace = @"_colorSpace";
    NSString *kCustomColorSpace = @"_customColorSpace";
    NSString *kRed = @"_red";
    NSString *kGreen = @"_green";
    NSString *kBlue = @"_blue";
    NSString *kAlpha = @"_alpha";
    
    if (([colorDict[kColorSpace] isEqualToString:@"custom"] && [colorDict[kCustomColorSpace] isEqualToString:@"sRGB"]) ||
        [colorDict[kColorSpace] isEqualToString:@"calibratedRGB"]) {
        return [self handleGetterColorWithRed:colorDict[kRed] green:colorDict[kGreen] blue:colorDict[kBlue] alpha:colorDict[kAlpha]];
    } else {
        return nil;
    }
}

+ (NSString *)textAlignmentWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSString *str = nil;
    if (viewInfo[kTextAlignment]) {
        if ([viewInfo[kTextAlignment] isEqualToString:kTextAlignmentNatural]) {
            /*
             NSTextAlignmentNatural // 默认对齐方式
             */
        } else if ([viewInfo[kTextAlignment] isEqualToString:kTextAlignmentCenter]) {
            str = @"NSTextAlignmentCenter";
        } else if ([viewInfo[kTextAlignment] isEqualToString:kTextAlignmentRight]) {
            str = @"NSTextAlignmentRight";
        } else if ([viewInfo[kTextAlignment] isEqualToString:kTextAlignmentJustified]) {
            str = @"NSTextAlignmentJustified";
        }
        if (str) {
            str = [NSString stringWithFormat:@"_%@.textAlignment = %@;", viewInfo[kViewUserLabel], str];
        }
    }
    return str;
}

#pragma mark -

+ (NSMutableArray<NSString *> *)viewCodeWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableArray<NSString *> *codesArray = [NSMutableArray array];
    NSString *backgroundColor = [self backgroundColorWithViewInfo:viewInfo];
    if (backgroundColor) {
        [codesArray addObject:backgroundColor];
    }
    return codesArray;
}

+ (NSMutableArray<NSString *> *)labelCodeWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableArray<NSString *> *codesArray = [NSMutableArray array];
    [codesArray addObject:[NSString stringWithFormat:@"_%@ = [[%@ alloc] init];", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])]];
    [codesArray addObjectsFromArray:[self viewCodeWithViewInfo:viewInfo]];
    NSString *font = [self fontWithViewInfo:viewInfo];
    if (font) {
        [codesArray addObject:[NSString stringWithFormat:@"_%@.font = %@;", viewInfo[kViewUserLabel], font]];
    }
    if (viewInfo[kTextNumberOfLines]) {
        [codesArray addObject:[NSString stringWithFormat:@"_%@.numberOfLines = %@;", viewInfo[kViewUserLabel], viewInfo[kTextNumberOfLines]]];
    }
    NSString *textColor = [self textColorWithViewInfo:viewInfo];
    if (textColor) {
        [codesArray addObject:textColor];
    }
    NSString *textAlignment = [self textAlignmentWithViewInfo:viewInfo];
    if (textAlignment) {
        [codesArray addObject:textAlignment];
    }
    if (viewInfo[kText]) {
        [codesArray addObject:[NSString stringWithFormat:@"_%@.text = @\"%@\";", viewInfo[kViewUserLabel], viewInfo[kText]]];
    }
    return codesArray;
}

+ (NSMutableArray<NSString *> *)textFieldCodeWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableArray<NSString *> *codesArray = [NSMutableArray array];
    [codesArray addObject:[NSString stringWithFormat:@"_%@ = [[%@ alloc] init];", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])]];
    [codesArray addObjectsFromArray:[self viewCodeWithViewInfo:viewInfo]];
    NSString *font = [self fontWithViewInfo:viewInfo];
    if (font) {
        [codesArray addObject:[NSString stringWithFormat:@"_%@.font = %@;", viewInfo[kViewUserLabel], font]];
    }
    NSString *textColor = [self textColorWithViewInfo:viewInfo];
    if (textColor) {
        [codesArray addObject:textColor];
    }
    NSString *textAlignment = [self textAlignmentWithViewInfo:viewInfo];
    if (textAlignment) {
        [codesArray addObject:textAlignment];
    }
    if (viewInfo[kTextFieldPlaceholder]) {
        [codesArray addObject:[NSString stringWithFormat:@"_%@.placeholder = @\"%@\";", viewInfo[kViewUserLabel], viewInfo[kTextFieldPlaceholder]]];
    }
    return codesArray;
}

+ (NSMutableArray<NSString *> *)textViewCodeWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableArray<NSString *> *codesArray = [NSMutableArray array];
    [codesArray addObject:[NSString stringWithFormat:@"_%@ = [[%@ alloc] init];", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])]];
    [codesArray addObjectsFromArray:[self viewCodeWithViewInfo:viewInfo]];
    NSString *font = [self fontWithViewInfo:viewInfo];
    if (font) {
        [codesArray addObject:[NSString stringWithFormat:@"_%@.font = %@;", viewInfo[kViewUserLabel], font]];
    }
    NSString *textColor = [self textColorWithViewInfo:viewInfo];
    if (textColor) {
        [codesArray addObject:textColor];
    }
    NSString *textAlignment = [self textAlignmentWithViewInfo:viewInfo];
    if (textAlignment) {
        [codesArray addObject:textAlignment];
    }
    if (viewInfo[kTextViewString]) {
        [codesArray addObject:[NSString stringWithFormat:@"_%@.text = @\"%@\";", viewInfo[kViewUserLabel], viewInfo[kTextViewString][kTextViewText]]];
    }
    return codesArray;
}

+ (NSMutableArray<NSString *> *)buttonCodeWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableArray<NSString *> *codesArray = [NSMutableArray array];
    [codesArray addObject:[NSString stringWithFormat:@"_%@ = [%@ buttonWithType:UIButtonTypeSystem];", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])]];
    [codesArray addObjectsFromArray:[self viewCodeWithViewInfo:viewInfo]];
    NSString *font = [self fontWithViewInfo:viewInfo];
    if (font) {
        [codesArray addObject:[NSString stringWithFormat:@"_%@.titleLabel.font = %@;", viewInfo[kViewUserLabel], font]];
    }
    if (viewInfo[kUIButtonState]) {
        NSString *titleColor = [self titleColorWithViewInfo:viewInfo];
        if (titleColor) {
            [codesArray addObject:titleColor];
        }
        if (viewInfo[kUIButtonState][kUIButtonTitle]) {
            [codesArray addObject:[NSString stringWithFormat:@"[_%@ setTitle:@\"%@\" forState:UIControlStateNormal];", viewInfo[kViewUserLabel], viewInfo[kUIButtonState][kUIButtonTitle]]];
        }
    }

    return codesArray;
}

+ (NSMutableArray<NSString *> *)imageViewCodeWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableArray<NSString *> *codesArray = [NSMutableArray array];
    [codesArray addObject:[NSString stringWithFormat:@"_%@ = [[%@ alloc] init];", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])]];
    [codesArray addObjectsFromArray:[self viewCodeWithViewInfo:viewInfo]];
    if (viewInfo[kUIImageViewImage]) {
        if (viewInfo[kUIImageViewImage]) {
            [codesArray addObject:[NSString stringWithFormat:@"_%@.image = %@;", viewInfo[kViewUserLabel], [self handleGetterImage:viewInfo[kUIImageViewImage]]]];
        }
    }
    
    return codesArray;
}

+ (NSMutableArray<NSString *> *)switchCodeWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableArray<NSString *> *codesArray = [NSMutableArray array];
    [codesArray addObject:[NSString stringWithFormat:@"_%@ = [[%@ alloc] init];", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])]];
    [codesArray addObjectsFromArray:[self viewCodeWithViewInfo:viewInfo]];
    
    return codesArray;
}

+ (NSMutableArray<NSString *> *)tableViewCodeWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableArray<NSString *> *codesArray = [NSMutableArray array];
    NSString *str = nil;
    if ([viewInfo[kUITableViewStyle] isEqualToString:@"plain"]) {
        str = @"UITableViewStylePlain";
    }  else if ([viewInfo[kUITableViewStyle] isEqualToString:@"grouped"]) {
        str = @"UITableViewStyleGrouped";
    }
    [codesArray addObject:[NSString stringWithFormat:@"_%@ = [[UITableView alloc] initWithFrame:CGRectZero style:%@];", viewInfo[kViewUserLabel], str]];
    [codesArray addObjectsFromArray:[self viewCodeWithViewInfo:viewInfo]];
    
    return codesArray;
}

+ (NSMutableArray<NSString *> *)scrollViewCodeWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableArray<NSString *> *codesArray = [NSMutableArray array];
    [codesArray addObject:[NSString stringWithFormat:@"_%@ = [[%@ alloc] init];", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])]];
    [codesArray addObjectsFromArray:[self viewCodeWithViewInfo:viewInfo]];
    
    return codesArray;
}

#pragma mark -

+ (NSString *)handleGetterFontSize:(NSString *)fontSize {
    
    DVVGenerateHandler *handler = [DVVGenerateHandler shared];
    if (handler.delegate && [handler.delegate respondsToSelector:@selector(handleGetterFontSize:)]) {
        return [handler.delegate handleGetterFontSize:fontSize];
    } else {
        return fontSize;
    }
}

+ (NSString *)handleGetterColorWithRed:(NSString *)red green:(NSString *)green blue:(NSString *)blue alpha:(NSString *)alpha {
    
    NSString * (^colorCode)(void) = ^(void) {
        return [NSString stringWithFormat:@"[UIColor colorWithRed:%@ green:%@ blue:%@ alpha:%@]", red, green, blue, alpha];
    };
    DVVGenerateHandler *handler = [DVVGenerateHandler shared];
    if (handler.delegate && [handler.delegate respondsToSelector:@selector(handleGetterColorWithRed:green:blue:alpha:)]) {
        NSString *str = [handler.delegate handleGetterColorWithRed:red green:green blue:blue alpha:alpha];
        if (str) {
            return str;
        } else {
            return colorCode();
        }
    } else {
        return colorCode();
    }
}

+ (NSString *)handleGetterImage:(NSString *)image {
    
    NSString * (^imageCode)(void) = ^(void) {
        return [NSString stringWithFormat:@"[UIImage imageNamed:@\"%@\"]", image];
    };
    DVVGenerateHandler *handler = [DVVGenerateHandler shared];
    if (handler.delegate && [handler.delegate respondsToSelector:@selector(handleGetterImage:)]) {
        NSString *str = [handler.delegate handleGetterImage:image];
        if (str) {
            return str;
        } else {
            return imageCode();
        }
    } else {
        return imageCode();
    }
}

@end
