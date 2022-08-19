//
//  CustomTableviewCell.m
//  PressForFactory
//
//  Created by liutengjiao on 2022/8/17.
//

#import "CustomTableviewCell.h"


@interface CustomTableviewCell()



@end

@implementation CustomTableviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
 
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.selectBt setBackgroundImage:[UIImage imageNamed:@"danxuan"] forState:UIControlStateNormal];
    }else{
        [self.selectBt setBackgroundImage:NULL forState:UIControlStateNormal];

    }
   
   
}

@end
