#import "EntityManager.h"
#import "InfoFactory.h"
#import "FilterObjectManager.h"
#import "GreaterThanCriteria.h"
#import "GreaterThanOrEqualCriteria.h"
#import "LikeCriteria.h"
#import "LessThanCriteria.h"
#import "LessThanOrEqualCriteria.h"
#import "NotInCriteria.h"
#import "DatetimeHelper.h"

@implementation EntityManager

+ (NSArray *)list:(NSString *)entity criterias:(NSDictionary *)criterias {

    NSMutableArray *list =  [NSMutableArray arrayWithCapacity:1] ;//[[NSMutableArray alloc] initWithCapacity:1];
    NSObject <EntityInfo> *info = [InfoFactory getInfo:entity];
    
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:[info getAllFields]];
    [fields addObject:@"local_id"];
    [fields addObject:@"modified"];
    NSMutableDictionary *newCriterias = [[NSMutableDictionary alloc] initWithDictionary:criterias];
    [newCriterias setValue:[[[ValuesCriteria alloc] initWithString:@"0"] autorelease] forKey:@"deleted"];
    
    NSArray *records = [[DatabaseManager getInstance] select:entity fields:fields criterias:newCriterias order:nil ascending:true];
    for (NSDictionary *record in records) {
        Item *tmpItem = [[Item alloc] init:entity fields:record];
        [list addObject:tmpItem];
        [tmpItem release];
    }
    
   // [info release]; // Latest release
    [newCriterias release];
    [records release];
    [fields release];
    return list;
}

+ (NSArray *)listBySQL:(NSString *)entity statement:(NSString *)statement criterias:(NSDictionary *)criterias fields:(NSArray *)fields {
     NSMutableDictionary *newCriterias = [[NSMutableDictionary alloc] initWithDictionary:criterias];
    for(NSString *key in [criterias allKeys]){
        NSRange range = [key rangeOfString:[NSString stringWithFormat:@"%@.",entity]];
        NSString *newkey = key;
        if(range.length <= 0){
            newkey = [NSString stringWithFormat:@"%@.%@",entity,key];
        }
        [newCriterias setValue:[criterias valueForKey:key] forKey:newkey];
    }
   
    [newCriterias setValue:[[[ValuesCriteria alloc] initWithString:@"0"] autorelease] forKey:[NSString stringWithFormat:@"%@.deleted",entity]];
    
    NSMutableString *sql = [NSMutableString stringWithString:statement];
    [sql appendString:[[DatabaseManager getInstance] getWhere:newCriterias]];
    NSArray *params = [[DatabaseManager getInstance] getParams:newCriterias];
    NSArray *records = [[DatabaseManager getInstance] selectSql:sql params:params fields:fields];
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSDictionary *record in records) {
        Item *tmpItem = [[Item alloc] init:entity fields:record];
        [list addObject:tmpItem];
        [tmpItem release];
    }
    [newCriterias release];
    return list;
}

+ (Item *)find:(NSString *)entity column:(NSString *)column value:(NSString *)value {
    Item *item = nil;
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:[[InfoFactory getInfo:entity] getAllFields]]; // Latest release
    [fields addObject:@"local_id"];
    [fields addObject:@"modified"];
    NSArray *items = [[DatabaseManager getInstance] select:entity fields:fields column:column value:value order:Nil ascending:YES];
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[Item alloc] init:entity fields:itemFields];
    }
    [items release];
    [fields release];
    return item;
}

+ (Item *)find:(NSString *)entity criterias:(NSDictionary *)criterias {
    Item *item = nil;
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:[[InfoFactory getInfo:entity] getAllFields]];
    [fields addObject:@"local_id"];
    [fields addObject:@"modified"];
    [fields addObject:@"error"];
    
    NSArray *items = [[DatabaseManager getInstance] select:entity fields:fields criterias:criterias order:Nil ascending:YES];
       
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[Item alloc] init:entity fields:itemFields];
    }
    [items release];
    [fields release];
    return item;
}

