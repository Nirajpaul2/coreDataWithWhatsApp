//
//  UpdateViewController.m
//  coredataDemo
//
//  Created by Brainium on 5/1/16.
//  Copyright © 2016 Brainium. All rights reserved.
//

#import "UpdateViewController.h"
#import "MyDatabaseManager.h"

@interface UpdateViewController ()
{
    
    NSString *currentTime;
}
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UITextField *txtTime;


@end

@implementation UpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    currentTime = [dateFormatter stringFromDate:today];
    NSLog(@"User's current time in their preference format:%@",currentTime);
    
    _lblTime.text = currentTime;
    
   // NSLog(@"issen%@",self.record.isseen);
    
    
    if (self.record.isseen)
    {
      //  NSLog(@"username:%@",self.record.username);
       // NSLog(@"lastmsg:%@",self.record.lastmsg);

    }
    
  //  _lblTime.text = self.record.name;
   // _txtTime.text = self.record.email;
   
    
}
- (IBAction)ButtonUpdate:(id)sender {
    
    NSLog(@"record:%@",self.record);
    
    NSNumber *stateNum = [NSNumber numberWithBool:0];

    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          _lblTime.text,kTime,
                          _txtTime.text,Klastmsg,
                          stateNum,Kisseen,
                          //_txtName.text,kPhoneNumber,
                          // _textfield.text,kComment,
                          // _lblTime.text,Kage,
                          
                          //  imageData,Kimage,
                          nil];

    
    [[MyDatabaseManager sharedManager] updateRecord:self.record inRecordTable:dict];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


@end
