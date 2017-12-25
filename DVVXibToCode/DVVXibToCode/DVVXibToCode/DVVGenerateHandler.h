//
//  DVVGenerateHandler.h
//  DVVXibToCode
//
//  Created by dawei on 2017/12/22.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DVVGenerateHandlerDelegate;

@interface DVVGenerateHandler : NSObject

@property (nonatomic, weak) id<DVVGenerateHandlerDelegate> delegate;

+ (instancetype)shared;

@end



@protocol DVVGenerateHandlerDelegate <NSObject>

@optional

- (NSString *)handleAutoLayoutInsert:(NSString *)insert;
- (NSString *)handleAutoLayoutOffset:(NSString *)offset;
- (NSString *)handleAutoLayoutSize:(NSString *)size;

- (NSString *)handleGetterFontSize:(NSString *)fontSize;
- (NSString *)handleGetterColorWithRed:(NSString *)red green:(NSString *)green blue:(NSString *)blue alpha:(NSString *)alpha;

@end
