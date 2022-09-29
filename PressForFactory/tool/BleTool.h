//
//  BleTool.h
//  PressForFactory
//
//  Created by liutengjiao on 2022/8/17.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN
@class ZHMutableArray;
@class BleTool;
@class CBCustomPeripheral;
@protocol  BleToolDelegate
-(void)bleTool:(BleTool *)tool peripheral:(ZHMutableArray *)peripherals;
@end

@interface BleTool : NSObject
@property(nonatomic, weak) id toolDelegate;
@property(nonatomic, strong) NSString * scanName;
+ (id)shareInstance;
- (void)startScan;
- (void)stopScan;
- (void)disconnect;
- (void)connectPeripheral:(CBCustomPeripheral *)peripheral;
- (BOOL)isRuning;
@end

NS_ASSUME_NONNULL_END
