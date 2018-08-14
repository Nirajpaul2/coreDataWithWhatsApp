//
//  ViewController.m
//  coredataDemo
//
//  Created by Brainium on 4/30/16.
//  Copyright © 2016 Brainium. All rights reserved.
//

#import "ViewController.h"
#import "MyDatabaseManager.h"
#import "secondViewController.h"
#import "InboxtableviewCell.h"
#import "UpdateViewController.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
NSArray *records;
NSArray *filteredRecords;
NSString *sortingAttribute;
    RecordTable *selectedRecord;

    
  //  NSMutableArray *titleArray;
    
}
@property (weak, nonatomic) IBOutlet UITableView *mytable;



@end

@implementation ViewController
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
  //  titleArray = [[NSMutableArray alloc]initWithObjects:@"Niraj paul",@"Prabhat kumar",@"Abijit Rana",@"Amartaya kumar",@"priya kumari",@"Pankaj Kumar",@"Niraj paul", nil];
    
    
    
    UINib *nib = [UINib nibWithNibName:@"InboxtableviewCell" bundle:nil];
    [self.mytable registerNib:nib forCellReuseIdentifier:@"InboxtableviewCell"];
    

   // [self CoreDataFetchValue];
    // Do any additional setup after loading the view, typically from a nib.
}
//-(void)viewWillAppear:(BOOL)animated{
//
//   // [self CoreDataFetchValue];
//    sortingAttribute = kName;
//    [self CoreDataFetchValue];
//    
//    [_mytable reloadData];
//
//}
//- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName
//{
//    
//}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    sortingAttribute = kTime;
    [self CoreDataFetchValue];
    
   // NSLog(@"Dar")
}

-(void)CoreDataFetchValue
{

    
    records = [[[MyDatabaseManager sharedManager] allRecordsSortByAttribute:sortingAttribute] mutableCopy];
    
    
    [_mytable reloadData];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [records count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    InboxtableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InboxtableviewCell"];
    
    if (cell==0) {
        cell=[[InboxtableviewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InboxtableviewCell"];
    }
    
//    UITableViewCell *cell = [[UITableViewCell alloc]init];
//    
//    if (cell==nil) {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
//    }
    
    RecordTable *record = [records objectAtIndex:indexPath.row];
   
    NSLog(@"%@",record.isseen);
    if ([record.isseen isEqualToNumber:@1]) {
        
        cell.lblForLastMsg.textColor = [UIColor greenColor];
    }
    
    else{
        cell.lblForLastMsg.textColor = [UIColor grayColor];

    
    }
    
    cell.lblForLastMsg.text = record.lastmsg;
   
    
    
    cell.lblForNameTitle.text = record.username;
//    cell.imagecell.image = [UIImage imageWithData:record.image];
    cell.lblForDate.text = record.time;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        RecordTable *aRecord = [records objectAtIndex: indexPath.row];
        [[MyDatabaseManager sharedManager] deleteTableRecord:aRecord];
        
        [self CoreDataFetchValue];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

//    if (tableView == self.searchDisplayController.searchResultsTableView)
//    {
//        selectedRecord = [filteredRecords objectAtIndex:indexPath.row];
//    }
//    else
//    {
        selectedRecord = [records objectAtIndex:indexPath.row];
    //}
    
   // [self performSegueWithIdentifier:@"kUpdateSegue" sender:self];
   
    
    UpdateViewController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"UpdateViewController"];
    obj.record = selectedRecord;
    [self.navigationController pushViewController:obj animated:YES];
//
//
//    NSLog(@"index:%ld",(long)indexPath.row);
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 88;
}

- (IBAction)deleteAction:(id)sender {
   
    [[MyDatabaseManager sharedManager] deleteAllTableRecord];

    
//    NSIndexPath *index =[_mytable indexPathForSelectedRow];
//    
//    RecordTable *aRecord = [records objectAtIndex:index.row];
//    [[MyDatabaseManager sharedManager] deleteTableRecord:aRecord];
//    
//    //  [arrNumberOfProducts removeObjectAtIndex:index.row];
//    [records removeObjectAtIndex:index.row];
//    
//    
   [self CoreDataFetchValue];
}

@end
