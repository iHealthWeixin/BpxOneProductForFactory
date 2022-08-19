//
//  BleViewController.m
//  PressForFactory
//
//  Created by liutengjiao on 2022/8/17.
//

#import "BleViewController.h"
#import "CustomTableviewCell.h"
#import "BleTool.h"
#define identifier @"CustomTableviewCell"
@interface BleViewController ()<UITableViewDataSource,UITabBarDelegate,BleToolDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSMutableArray * dataArray;
@property(nonatomic, weak) BleTool * bleTool;
@end

@implementation BleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableview];
    [self.dataArray removeAllObjects];
    self.bleTool = [BleTool shareInstance];
    self.bleTool.toolDelegate = self;
    self.bleTool.scanName = self.name;
    [self.bleTool  startScan];
}



-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.bleTool stopScan];
    [self.bleTool disconnect];
}

-(void)initTableview{
   
    [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];

}
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


#pragma --mark tooldetalegate

-(void)bleTool:(BleTool *)tool peripheral:(NSMutableArray *)peripherals{
    self.dataArray = peripherals;
    [self.tableView reloadData];
    if (self.isAuto && self.dataArray.count>0 && ![self.bleTool isRuning]) {
        NSLog(@"连接设备  %@",self.dataArray[0]);
        [self.bleTool connectPeripheral:self.dataArray[0]];
    }
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CBPeripheral *peripheral = self.dataArray[indexPath.row];
    CustomTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    NSLog(@"peripheral = %@",peripheral);
    cell.pressNameLable.text = peripheral.name;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.isAuto && ![self.bleTool isRuning]) {
        CBPeripheral *peripheral = self.dataArray[indexPath.row];
        [self.bleTool connectPeripheral:peripheral];
    }
}


-(void)dealloc{
    NSLog(@"dealloc---");
}

@end
