//
//  DVVCover.m
//  DVVXibToCode
//
//  Created by dawei on 2017/12/22.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import "DVVCover.h"
#import "XMLDictionary.h"
#import "DVVGenerateProperties.h"
#import "DVVGenerateAddSubviews.h"
#import "DVVGenerateAutoLayouts.h"
#import "DVVGenerateGetters.h"

@interface DVVCover () <NSXMLParserDelegate>

@property (nonatomic, assign) DVVCoverXibType xibType;

@property (nonatomic, assign) BOOL canParseViewsOrder;
@property (nonatomic, strong) NSMutableArray<NSString *> *viewsOrder;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary<NSString *, id> *> *viewsInfo;

@property (nonatomic, copy) NSString *propertiesCode;
@property (nonatomic, copy) NSString *layoutsCode;
@property (nonatomic, copy) NSString *addSubviewsCode;
@property (nonatomic, copy) NSString *gettersCode;

@end

@implementation DVVCover

- (NSString *)coverAtPath:(NSString *)path xibType:(DVVCoverXibType)xibType {
    
    _xibType = xibType;
    
    // 读取 xib 文件
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *data = [fileHandle readDataToEndOfFile];
    // XML数据 转换为 字典
    NSDictionary *root = [NSDictionary dictionaryWithXMLData:data];
    NSDictionary *view = nil;
    switch (xibType) {
        case DVVCoverXibTypeUIView:
        case DVVCoverXibTypeUIViewController:
            view = root[@"objects"][@"view"];
            break;
        case DVVCoverXibTypeUITableViewCell:
            view = root[@"objects"][@"tableViewCell"][@"tableViewCellContentView"];
            break;
        case DVVCoverXibTypeUICollectionViewCell:
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
    
    // 寻找视图顺序
    [self findViewsOrderWithXibData:data];
    // 寻找到所有的视图
    [self findViewFromDict:view superViewID:view[kViewId] viewType:kViewTypeUIView isRootView:YES];
    // 寻找到子视图
    [self findSubviews];
    [self.viewsOrder enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"\n%@\n%@", obj, self.viewsInfo[obj]);
    }];
    
    // 生成属性代码
    _propertiesCode = [DVVGenerateProperties generatePropertiesCodeWithViewsOrder:self.viewsOrder viewsInfo:self.viewsInfo];
    // 生成添加视图代码
    _addSubviewsCode = [DVVGenerateAddSubviews generateAddViewsCodeWithViewsOrder:self.viewsOrder viewsInfo:self.viewsInfo xibType:xibType];
    // 生成约束代码
    _layoutsCode = [DVVGenerateAutoLayouts generateAutoLayoutsCodeWithViewsOrder:self.viewsOrder viewsInfo:self.viewsInfo xibType:xibType];
    // 生成Getter代码
    _gettersCode = [DVVGenerateGetters generateGettersCodeWithViewsOrder:self.viewsOrder viewsInfo:self.viewsInfo];
    
    NSMutableString *mstr = [NSMutableString string];
    
    [mstr appendString:@"\n\n==============================================================\n"];
    [mstr appendString:_propertiesCode];
    [mstr appendString:@"\n==============================================================\n"];
    
    [mstr appendString:@"\n\n==============================================================\n"];
    [mstr appendString:_addSubviewsCode];
    [mstr appendString:@"\n==============================================================\n"];
    
    [mstr appendString:@"\n\n==============================================================\n"];
    [mstr appendString:_layoutsCode];
    [mstr appendString:@"\n==============================================================\n"];
    
    [mstr appendString:@"\n\n==============================================================\n"];
    [mstr appendString:_gettersCode];
    [mstr appendString:@"\n==============================================================\n\n"];
    
    return mstr.copy;
}

#pragma mark -

- (void)findViewsOrderWithXibData:(NSData *)data {
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    
    self.canParseViewsOrder = NO;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    switch (_xibType) {
        case DVVCoverXibTypeUIView:
        case DVVCoverXibTypeUIViewController:
            if (!self.canParseViewsOrder) {
                self.canParseViewsOrder = YES;
            }
            break;
        case DVVCoverXibTypeUITableViewCell:
            if (!self.canParseViewsOrder) {
                if ([elementName isEqualToString:@"tableViewCellContentView"]) {
                    if (attributeDict[@"id"]) {
                        [self.viewsOrder addObject:attributeDict[@"id"]];
                    }
                    self.canParseViewsOrder = YES;
                }
            }
            break;
        case DVVCoverXibTypeUICollectionViewCell:
        {
            if (!self.canParseViewsOrder) {
                if ([elementName isEqualToString:@"collectionViewCell"]) {
                    if (attributeDict[@"id"]) {
                        [self.viewsOrder addObject:attributeDict[@"id"]];
                    }
                    self.canParseViewsOrder = YES;
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    if (self.canParseViewsOrder) {
        static NSArray<NSString *> *availableClassArray = nil;
        if (!availableClassArray) {
            availableClassArray = @[@"view",
                                    @"label",
                                    @"textField",
                                    @"textView",
                                    @"button",
                                    @"imageView",
                                    @"switch",
                                    @"tableView",
                                    @"scrollView",
                                    ];
        }
        if ([availableClassArray containsObject:elementName]) {
            if (attributeDict[@"id"]) {
                [self.viewsOrder addObject:attributeDict[@"id"]];
            }
        }
    }
}

#pragma mark -

- (void)findViewFromDict:(NSDictionary<NSString *, id> *)dict superViewID:(NSString *)superViewID viewType:(NSString *)viewType isRootView:(BOOL)isRootView {
    
    NSMutableDictionary *d = dict.mutableCopy;
    if (isRootView) {
        d[kViewUserLabel] = kRootView;
    } else {
        if (dict[kViewUserLabel]) {
            d[kViewUserLabel] = dict[kViewUserLabel];
        } else {
            d[kViewUserLabel] = viewType;
        }
    }
    d[kSuperViewID] = superViewID;
    d[kViewType] = viewType;
    // 保存视图
    NSString *_id = (NSString *)dict[kViewId];
    self.viewsInfo[_id] = d;
    
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

#pragma mark -

- (void)findSubviews {
    
    [self.viewsOrder enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary<NSString *,id> *viewInfo = self.viewsInfo[obj];
        if (JudgeIsRoot(viewInfo[kViewUserLabel])) {
            [self findSubviewsWithViewID:obj];
            *stop = YES;
        }
    }];
}

- (void)findSubviewsWithViewID:(NSString *)viewID {
    
    __block NSMutableArray<NSString *> *subViewArray = [NSMutableArray array];
    // 寻找子视图
    [self.viewsOrder enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary<NSString *,id> *viewInfo = self.viewsInfo[obj];
        if (!JudgeIsRoot(viewInfo[kViewUserLabel]) &&
            [viewInfo[kSuperViewID] isEqualToString:viewID]) {
            [subViewArray addObject:obj];
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

#pragma mark - Getters

- (NSMutableDictionary<NSString *,NSDictionary<NSString *,id> *> *)viewsInfo {
    if (!_viewsInfo) {
        _viewsInfo = [NSMutableDictionary dictionary];
    }
    return _viewsInfo;
}

- (NSMutableArray<NSString *> *)viewsOrder {
    if (!_viewsOrder) {
        _viewsOrder = [NSMutableArray array];
    }
    return _viewsOrder;
}

@end
