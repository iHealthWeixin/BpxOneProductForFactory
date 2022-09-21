//
//  TJAlert.h
//  PressForFactory
//
//  Created by liutengjiao on 2022/9/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef void(^SQAlertConfirmHandle)(void);
typedef void(^SQAlertCancleHandle)(void);
@interface TJAlert : NSObject
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message confirmHandle:(SQAlertConfirmHandle)confirmHandle cancleHandle:(SQAlertCancleHandle)cancleHandle;
@end

NS_ASSUME_NONNULL_END
