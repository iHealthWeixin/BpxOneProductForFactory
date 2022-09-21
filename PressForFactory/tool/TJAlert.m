//
//  TJAlert.m
//  PressForFactory
//
//  Created by liutengjiao on 2022/9/15.
//

#import "TJAlert.h"

@implementation TJAlert
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message confirmHandle:(SQAlertConfirmHandle)confirmHandle cancleHandle:(SQAlertCancleHandle)cancleHandle {
   
}

+ (UIViewController *)currentViewController {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *presentedVC = [[window rootViewController] presentedViewController];
    if (presentedVC) {
        return presentedVC;

    } else {
        return window.rootViewController;
    }
}

@end
