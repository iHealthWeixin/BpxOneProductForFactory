//
//  AppDelegate.h
//  PressForFactory
//
//  Created by liutengjiao on 2022/8/17.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (strong, nonatomic) UIWindow * window;
- (void)saveContext;


@end

