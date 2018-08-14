

#import <Foundation/Foundation.h>

//iOS 5 compatibility method
@implementation NSArray (iOS5_firstObject)

-(id)firstObject
{
    return ([self count] > 0)?[self objectAtIndex:0]:nil;
}

@end



#import "IQDatabaseManager.h"

/*************************************/

//Category Methods are used as private methods. Because these are used only inside the class. Not able to access from outside.
//Class method are used because these methods are not dependent upon class iVars.

//Created by Iftekhar. 18/4/13.
@interface IQDatabaseManager()

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end


@implementation IQDatabaseManager
{
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}


#pragma mark - Abstract method exceptions.
+(NSURL*)modelURL
{
    NSString *selector = NSStringFromSelector(_cmd);
    [NSException raise:NSInternalInconsistencyException format:@"%@ is abstract method You must override %@ method in %@ class and must not call [super %@].",selector,selector,NSStringFromClass([self class]),selector];
    return nil;
}

#pragma mark - Initialize and Save.
- (id)init
{
    self = [super init];
    if (self)
    {
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[self class] modelURL]];

        //Initializing persistentStoreCoordinator with ManagedObjectModel.
        {
            NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            
            NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",NSStringFromClass([self class])]];
            
            NSError *error = nil;
            _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
            
            // Set Core Data migration options
            // For automatic lightweight migration set NSInferMappingModelAutomaticallyOption to YES
            // For automatic migration using a mapping model set NSInferMappingModelAutomaticallyOption to YES
            NSDictionary *optionsDictionary = @{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                                                NSInferMappingModelAutomaticallyOption:@(YES)};
            
            if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error])
            {
                NSLog(@"PersistentStore Error: %@, %@", error, [error userInfo]);
                
                //Removign file and now trying once again
                [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
                
                if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
                {
                    //If issue still not resolved then removing file and aborting.
                    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
                    abort();
                }
            }
        }
        
        //Initializing ManagedObjectContext with persistentStoreCoordinator
        {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            _managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
            [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
        }
    }
    return self;
}

+(IQ_INSTANCETYPE)sharedManager
{
    static NSMutableDictionary *sharedDictionary;
    
    if (sharedDictionary == nil)
        
    sharedDictionary = [[NSMutableDictionary alloc] init];
    
    id sharedObject = [sharedDictionary objectForKey:NSStringFromClass([self class])];
    
    if (sharedObject == nil)
    {
        @synchronized(self) {
            
            //Again trying (May be set from another thread)
            id sharedObject = [sharedDictionary objectForKey:NSStringFromClass([self class])];
            
            if (sharedObject)
            {
                return sharedObject;
            }
            else if (![NSStringFromClass(self) isEqualToString:NSStringFromClass([IQDatabaseManager class])])
            {
                sharedObject = [[self alloc] init];
                
                [sharedDictionary setObject:sharedObject forKey:NSStringFromClass([self class])];
            }
            else
            {
                [NSException raise:NSInternalInconsistencyException format:@"You must subclass %@",NSStringFromClass([IQDatabaseManager class])];
                return nil;
            }
        }
    }
    
    return sharedObject;
}

//Save context.
-(BOOL)save;
{
    if ([_managedObjectContext hasChanges])
    {
        __block NSError *error = nil;
        __block BOOL isSaved = NO;
        
        [_managedObjectContext performBlockAndWait:^{
            
            isSaved = [_managedObjectContext save:&error];
            
            if (error)
            {
                NSLog(@"Error Saving Database: %@",error);
            }
        }];
        
        return isSaved;
        
        //            BOOL isSaved = [_managedObjectContext save:&error];
        //
        //            if (error)
        //            {
        //                NSLog(@"Error Saving Database: %@",error);
        //            }
        //
        //            return isSaved;
    }
    else
    {
        return NO;
    }
}

-(NSArray*)tableNames
{
    NSDictionary *entities = [_managedObjectModel entitiesByName];
    return [entities allKeys];
}

-(NSDictionary*)attributesForTable:(NSString*)tableName
{
    NSEntityDescription *description = [[_managedObjectModel entitiesByName] objectForKey:tableName];

    NSDictionary *properties = [description propertiesByName];
    NSArray *allKeys = [properties allKeys];
    
    NSMutableDictionary *attributeDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *key in allKeys)
    {
        if ([[properties objectForKey:key] attributeType] == NSTransformableAttributeType)
        {
            [attributeDictionary setObject:@"id" forKey:key];
        }
        else
        {
            NSString *attributeClassName = [[properties objectForKey:key] attributeValueClassName];
            
            if (attributeClassName)
            {
                [attributeDictionary setObject:attributeClassName forKey:key];
            }
        }
    }
    
    return attributeDictionary;
}



#pragma mark - Fetch Records

