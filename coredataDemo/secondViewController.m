//
//  secondViewController.m
//  coredataDemo
//
//  Created by Brainium on 4/30/16.
//  Copyright © 2016 Brainium. All rights reserved.
//

#import "secondViewController.h"
#import "MyDatabaseManager.h"
BOOL isbool = YES;

@interface secondViewController ()
{
    NSString *yesvalue;
    NSString *currentTime;
    
}
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UITextField *txtName;

@end

@implementation secondViewController

BOOL trueOrFalse = YES;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    
    yesvalue=@"NO";
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    currentTime = [dateFormatter stringFromDate:today];
    NSLog(@"User's current time in their preference format:%@",currentTime);

    _lblTime.text = currentTime;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveButton:(id)sender {
    [self DataStoreInDataBase];
    
}
-(void)DataStoreInDataBase
{
  
    NSNumber *stateNum = [NSNumber numberWithBool:1];

    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          _lblTime.text,kTime,
                          _textfield.text,Klastmsg,
                           _txtName.text,kusername,
                            stateNum,Kisseen,
                           // _textfield.text,kComment,
                          // _lblTime.text,Kage,
                          
                          //  imageData,Kimage,
                          nil];
    //[dict setValue:[NSString stringWithFormat:@"%c", isDefault] forKey:@"isseen"];

    
    
//    NSDictionary *dictForPassword = [[NSDictionary alloc] initWithObjectsAndKeys:stateNum,kPassword, nil];
    
    
  //  [dict setValue:[NSNumber numberWithBool:YES] forKey:@"isseen"];
    
    [[MyDatabaseManager sharedManager] insertRecordInRecordTable:dict];
    
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
