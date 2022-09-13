//
//  CustomTableviewCell.h
//  PressForFactory
//
//  Created by liutengjiao on 2022/8/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableviewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pressNameLable;
@property (weak, nonatomic) IBOutlet UILabel *sub;

@property (weak, nonatomic) IBOutlet UIButton *selectBt;
@end

NS_ASSUME_NONNULL_END
