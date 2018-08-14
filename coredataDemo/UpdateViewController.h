//
//  UpdateViewController.h
//  coredataDemo
//
//  Created by Brainium on 5/1/16.
//  Copyright © 2016 Brainium. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDatabaseManager.h"

@class RecordTable;

@interface UpdateViewController : UIViewController
@property(nonatomic, strong) RecordTable *record;

@end
