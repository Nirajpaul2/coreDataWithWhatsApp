//
//  RecordTable.h
//  DatabaseManager

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RecordTable : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * lastmsg;

@property (nonatomic, retain) NSNumber *isseen;

@end
