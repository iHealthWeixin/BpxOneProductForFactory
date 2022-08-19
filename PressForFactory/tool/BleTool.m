//
//  BleTool.m
//  PressForFactory
//
//  Created by liutengjiao on 2022/8/17.
//

#import "BleTool.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BleTool()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property(nonatomic, strong) CBCentralManager * centralManager;
@property(nonatomic, strong) NSString * resultStr;
@property(nonatomic, strong) NSMutableArray * services;
@property(nonatomic, strong) NSMutableArray * peripheralsArray;
@property(nonatomic, strong) CBPeripheral * currentPeripheral;
@property(nonatomic, strong) CBCharacteristic * characteristicWrite;

#define serviceUUID @"636F6D2E-6A69-7561-6E2E-646576000000"
#define notifyUUID @"7365642E-6A69-7561-6E2E-646576000000"
#define writeUUID @"7265632E-6A69-7561-6E2E-646576000000"

@end

static BleTool *_instance;

@implementation BleTool

+(id)shareInstance{
   @synchronized(self){
    if(_instance == nil)
        _instance = [[BleTool alloc] init];
   }
   return _instance;
}

-(NSMutableArray *)peripheralsArray{
    if (!_peripheralsArray) {
        _peripheralsArray = [NSMutableArray array];
    }
    return _peripheralsArray;
}


-(instancetype)init{
    if(self = [super init]){
        self.currentPeripheral = nil;
        [self createDispatch];
    }
    return self;
}




- (void)createDispatch{
    dispatch_queue_t centralQueue = dispatch_queue_create("blesdk",DISPATCH_QUEUE_SERIAL);
    NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey : [NSNumber numberWithBool:YES], CBCentralManagerOptionRestoreIdentifierKey : @"blesdk"};
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:options];
                                        
    self.resultStr = @"";
    self.services = [[NSMutableArray alloc]init];
}


#pragma --mark CBCentralManagerDelegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
   
       switch (central.state)
       {
           case CBManagerStatePoweredOn:

               NSLog(@"蓝牙已开启");
               // 根据SERVICE_UUID来扫描外设，如果不设置SERVICE_UUID，则扫描所有蓝牙设备
               // 第一个参数为CBUUID的数组，需要搜索特点服务的蓝牙设备，只要每搜索到一个符合条件的蓝牙设备都会调用didDiscoverPeripheral代理方法
               [self startScan];
               break;
           case CBManagerStatePoweredOff:
               
               NSLog(@"蓝牙已关闭, 请打开蓝牙");
               break;
           case CBManagerStateUnsupported:
               NSLog(@"设备不支持蓝牙");
               break;
           case CBManagerStateUnauthorized:
               NSLog(@"应用尚未被授权使用蓝牙");
               break;
           case CBManagerStateUnknown:
               NSLog(@"未知错误，请重新开启蓝牙");
               break;
           case CBManagerStateResetting:
               NSLog(@"蓝牙重置中");
               [self stopScan];
               break;
           default:
               NSLog(@"Central Manager did change state");
               break;
       }
}


// 开始扫描周围可用蓝牙
- (void)startScan {
    [self stopScan];
    [self.peripheralsArray removeAllObjects];
    NSDictionary *option = @{CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:NO],CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:YES]};
    [self.centralManager scanForPeripheralsWithServices:nil options:option];
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
     CBPeripheral *customPeripheral = peripheral;
    if (customPeripheral.name!=nil && customPeripheral.name!=NULL && [[customPeripheral.name uppercaseString] containsString:self.scanName]) {
        if (![self.peripheralsArray containsObject:peripheral]) {
            [self.peripheralsArray addObject:peripheral];
            [self changgeData];
        }
    }
}

-(BOOL)isRuning{
    return  self.currentPeripheral != nil;
}

- (void)changgeData{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.toolDelegate respondsToSelector:@selector(bleTool:peripheral:)]) {
            [self.toolDelegate bleTool:self peripheral:self.peripheralsArray];
        }
    });
}
    
-(void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict{
    
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didDisconnectPeripheral 断开连接");
    if (self.currentPeripheral == peripheral) {
        self.currentPeripheral = nil;
    }
    if ([self.peripheralsArray containsObject:peripheral]) {
        [self.peripheralsArray removeObject:peripheral];
        [self changgeData];
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"didConnectPeripheral 已连接  %@",peripheral);
    peripheral.delegate = self;
    self.currentPeripheral = peripheral;
    CBUUID *uuids = [CBUUID UUIDWithString:serviceUUID];
    [peripheral discoverServices:@[uuids]];
}

//发现服务了
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"didDiscoverServices 发现服务了 %@",peripheral.services);
    for (CBService *service in peripheral.services) {
        if ([[NSString stringWithFormat:@"%@",service.UUID] isEqual:serviceUUID] ) {
            CBUUID *uuids = [CBUUID UUIDWithString:notifyUUID];
            CBUUID *uuidWrite = [CBUUID UUIDWithString:writeUUID];
            [peripheral discoverCharacteristics:@[uuids,uuidWrite] forService:service];
        }

    }
}

//发现特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    for (CBCharacteristic * characteristic in service.characteristics) {
        if ([[NSString stringWithFormat:@"%@",characteristic.UUID] isEqual:notifyUUID]) {
            NSLog(@"找到notify特征 %@",characteristic);
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if ([[NSString stringWithFormat:@"%@",characteristic.UUID] isEqual:writeUUID]) {
            NSLog(@"找到写入特征  %@",characteristic);
            self.characteristicWrite = characteristic;
        }
        
    }
  
}

//收到特征值变化
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
//    0xa0040000a1de7f
    if ([[NSString stringWithFormat:@"%@",characteristic.UUID] isEqual:notifyUUID] ) {
        NSLog(@"特征变化 %@",characteristic);
        Byte bytes[] = {0xb0,0x04,0xa0,0x00,0xa1,0xde,0x1f};
        NSData *temphead = [[NSData alloc]initWithBytes:bytes length:sizeof(bytes)];
        [peripheral writeValue:temphead forCharacteristic:self.characteristicWrite type:CBCharacteristicWriteWithoutResponse];
    }
}



-(void)stopScan{
    [self.centralManager stopScan];
    
}

//断开外设
- (void)disconnect{
    if (self.currentPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.currentPeripheral];
        self.currentPeripheral = nil;
    }
}

- (void)connectPeripheral:(CBPeripheral *)peripheral{
    [self.centralManager connectPeripheral:peripheral options:nil];
    NSLog(@"connectPeripheral");
}
    
@end
