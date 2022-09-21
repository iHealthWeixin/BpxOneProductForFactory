//
//  ViewController.m
//  PressForFactory
//
//  Created by liutengjiao on 2022/8/17.
//

#import "ViewController.h"
#import "BleViewController.h"
#import "CustomTableviewCell.h"
#import "TJAlert.h"
#import "TimeTool.h"
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
    self.navigationItem.title = @"BP Factory TEST";
    [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
    self.selectName = self.dataArray[0];
    self.start.layer.cornerRadius = 10;
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45, 100)];
    version.text = @"V1.0.0";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:version];
    [self showAlert];
}



- (void)showAlert{
    
    NSString *currentTimeNet = [TimeTool getCurrentTimeNet];
    NSString *getCurrentTimes = [TimeTool getCurrentTimes];
    NSString *message = currentTimeNet==NULL?[NSString stringWithFormat:@"手机时间:%@",getCurrentTimes]:[NSString stringWithFormat:@"网络时间:%@\n手机时间:%@",currentTimeNet==NULL?@"":currentTimeNet,getCurrentTimes];
    
   
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"操作前请确认手机时间是否正确" message:message preferredStyle:UIAlertControllerStyleAlert];
     UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         
     }];
     UIAlertAction *confirAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
     }];
     [alertVC addAction:cancleAction];
     [alertVC addAction:confirAction];
     [self presentViewController:alertVC animated:YES completion:nil];
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
