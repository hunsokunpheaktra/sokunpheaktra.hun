#import "ParcelEntityManager.h"
#import "GreaterThanCriteria.h"
#import "GreaterThanOrEqualCriteria.h"
#import "LikeCriteria.h"
#import "LessThanCriteria.h"
#import "LessThanOrEqualCriteria.h"
#import "NotInCriteria.h"
#import "ParcelItem.h"

#import "NSObject+SBJson.h"
#import "PhotoUtile.h"
#import "AttachmentEntitymanager.h"
#import "MainViewController.h"

@implementation ParcelEntityManager

static NSMutableArray *columns;

+ (NSArray *)list:(NSString *)entity criterias:(NSDictionary *)criterias {

    NSMutableArray* listRecord = [[NSMutableArray alloc] init];
    NSArray *records = [[DatabaseManager getInstance] select:entity fields:columns criterias:criterias order:nil ascending:false];

    Item* item;
    for (NSDictionary*fields in records) {
        
        item = [[Item alloc] init:entity fields:fields];

        //RSK::select attachment
        NSString *parrentId=@"";
        if ([item.fields objectForKey:@"id"] == nil || [[item.fields objectForKey:@"id"] isEqualToString:@""]) {
            parrentId = [item.fields objectForKey:@"local_id"];
        }else{
            parrentId = [item.fields objectForKey:@"id"];
        }
        NSMutableDictionary *attachment = [AttachmentEntitymanager findAttachmentByParentId:parrentId];
        item.attachments=attachment;
        //end

        [listRecord addObject:item];
        [item release];
    }
    return listRecord;
}


+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally {
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:item.fields];
    
    if(![[tmp valueForKey:@"modified"] isEqualToString:@"2"]){
        [tmp setValue:(modifiedLocally ? @"1" : @"0") forKey:@"modified"];
    }
    
    [[DatabaseManager getInstance] insert:item.entity item:tmp];
    // RSK::after insert parcel item complete process insert attachment
    if (item.attachments != nil && [[item.attachments allKeys] count] > 0) {
        
        Item* user = [MainViewController getInstance].user;
        
        NSString *userId = [user.fields objectForKey:@"id"];
        userId = userId==nil ? @"" : userId;
        userId = [userId isEqualToString:@""] ? [user.fields objectForKey:@"local_id"] : userId;
        
        NSMutableDictionary* criterias = [NSMutableDictionary dictionary];
        [criterias setValue:[[[ValuesCriteria alloc] initWithString:userId] autorelease] forKey:@"user_email"];
        [criterias setValue:[[[ValuesCriteria alloc] initWithString:[item.fields objectForKey:@"trackingNo"]] autorelease] forKey:@"trackingNo"];
        [criterias setValue:[[[ValuesCriteria alloc] initWithString:@"0"] autorelease] forKey:@"deleted"];
        NSArray *itemsExisted = [self list:@"Parcel" criterias:criterias];
        
        Item *inserted = itemsExisted.count > 0 ? [itemsExisted lastObject] : nil;
        if (inserted != nil) {
            for (Item *i in [item.attachments allValues]) {
                NSString *parentId=[inserted.fields objectForKey:@"id"]==nil?[inserted.fields objectForKey:@"local_id"]:[inserted.fields objectForKey:@"id"];
                [i.fields setObject:parentId forKey:@"ParentId"];
                [AttachmentEntitymanager insert:i modifiedLocally:NO];
            }
        }
    }
    //end
    
}

+ (int)getCount:(NSString *)entity{
    int count = [[[DatabaseManager getInstance] select:entity fields:[NSArray arrayWithObject:@"local_id"] criterias:nil order:nil ascending:YES ] count];
    return count;
}

+ (Item *)find:(NSString *)entity column:(NSString *)column value:(NSString *)value{
    NSArray *results = [[DatabaseManager getInstance] select:entity fields:columns column:column value:value order:nil ascending:NO];
    Item *item = nil;
    if ([results count] > 0) {
        NSDictionary *itemFields = [results objectAtIndex:0];
        item = [[Item alloc] init:entity fields:itemFields];
    }
    [results release];

    return item;
}


