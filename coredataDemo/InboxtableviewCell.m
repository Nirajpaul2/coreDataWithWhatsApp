//
//  InboxtableviewCell.m
//  Fitness_Dating
//
//  Created by Brainium on 4/29/16.
//  Copyright © 2016 Apple. All rights reserved.
//

#import "InboxtableviewCell.h"

@implementation InboxtableviewCell

- (void)awakeFromNib {
    
    _imgViewOncell.layer.cornerRadius=53/2;
    _imgViewOncell.clipsToBounds = YES;
   // _imgViewOncell.layer.borderColor = [UIColor redColor].CGColor;
   // _imgViewOncell.layer.borderWidth =1.0;

    _viewForPresence.layer.cornerRadius = 16/2;
    _viewForPresence.clipsToBounds = YES;
    
    
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
