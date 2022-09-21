//
//  TimeTool.h
//  PressForFactory
//
//  Created by liutengjiao on 2022/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef  void(^CurrentTimeNetBlock)(NSString *currenttime);
//:(CurrentTimeNetBlock)block
@interface TimeTool : NSObject
+ (NSString *)getCurrentTimeNet;//获取网络时间
+ (NSString *)getCurrentTimeInterval;//获取当前本机的时间戳
+ (NSString*)getCurrentTimes;//当前本机时间
@end

NS_ASSUME_NONNULL_END
