//
//  ViewController.m
//  PressForFactory
//
//  Created by liutengjiao on 2022/8/17.
//

#import "ViewController.h"
#import "BleViewController.h"
#import "CustomTableviewCell.h"
#define identifier @"CustomTableviewCell"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSArray * dataArray;
@property(nonatomic, assign) BOOL  isAuto;
@property (weak, nonatomic) IBOutlet UIButton *start;
@property(nonatomic, strong) NSString * selectName;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"工装测试";
    [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
    self.selectName = self.dataArray[0];
    self.start.layer.cornerRadius = 10;
}


-(NSArray *)dataArray{
    if (!_dataArray) {
        _dataArray = @[@"BPX1"];
    }
    return _dataArray;
}


/**
 修改运行模式
 */
- (IBAction)switchChange:(UISwitch *)sender {
    self.isAuto = sender.on;
    NSLog(@"%d = ",self.isAuto);
}
/**
 开始运行
 */
- (IBAction)startRun:(UIButton *)sender {
    BleViewController *ble = [[BleViewController alloc] init];
    ble.isAuto = self.isAuto;
    ble.name = self.selectName;
    [self.navigationController pushViewController:ble animated:YES];
}

#pragma --mark detalegate


#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //分组
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   //返回cell 个数  如果有两个tableView  可以通过判断是哪一个tableView 然后处理
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   //处理每一个cell
    NSString *name = self.dataArray[indexPath.row];
    
    CustomTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.pressNameLable.text =[NSString stringWithFormat:@"%@",name];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectName = self.dataArray[indexPath.row];
}



@end
