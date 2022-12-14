//
//  BleViewController.m
//  PressForFactory
//
//  Created by liutengjiao on 2022/8/17.
//

#import "BleViewController.h"
#import "CustomTableviewCell.h"
#import "CBCustomPeripheral.h"
#import "ZHMutableArray.h"
#import "BleTool.h"
#define identi @"CustomTableviewCell"
@interface BleViewController ()<UITableViewDataSource,UITabBarDelegate,BleToolDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) ZHMutableArray * dataArray;
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
    self.title = @"BP List";
}



-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.bleTool stopScan];
    [self.bleTool disconnect];
}

-(void)initTableview{
   
    [self.tableView registerNib:[UINib nibWithNibName:identi bundle:nil] forCellReuseIdentifier:identi];
    
}
-(ZHMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[ZHMutableArray alloc] init];
    }
    return _dataArray;
}


#pragma --mark tooldetalegate

-(void)bleTool:(BleTool *)tool peripheral:(ZHMutableArray *)peripherals{
    self.dataArray = peripherals;
    [self.tableView reloadData];
    if (self.isAuto && self.dataArray.count>0 && ![self.bleTool isRuning]) {
        NSLog(@"连接设备  %@",[self.dataArray objectAtIndex:0]);
        [self.bleTool connectPeripheral:[self.dataArray objectAtIndex:0]];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CBCustomPeripheral *peripheral = [self.dataArray objectAtIndex:indexPath.row];
    CustomTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:identi forIndexPath:indexPath];
    cell.pressNameLable.text = peripheral.name;
    cell.sub.text = [NSString stringWithFormat:@"%@",peripheral.peripheral.identifier];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.isAuto && ![self.bleTool isRuning]) {
        CBCustomPeripheral *peripheral = [self.dataArray objectAtIndex:indexPath.row];
        [self.bleTool connectPeripheral:peripheral];
    }
}


-(void)dealloc{
    NSLog(@"dealloc---");
}

@end
