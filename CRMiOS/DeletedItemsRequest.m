//
//  DeletedItemsRequest.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/13/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "DeletedItemsRequest.h"


@implementation DeletedItemsRequest
@synthesize startRow;

- (id)initWithListener:(NSObject <SOAPListener> *)newListener {
    self.startRow = nil;
    
    return [super init:newListener];
}

- (NSString *)getSoapAction {
    
    return @"\"document/urn:crmondemand/ws/deleteditem/:DeletedItemQueryPage\"";
    
   }

- (void)generateBody:(NSMutableString *)soapMessage {
    
    [soapMessage appendString:@"<DeletedItemWS_DeletedItemQueryPage_Input xmlns='urn:crmondemand/ws/deleteditem/'>"];
    [soapMessage appendFormat:@"<StartRowNum>%i</StartRowNum>",[self.startRow intValue]];
    [soapMessage appendString:@"<PageSize>50</PageSize>"];
    [soapMessage appendString:@"<ListOfDeletedItem>"];
    [soapMessage appendString:@"<DeletedItem>"];
    [soapMessage appendString:@"<DeletedItemId/>"];
    [soapMessage appendFormat:@"<DeletedDate>&gt; '%@'</DeletedDate>", [PropertyManager read:@"PreviousSyncStart"]];
    [soapMessage appendString:@"<Name/>"];
    [soapMessage appendString:@"<ObjectId/>"];
    [soapMessage appendString:@"<Type/>"];
    [soapMessage appendString:@"<ExternalSystemId/>"];
    [soapMessage appendString:@"</DeletedItem>"];
    [soapMessage appendString:@"</ListOfDeletedItem>"];
    [soapMessage appendString:@"</DeletedItemWS_DeletedItemQueryPage_Input>"];

}

- (ResponseParser *)getParser {
    return [[DeletedItemsResponseParser alloc]init];
}

- (int)getStep {
    return 10;
}

- (NSString *)getURLSuffix {
    return @"Services/Integration";
}

- (NSString *)getName {
    return NSLocalizedString(@"READING_DELETE_ITEM", @"READING_DELETE_ITEM");
}

- (BOOL)prepare {
    // if there was no previous sync, no need to read deleted items
    if ([PropertyManager read:@"PreviousSyncStart"] == nil) {
        return NO;
    }
    if (self.startRow == nil) {
        self.startRow = [NSNumber numberWithInt:0];
    } else {
        if ([self.retryCount intValue] == 0) {
            self.startRow = [NSNumber numberWithInt:[self.startRow intValue] + 50];
        }
    }
    return YES;
}

@end
