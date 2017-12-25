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
            NSMutableString *mstr = [NSMutableString stringWithString:[self methodBeginLinesWithViewInfo:viewInfo]];
            if ([viewInfo[kViewType] isEqualToString:kViewTypeUIView]) {
                [mstr appendFormat:@"        _%@ = [[%@ alloc] init];\n", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])];
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUILabel] ||
                       [viewInfo[kViewType] isEqualToString:kViewTypeUITextField] ||
                       [viewInfo[kViewType] isEqualToString:kViewTypeUITextView]) {
                if ([viewInfo[kViewType] isEqualToString:kViewTypeUILabel]) {
                    [mstr appendFormat:@"        _%@ = [[%@ alloc] init];\n", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])];
                    if (viewInfo[kTextNumberOfLines]) {
                        [mstr appendFormat:@"        _%@.numberOfLines = %@;\n", viewInfo[kViewUserLabel], viewInfo[kTextNumberOfLines]];
                    }
                    if (viewInfo[kText]) {
                        [mstr appendFormat:@"        _%@.text = @\"%@\";\n", viewInfo[kViewUserLabel], viewInfo[kText]];
                    }
                } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUITextField]) {
                    [mstr appendFormat:@"        _%@ = [[%@ alloc] init];\n", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])];
                    if (viewInfo[kTextFieldPlaceholder]) {
                        [mstr appendFormat:@"        _%@.placeholder = @\"%@\";\n", viewInfo[kViewUserLabel], viewInfo[kTextFieldPlaceholder]];
                    }
                } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUITextView]) {
                    [mstr appendFormat:@"        _%@ = [[%@ alloc] init];\n", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])];
                    if (viewInfo[kTextViewString]) {
                        [mstr appendFormat:@"        _%@.text = @\"%@\";\n", viewInfo[kViewUserLabel], viewInfo[kTextViewString][kTextViewText]];
                    }
                }
                if (viewInfo[kTextAlignment]) {
                    NSString *str = nil;
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
                        [mstr appendFormat:@"        _%@.textAlignment = %@;\n", viewInfo[kViewUserLabel], str];
                    }
                }
                NSString *font = [self fontWithViewInfo:viewInfo];
                if (font) {
                    [mstr appendFormat:@"        _%@.font = %@;\n", viewInfo[kViewUserLabel], font];
                }
                NSString *textColor = [self textColorWithViewInfo:viewInfo];
                if (textColor) {
                    [mstr appendString:textColor];
                }
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUIButton]) {
                [mstr appendFormat:@"        _%@ = [%@ buttonWithType:UIButtonTypeSystem];\n", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])];
                NSString *font = [self fontWithViewInfo:viewInfo];
                if (font) {
                    [mstr appendFormat:@"        _%@.titleLabel.font = %@;\n", viewInfo[kViewUserLabel], font];
                }
                if (viewInfo[kUIButtonState]) {
                    NSString *titleColor = [self titleColorWithViewInfo:viewInfo];
                    if (titleColor) {
                        [mstr appendString:titleColor];
                    }
                    if (viewInfo[kUIButtonState][kUIButtonTitle]) {
                        [mstr appendFormat:@"        [_%@ setTitle:@\"%@\" forState:UIControlStateNormal];\n", viewInfo[kViewUserLabel], viewInfo[kUIButtonState][kUIButtonTitle]];
                    }
                }
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUIImageView]) {
                [mstr appendFormat:@"        _%@ = [[%@ alloc] init];\n", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])];
                if (viewInfo[kUIImageViewImage]) {
                    if (viewInfo[kUIImageViewImage]) {
                        [mstr appendFormat:@"        _%@.image = [UIImage imageNamed:@\"%@\"];\n", viewInfo[kViewUserLabel], viewInfo[kUIImageViewImage]];
                    }
                }
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUISwitch]) {
                [mstr appendFormat:@"        _%@ = [[%@ alloc] init];\n", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])];
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUITableView]) {
                NSString *str = nil;
                if ([viewInfo[kUITableViewStyle] isEqualToString:@"plain"]) {
                    str = @"UITableViewStylePlain";
                }  else if ([viewInfo[kUITableViewStyle] isEqualToString:@"grouped"]) {
                    str = @"UITableViewStyleGrouped";
                }
                [mstr appendFormat:@"        _%@ = [[UITableView alloc] initWithFrame:CGRectZero style:%@];\n", viewInfo[kViewUserLabel], str];
            } else if ([viewInfo[kViewType] isEqualToString:kViewTypeUIScrollView]) {
                [mstr appendFormat:@"        _%@ = [[%@ alloc] init];\n", viewInfo[kViewUserLabel], ViewTypeToClassName(viewInfo[kViewType])];
            }
            NSString *backgroundColor = [self backgroundColorWithViewInfo:viewInfo];
            if (backgroundColor) {
                [mstr appendString:backgroundColor];
            }
            
            [mstr appendFormat:@"%@", [self methodEndLinesWithViewInfo:viewInfo]];
            [codesArray addObject:mstr];
        }
    }];
    return [codesArray componentsJoinedByString:@"\n\n"];
}

+ (NSString *)methodBeginLinesWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableString *mstr = [NSMutableString string];
    NSString *first = [NSString stringWithFormat:@"- (%@ *)%@ {", ViewTypeToClassName(viewInfo[kViewType]), viewInfo[kViewUserLabel]];
    NSString *second = [NSString stringWithFormat:@"    if (!_%@) {", viewInfo[kViewUserLabel]];
    [mstr appendFormat:@"%@\n", first];
    [mstr appendFormat:@"%@\n", second];
    return mstr;
}

+ (NSString *)methodEndLinesWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSMutableString *mstr = [NSMutableString string];
    NSString *first = @"    }";
    NSString *second = [NSString stringWithFormat:@"    return _%@;", viewInfo[kViewUserLabel]];
    NSString *third = @"}";
    [mstr appendFormat:@"%@\n", first];
    [mstr appendFormat:@"%@\n", second];
    [mstr appendFormat:@"%@", third];
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
        return [NSString stringWithFormat:@"        _%@.backgroundColor = %@;\n", viewInfo[kViewUserLabel], str];
    } else {
        return nil;
    }
}

+ (NSString *)textColorWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSString *str = [self colorWithKey:@"textColor" colorInfo:viewInfo[kColorInfo]];
    if (str) {
        return [NSString stringWithFormat:@"        _%@.textColor = %@;\n", viewInfo[kViewUserLabel], str];
    } else {
        return nil;
    }
}

+ (NSString *)titleColorWithViewInfo:(NSDictionary<NSString *, id> *)viewInfo {
    
    NSString *str = [self colorWithKey:@"titleColor" colorInfo:viewInfo[kUIButtonState][kColorInfo]];
    if (str) {
        return [NSString stringWithFormat:@"        [_%@ setTitleColor:%@ forState:UIControlStateNormal];\n", viewInfo[kViewUserLabel], str];
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

@end