- (NSArray *)allObjectsFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate sortDescriptor:(NSSortDescriptor*)descriptor
{
    //Creating fetch request object for fetching records.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:tableName];
    
#if TARGET_IPHONE_SIMULATOR
    [fetchRequest setReturnsObjectsAsFaults:NO];
#endif
    
    if (predicate)  [fetchRequest setPredicate:predicate];
    if (descriptor) [fetchRequest setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    
    __block NSArray *objects = nil;
    [_managedObjectContext performBlockAndWait:^{
        objects = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    }];
    
    return objects;
}

- (NSArray *)allObjectsFromTable:(NSString*)tableName sortDescriptor:(NSSortDescriptor*)descriptor
{
    return [self allObjectsFromTable:tableName wherePredicate:nil sortDescriptor:descriptor];
}

- (NSArray *)allObjectsFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate
{
    return [self allObjectsFromTable:tableName wherePredicate:predicate sortDescriptor:nil];
}

-(NSArray*)allObjectsFromTable:(NSString*)tableName
{
    return [self allObjectsFromTable:tableName wherePredicate:nil sortDescriptor:nil];
}


/***Key Value predicate***/
- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value sortDescriptor:(NSSortDescriptor*)descriptor
{
    if (key && value)
    {
        if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSDate class]])
        {
            NSPredicate *predicate;
            if (key && value)   predicate = [NSPredicate predicateWithFormat:@"self.%@ == %@",key,value];
            return [self allObjectsFromTable:tableName wherePredicate:predicate sortDescriptor:descriptor];
        }
        else
        {
            NSArray *allObjects = [self allObjectsFromTable:tableName wherePredicate:nil sortDescriptor:descriptor];
            
            NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
            
            for (NSManagedObject *object in allObjects)
                if ([[object valueForKey:key] isEqual:value])
                    [filteredArray addObject:object];

            return filteredArray;
        }
    }
    else
    {
        return [self allObjectsFromTable:tableName wherePredicate:nil sortDescriptor:descriptor];
    }
}

- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value
{
    return [self allObjectsFromTable:tableName where:key equals:value sortDescriptor:nil];
}


- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key contains:(id)value sortDescriptor:(NSSortDescriptor*)descriptor
{
    NSPredicate *predicate;
    if (key && value) 
    {
        NSString *predicateString = [NSString stringWithFormat:@"self.%@ contains[c] \"%@\"",key,value];
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    
    return [self allObjectsFromTable:tableName wherePredicate:predicate sortDescriptor:descriptor];
}

- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key contains:(id)value
{
    return [self allObjectsFromTable:tableName where:key contains:value sortDescriptor:nil];
}


/*First/Last object*/
- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName
{
    return [[self allObjectsFromTable:tableName] firstObject];
}

- (NSManagedObject *)lastObjectFromTable:(NSString*)tableName
{
    return [[self allObjectsFromTable:tableName] lastObject];
}

#pragma mark - Insert & Update Records

//Update object
- (NSManagedObject*)updateRecord:(NSManagedObject*)object withAttribute:(NSDictionary*)dictionary
{
    NSArray *allValidKeys = object.entity.attributesByName.allKeys;
    
    for (NSString *aKey in allValidKeys)
    {
        id value = [dictionary objectForKey:aKey];
        
        if (value && [value isKindOfClass:[NSNull class]] == NO)
        {
            [object setValue:value forKey:aKey];
        }
        else if ([value isKindOfClass:[NSNull class]])
        {
            //            NSLog(@"Found Null");
        }
    }
    
    [self save];
    return object;
}

//Insert objects
- (NSManagedObject*)insertRecordInTable:(NSString*)tableName withAttribute:(NSDictionary*)dictionary
{
    //creating NSManagedObject for inserting records
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:_managedObjectContext];
    
    return [self updateRecord:object withAttribute:dictionary];
}

- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName createIfNotExist:(BOOL)create
{
    NSManagedObject *object = [self firstObjectFromTable:tableName];
    
    if (object == nil && create == YES)    object = [self insertRecordInTable:tableName withAttribute:nil];
    
    
    return object;
}

- (NSManagedObject *)lastObjectFromTable:(NSString*)tableName createIfNotExist:(BOOL)create
{
    NSManagedObject *object = [self lastObjectFromTable:tableName];
    
    if (object == nil && create == YES)    object = [self insertRecordInTable:tableName withAttribute:nil];
    
    return object;
}


- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value
{
    return [[self allObjectsFromTable:tableName where:key equals:value] firstObject];
}

- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate
{
    return [[self allObjectsFromTable:tableName wherePredicate:predicate] firstObject];
}

- (NSManagedObject *)lastObjectFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value
{
    return [[self allObjectsFromTable:tableName where:key equals:value] lastObject];
}

- (NSManagedObject *)lastObjectFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate
{
    return [[self allObjectsFromTable:tableName wherePredicate:predicate] lastObject];
}

- (NSManagedObject*)insertRecordInTable:(NSString*)tableName withAttribute:(NSDictionary*)dictionary updateOnExistKey:(NSString*)key equals:(id)value
{
    NSManagedObject *object = [self firstObjectFromTable:tableName where:key equals:value];
    
    if (object)
    {
        return [self updateRecord:object withAttribute:dictionary];
    }
    else
    {
        return [self insertRecordInTable:tableName withAttribute:dictionary];
    }
}

#pragma mark - Delete Records
//Delete all records in table.
-(BOOL)flushTable:(NSString*)tableName
{
    NSArray *records = [self allObjectsFromTable:tableName];
    
    [_managedObjectContext performBlockAndWait:^{
        for (NSManagedObject *object in records)
        {
            [_managedObjectContext deleteObject:object];
        }
    }];
    
    return [self save];
}

//Delete object
-(BOOL)deleteRecord:(NSManagedObject*)object
{
    [_managedObjectContext performBlockAndWait:^{
        [_managedObjectContext deleteObject:object];
    }];
    
    return [self save];
}

@end