+ (Item *)find:(NSString *)entity criterias:(NSDictionary *)criterias{
    return nil;
}

+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally {
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    
    if(![[tmp valueForKey:@"modified"] isEqualToString:@"2"]){
        [tmp setValue:(modifiedLocally ? @"1" : @"0") forKey:@"modified"];
    }
    if ([tmp objectForKey:@"local_id"] != Nil) {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"local_id" value:[tmp objectForKey:@"local_id"]];
    } else {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"id" value:[tmp objectForKey:@"id"]];
    }
    [tmp release];
    
    // RSK::after insert parcel item complete process insert attachment
    if (item.attachments != nil && [[item.attachments allKeys] count] > 0) {
        
        Item* user = [MainViewController getInstance].user;
        
        NSString *userId = [user.fields objectForKey:@"id"];
        userId = userId==nil ? @"" : userId;
        userId = [userId isEqualToString:@""] ? [user.fields objectForKey:@"local_id"] : userId;
        
        if (item != nil) {
            for (Item *i in [item.attachments allValues]) {
                NSString *parentId=[item.fields objectForKey:@"id"]==nil?[item.fields objectForKey:@"local_id"]:[item.fields objectForKey:@"id"];
                [i.fields setObject:parentId forKey:@"ParentId"];
                if ([[i.fields objectForKey:@"modified"] isEqualToString:@"1"] && ![[i.fields objectForKey:@"local_id"] isEqualToString:@""]) {
                    [AttachmentEntitymanager update:i modifiedLocally:YES];
                }else if([[i.fields objectForKey:@"modified"] isEqualToString:@"2"]){
                    [AttachmentEntitymanager insert:i modifiedLocally:NO];
                }
            }
        }
    }
    //end
}

+ (void)remove:(Item *)item {
    
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    if ([tmp objectForKey:@"id"] == Nil) {
        [[DatabaseManager getInstance] remove:item.entity column:@"local_id" value:[tmp objectForKey:@"local_id"]];
    } else {
        [[DatabaseManager getInstance] remove:item.entity column:@"id" value:[tmp objectForKey:@"id"]];
    }
    [tmp release];
}

+ (void)initData {
    
}
+ (void)initTable{
    
    DatabaseManager *database = [DatabaseManager getInstance];
    columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    
    [columns addObject:@"local_id"];
    [types addObject:@"INTEGER PRIMARY KEY"];
    [columns addObject:@"id"];
    [types addObject:@"TEXT"];
    [columns addObject:@"modified"];
    [types addObject:@"TEXT"];
    [columns addObject:@"deleted"];
    [types addObject:@"TEXT"];
    [columns addObject:@"error"];
    [types addObject:@"TEXT"];
    [columns addObject:@"user_email"];
    [types addObject:@"TEXT"];
    [columns addObject:@"status"];
    [types addObject:@"TEXT"];
    [columns addObject:@"description"];
    [types addObject:@"TEXT"];

    [columns addObject:@"trackingNo"];
    [types addObject:@"TEXT"];
    [columns addObject:@"forwarder"];
    [types addObject:@"TEXT"];
    [columns addObject:@"receiver"];
    [types addObject:@"TEXT"];
    [columns addObject:@"shippingDate"];
    [types addObject:@"TEXT"];
    [columns addObject:@"reminderDate"];
    [types addObject:@"TEXT"];

    [columns addObject:@"note"];
    [types addObject:@"TEXT"];
    [columns addObject:@"sendProofOfDelivery"];
    [types addObject:@"TEXT"];
    [columns addObject:@"search"];
    [types addObject:@"TEXT"];
    [columns addObject:@"externalId"];
    [types addObject:@"TEXT"];
    [columns addObject:@"statusDate"];
    [types addObject:@"TEXT"];
    [columns addObject:@"location"];
    [types addObject:@"TEXT"];
    [database check:@"Parcel" columns:columns types:types];
    [database createIndex:@"Parcel" column:@"local_id" unique:true];
    
    [types release];
    
}

@end
