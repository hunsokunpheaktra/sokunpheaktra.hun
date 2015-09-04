//
//  ParcelItem.m
//  Parcel
//
//  Created by Davin Pen on 10/2/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "ParcelItem.h"

@implementation ParcelItem
@synthesize  data;

-(id)initWithData:(NSMutableDictionary *)d{
    self.data=d;
    return [super init];
}

+(NSArray*)allFieldNames{
    return@[@"description",@"trackingNo",@"forwarder",@"status",@"receiver",@"shippingDate",@"reminderDate",@"note",@"sendProofOfDelivery"];
}


+(NSMutableDictionary*)newItem{
    NSArray *allValues = [[NSArray alloc] initWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",nil];
    return [NSMutableDictionary dictionaryWithObjects:allValues forKeys:[self allFieldNames]];
}

+(NSArray*)allDataInfo{
    
    NSArray *allFieldLabel = @[DESCRIPTION,REMINDER_DATE,NOTE];
    NSArray *allFieldName = @[@"description",@"reminderDate",@"note"];
    NSMutableArray *section = [[NSMutableArray alloc] initWithCapacity:1];
    
    for(int i=0;i<allFieldName.count;i++){
        
        NSMutableDictionary *fieldItem = [NSMutableDictionary dictionary];
        NSString *fieldName = [allFieldName objectAtIndex:i];
        NSString *fieldLabel = [allFieldLabel objectAtIndex:i];
        
        [fieldItem setObject:fieldName forKey:@"fieldName"];
        [fieldItem setObject:fieldLabel forKey:@"fieldLabel"];
        [section addObject:fieldItem];
    }
    
    return section;
    
}

+(NSArray*)allSections{
    
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSMutableArray *section = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *allFieldLabel = [NSArray arrayWithObjects:DESCRIPTION,TRACKING_NO,FORWARDER, nil];;
    NSArray *allFieldName = [NSArray arrayWithObjects:@"description",@"trackingNo",@"forwarder", nil];
    
    for(int i=0;i<allFieldName.count;i++){
        NSMutableDictionary *fieldItem = [NSMutableDictionary dictionary];
        NSString *fieldName = [allFieldName objectAtIndex:i];
        NSString *fieldLabel = [allFieldLabel objectAtIndex:i];
        
        [fieldItem setObject:fieldName forKey:@"fieldName"];
        [fieldItem setObject:fieldLabel forKey:@"fieldLabel"];
        [section addObject:fieldItem];

    }
    [sections addObject:section];
    [section release];
    
    allFieldLabel = [NSArray arrayWithObjects:STATUS,RECEIVER,SHIPPING_DATE,REMINDER_DATE,PICTURE_CONTENT,NOTE,SEND_DELIVERY_PROOF,FORWARDER_LINK,nil];
    allFieldName = [NSArray arrayWithObjects:@"status",@"receiver",@"shippingDate",@"reminderDate",@"pictureContent",@"note",@"sendProofOfDelivery",@"forwarderLink",nil];
    
    section = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i=0; i<allFieldName.count; i++) {
        NSMutableDictionary *fieldItem = [NSMutableDictionary dictionary];
        NSString *fieldName = [allFieldName objectAtIndex:i];
        NSString *fieldLabel = [allFieldLabel objectAtIndex:i];
        
        [fieldItem setObject:fieldName forKey:@"fieldName"];
        [fieldItem setObject:fieldLabel forKey:@"fieldLabel"];
        [section addObject:fieldItem];
    }
    [sections addObject:section];
    [section release];
    
    return sections;

}

@end
