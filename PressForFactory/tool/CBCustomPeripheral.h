//
//  CBCustomPeripheral.h
//  PressForFactory
//
//  Created by liutengjiao on 2022/9/28.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface CBCustomPeripheral : NSObject
@property(nonatomic, strong) NSString * name;
@property(nonatomic, strong) CBPeripheral * peripheral;

@end

NS_ASSUME_NONNULL_END
