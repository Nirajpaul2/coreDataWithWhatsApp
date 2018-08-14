//
//  InboxtableviewCell.h
//  Fitness_Dating
//
//  Created by Brainium on 4/29/16.
//  Copyright © 2016 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxtableviewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgViewOncell;
@property (weak, nonatomic) IBOutlet UILabel *lblForNameTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblForLastMsg;
@property (weak, nonatomic) IBOutlet UILabel *lblForDate;
@property (weak, nonatomic) IBOutlet UIView *viewForPresence;

@end
