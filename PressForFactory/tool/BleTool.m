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
    [self.peripheralsArray removeAllObjects];
    [self scan];
}

-(void)scan{
    [self stopScan];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:serviceUUID]] options:nil];
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
     CBPeripheral *customPeripheral = peripheral;
//    if ([[peripheral.name uppercaseString] containsString:@"BPX1"]) {
//        NSLog(@"name === %@",peripheral.name);
//    }
  
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
    



-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didDisconnectPeripheral 断开连接");
    if (self.currentPeripheral == peripheral) {
        NSLog(@"didDisconnectPeripheral 断开连接 %@",peripheral.name);
        [self disconnect];
    }
    [self removeAndRescan:peripheral];
}




-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didFailToConnectPeripheral 连接失败");
    [self removeAndRescan:peripheral];
}


-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"didConnectPeripheral 已连接  %@",peripheral.name);
    peripheral.delegate = self;
    self.currentPeripheral = peripheral;
    CBUUID *uuids = [CBUUID UUIDWithString:serviceUUID];
    [peripheral discoverServices:@[uuids]];
}

-(void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict{
    NSLog(@"willRestoreState ");
}


//发现服务了
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
//    NSLog(@"didDiscoverServices 发现服务了 %@",peripheral.services);
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
//            NSLog(@"找到notify特征 %@",characteristic);
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if ([[NSString stringWithFormat:@"%@",characteristic.UUID] isEqual:writeUUID]) {
//            NSLog(@"找到写入特征  %@",characteristic);
            self.characteristicWrite = characteristic;
        }
        
    }
  
}

//收到特征值变化
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if ([[NSString stringWithFormat:@"%@",characteristic.UUID] isEqual:notifyUUID] ) {
//        NSLog(@"特征变化 %@",characteristic);
        NSString * time =  [self getCurrentTimeInterval];
        NSString *utc = [self toBinarySystemWithDecimalSystem:time];

//        NSLog(@"utc === %@",utc);
        uint8_t bytes[11] = {0};
        bytes[0] = 0xb0;
        bytes[1] = 0x08;
        bytes[2] = 0xa0;
        bytes[3] = 0x00;
        bytes[4] = 0xa1;
        bytes[5] = 0xde;
        
        NSString * byte6 = [self getByte6:utc] ;
        NSString * byte7 =  [self getByte7:utc];
        NSString * byte8 = [self getByte8:utc];
        NSString * byte9 = [self getByte9:utc];
        uint8_t num2 = strtoul([@"a0" UTF8String],0,16);
        uint8_t num3 = strtoul([@"00" UTF8String],0,16);
        uint8_t num4 = strtoul([@"a1" UTF8String],0,16);
        uint8_t num5 = strtoul([@"de" UTF8String],0,16);
        uint8_t num6 = strtoul([byte6 UTF8String],0,16);
        uint8_t num7 = strtoul([byte7 UTF8String],0,16);
        uint8_t num8 = strtoul([byte8 UTF8String],0,16);
        uint8_t num9 = strtoul([byte9 UTF8String],0,16);
        bytes[6] = num6;
        bytes[7] = num7;
        bytes[8] = num8;
        bytes[9] = num9;
        uint8_t all = num2+num3+num4+num5+num6+num7+num8+num9;
//        NSLog(@"sum === %d  ",all);
        bytes[10] = all;
        NSData *temphead = [[NSData alloc]initWithBytes:bytes length:sizeof(bytes)];
        [peripheral writeValue:temphead forCharacteristic:self.characteristicWrite type:CBCharacteristicWriteWithoutResponse];
    }
}



- (void)removeAndRescan:(CBPeripheral *)peripheral{
    if ([self.peripheralsArray containsObject:peripheral]) {
        [self.peripheralsArray removeObject:peripheral];
        [self changgeData];
    }
    [self scan];
}


/**
 二进制转换成十六进制
 
 @param binary 二进制数
 @return 十六进制数
 */
- (NSString *)getHexByBinary:(NSString *)binary {
    NSMutableDictionary *binaryDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [binaryDic setObject:@"0" forKey:@"0000"];
    [binaryDic setObject:@"1" forKey:@"0001"];
    [binaryDic setObject:@"2" forKey:@"0010"];
    [binaryDic setObject:@"3" forKey:@"0011"];
    [binaryDic setObject:@"4" forKey:@"0100"];
    [binaryDic setObject:@"5" forKey:@"0101"];
    [binaryDic setObject:@"6" forKey:@"0110"];
    [binaryDic setObject:@"7" forKey:@"0111"];
    [binaryDic setObject:@"8" forKey:@"1000"];
    [binaryDic setObject:@"9" forKey:@"1001"];
    [binaryDic setObject:@"A" forKey:@"1010"];
    [binaryDic setObject:@"B" forKey:@"1011"];
    [binaryDic setObject:@"C" forKey:@"1100"];
    [binaryDic setObject:@"D" forKey:@"1101"];
    [binaryDic setObject:@"E" forKey:@"1110"];
    [binaryDic setObject:@"F" forKey:@"1111"];
    
    if (binary.length % 4 != 0) {
        
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    NSString *hex = @"";
    for (int i=0; i<binary.length; i+=4) {
        
        NSString *key = [binary substringWithRange:NSMakeRange(i, 4)];
        NSString *value = [binaryDic objectForKey:key];
        if (value) {
            
            hex = [hex stringByAppendingString:value];
        }
    }
    return hex;
}


- (NSString *)getByte6:(NSString *)utc{
    return [self getHexByBinary:[utc substringWithRange:NSMakeRange (0, utc.length-24)]];
}

- (NSString *)getByte7:(NSString *)utc{
//    NSLog(@"getByte7 == %@",[utc substringWithRange:NSMakeRange (utc.length-24, 8)]);
    
//    NSLog(@"getByte7 change1 == %@",[self getHexByBinary:[utc substringWithRange:NSMakeRange (utc.length-24, 8)]]);
//    int seven = [[self getHexByBinary:[utc substringWithRange:NSMakeRange (utc.length-24, 8)]] intValue] ;
//    NSLog(@"seven = %d",seven);
    
    return [self getHexByBinary:[utc substringWithRange:NSMakeRange (utc.length-24, 8)]];
}

- ( NSString *)getByte8:(NSString *)utc{
    return [self getHexByBinary:[utc substringWithRange:NSMakeRange (utc.length-16, 8)]] ;
}

- ( NSString *)getByte9:(NSString *)utc{
    return [self getHexByBinary:[utc substringWithRange:NSMakeRange (utc.length-8, 8)]] ;
}





//转二进制
- (NSString *)toBinarySystemWithDecimalSystem:(NSString *)time
{
    int num = [time intValue];
    int remainder = 0;      //余数
    int divisor = 0;        //除数
    
    NSString * prepare = @"";
    
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%d",remainder];
        
        if (divisor == 0)
        {
            break;
        }
    }
    
    NSString * result = @"";
    for (int i = prepare.length - 1; i >= 0; i --)
    {
        result = [result stringByAppendingFormat:@"%@",
                  [prepare substringWithRange:NSMakeRange(i , 1)]];
    }
    
    return result;
}


//获取事件戳
- (NSString *)getCurrentTimeInterval {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
//    NSLog(@"时间戳 == %@",[NSString stringWithFormat:@"%ld",(long)[datenow timeIntervalSince1970]]);
    return   [NSString stringWithFormat:@"%ld",(long)[datenow timeIntervalSince1970]]  ;
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
//    NSLog(@"connectPeripheral");
}
    
@end