+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally {
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    
    if(![[tmp valueForKey:@"modified"] isEqualToString:@"2"]){
        [tmp setValue:(modifiedLocally ? @"1" : @"0") forKey:@"modified"];
    }
    
    [[DatabaseManager getInstance] insert:item.entity item:tmp];
}

+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally {
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    Item *itmp =[EntityManager find:item.entity column:@"Id" value:[item.fields valueForKey:@"Id"]];
    
    if(![[itmp.fields valueForKey:@"modified"] isEqualToString:@"2"]){
        [tmp setValue:(modifiedLocally ? @"1" : @"0") forKey:@"modified"];
    }
    if ([tmp objectForKey:@"local_id"] != Nil) {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"local_id" value:[tmp objectForKey:@"local_id"]];
    } else {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"Id" value:[tmp objectForKey:@"Id"]];
    }
    [tmp release];
}


+ (void)remove:(Item *)item {
    
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    [tmp setObject:@"1" forKey:@"deleted"];
    
    if ([tmp objectForKey:@"Id"] == Nil) {
        [[DatabaseManager getInstance] remove:item.entity column:@"local_id" value:[tmp objectForKey:@"local_id"]];
    } else {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"Id" value:[tmp objectForKey:@"Id"]];
    }
}


+ (void)setModified:(Item *)item modified:(BOOL)modified {
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithCapacity:1];
    [tmp setValue:modified?@"1":@"0" forKey:@"modified"];
    [[DatabaseManager getInstance] update:item.entity item:tmp column:@"local_id" value:[tmp objectForKey:@"local_id"]];
}

+ (int) getCount:(NSString *)entity{
    int count = [[[DatabaseManager getInstance] select:entity fields:[NSArray arrayWithObject:@"local_id"] criterias:nil order:nil ascending:YES ] count]; 
    return count;
}

+ (void)initData {
    
}

+ (void)initTables {
    DatabaseManager *database = [DatabaseManager getInstance];
    NSMutableArray *entities = [InfoFactory getEntities];
    for (NSString *entity in entities) {
        NSObject <EntityInfo> *info = [InfoFactory getInfo:entity];
        NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
        [columns addObject:@"local_id"];
        [types addObject:@"INTEGER PRIMARY KEY"];
        [columns addObject:@"modified"];
        [types addObject:@"INTEGER"];
        [columns addObject:@"deleted"];
        [types addObject:@"INTEGER"];
        [columns addObject:@"error"];
        [types addObject:@"TEXT"];

        //Warning !! All fields are typed TEXT - Temporary 
        for (NSString *field in [info getAllFields]) {
            NSString *typename = @"TEXT";
            [columns addObject:field];
            NSString *typeByInfo = [info getFieldTypeByName:field];
            if([typeByInfo isEqualToString:@"double"] || [typeByInfo isEqualToString:@"currency"]){
                typename = @"NUMERIC";
            }else if([typeByInfo isEqualToString:@"int"]){
                typename = @"INTEGER";
            }else if([typeByInfo isEqualToString:@"blob"]){
                typename = @"BLOB";
            }
            [types addObject:typename];
        }
        
        
        [database check:entity columns:columns types:types];
        [columns release];
        [types release];
        
        [database createIndex:entity column:@"Id" unique:false];
       
        
    }
}
+ (void)initTable:(NSString*)entity column:(NSArray*)newColumns type:(NSArray*)newTypes{
    
    DatabaseManager *database = [DatabaseManager getInstance];
    NSMutableArray *entities = [InfoFactory getEntities];
    for (NSString *entity in entities) {
        NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
        [columns addObject:@"local_id"];
        [types addObject:@"INTEGER PRIMARY KEY"];
        [columns addObject:@"modified"];
        [types addObject:@"INTEGER"];
        [columns addObject:@"deleted"];
        [types addObject:@"INTEGER"];
        [columns addObject:@"error"];
        [types addObject:@"TEXT"];
        
        //Warning !! All fields are typed TEXT - Temporary 
        [columns addObjectsFromArray:newColumns];
        [types addObjectsFromArray:newTypes];
        [database check:entity columns:columns types:types];
        [database createIndex:entity column:@"Id" unique:false];
        
        [columns release];
        [types release];
        
    }

    
}

@end
