//
//  thordViewController.m
//  coredataDemo
//
//  Created by Brainium on 4/30/16.
//  Copyright © 2016 Brainium. All rights reserved.
//

#import "thordViewController.h"
#import "MyDatabaseManager.h"

@interface thordViewController ()

@end

@implementation thordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 //   NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:

                       //   nil];
    
    [[MyDatabaseManager sharedManager] insertRecordInRecordTable:nil];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
