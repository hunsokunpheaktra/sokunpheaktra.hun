//
//  ListRequest.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/6/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "EntityRequest.h"


@implementation EntityRequest

@synthesize entity;
@synthesize startRow;
@synthesize ownerFilter;
@synthesize dateFilter;
@synthesize idFilter;
@synthesize partnerFilter;

- (id)initWithEntity:(NSString *)newEntity listener:(NSObject <SOAPListener> *)newListener {
    self = [super init:newListener];
    self.entity = newEntity;
    self.startRow = nil;
    self.idFilter = NO;
    self.partnerFilter = NO;
    return self;
}

- (NSString *)getSoapAction {
    NSString *entityLowercase = [entity lowercaseString];	
    return [NSString stringWithFormat:@"\"document/urn:crmondemand/ws/ecbs/%@/:%@QueryPage\"", entityLowercase, entity];
}

- (void)generateBody:(NSMutableString *)soapMessage {

	NSString *entityLowercase = [entity lowercaseString];	
    [soapMessage appendFormat:@"<%@QueryPage_Input xmlns=\"urn:crmondemand/ws/ecbs/%@/\">", self.entity, entityLowercase];
    [soapMessage appendFormat:@"<ViewMode>%@</ViewMode>", self.ownerFilter];
    [soapMessage appendFormat:@"<ListOf%@ pagesize=\"50\" startrownum=\"%i\">", self.entity, [self.startRow intValue]];
    [soapMessage appendFormat:@"<%@>", self.entity];
    for (NSString *field in [[Configuration getInfo:entity] fields]) {
        if (self.idFilter && [field isEqualToString:@"Id"]) {
            NSString *userId = [[CurrentUserManager read] objectForKey:@"UserId"];
            [soapMessage appendFormat:@"<Id>= '%@'</Id>", userId];
        } else if (!self.idFilter && self.partnerFilter && [entity isEqualToString:@"User"] && [field isEqualToString:@"PartnerOrganizationId"]) {
            NSString *partnerOrgId = [[CurrentUserManager getCurrentUserInfo].fields objectForKey:@"PartnerOrganizationId"];
            [soapMessage appendFormat:@"<PartnerOrganizationId>= '%@'</PartnerOrganizationId>", partnerOrgId];
        } else {
            [soapMessage appendFormat:@"<%@/>", field];
        }
    }
    NSObject<EntityInfo> *info = [Configuration getInfo:entity];
    for (NSString *sublist in [info getSublists]) {
        [soapMessage appendFormat:@"<ListOf%@><%@>", sublist, sublist];
        for (NSString *field in [info getSublistFields:sublist]) {
            [soapMessage appendFormat:@"<%@/>", field];
        }
        [soapMessage appendFormat:@"</%@></ListOf%@>", sublist, sublist];
    }
    if (![self.dateFilter isEqualToString:@"All"]) {
        NSDate *today = [[NSDate alloc] init];
        double delay = 0;
        if ([self.dateFilter isEqualToString:@"Last Week"]) {
            delay = 7.0 * 24 * 60 * 60;
        } else if ([self.dateFilter isEqualToString:@"Last Month"]) {
            delay = 30.0 * 24 * 60 * 60;
        } else if ([self.dateFilter isEqualToString:@"Last Year"]) {
            delay = 365.0 * 24 * 60 * 60;
        }
        NSDate *start = [[NSDate alloc] initWithTimeInterval:-delay sinceDate:today];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSString *dateString = [formatter stringFromDate:start];
        [soapMessage appendFormat:@"<ModifiedDate>&gt; '%@'</ModifiedDate>", dateString];
        [formatter release];
        [start release];
        [today release];
    } else {
        NSString *dateString = [LastSyncManager read:self.entity];
        if (dateString != nil) {
            [soapMessage appendFormat:@"<ModifiedDate>&gt; '%@'</ModifiedDate>", dateString];
        }
    }

    [soapMessage appendFormat:@"</%@>", self.entity];
    [soapMessage appendFormat:@"</ListOf%@>", self.entity];
    [soapMessage appendFormat:@"</%@QueryPage_Input>", self.entity];

}


- (ResponseParser *)getParser {
    return [[EntityResponseParser alloc] initWithEntity:self.entity];
}

- (NSString *)getName {
    return [NSString stringWithFormat:NSLocalizedString(@"READING_DATA", @"READING_DATA"), 
            [LocalizationTools getLocalizedName:self.entity]];
}


- (int)getStep {
    if (self.idFilter && [self.entity isEqualToString:@"User"]) return 3;
    else return 11;}

- (BOOL)prepare {
    NSString *value = [PropertyManager read:[NSString stringWithFormat:@"sync%@", entity]];
    if (![entity isEqualToString:@"User"] && ![value isEqualToString:@"true"]) {
        return NO;
    }
    if ([Configuration isYes:@"LandolakesFilterUsers"]) {
        self.partnerFilter = YES;
    }
    if (self.startRow == nil) {
        self.startRow = [NSNumber numberWithInt:0];
    } else {
        if ([self.retryCount intValue] == 0) {
            self.startRow = [NSNumber numberWithInt:[self.startRow intValue] + 50];
        }
    }
    self.ownerFilter = [PropertyManager read:[NSString stringWithFormat:@"ownerFilter%@", entity]];
    self.dateFilter = [PropertyManager read:[NSString stringWithFormat:@"dateFilter%@", entity]];
    return YES;
}


- (NSString *)requestEntity {
    return self.entity;
}

@end
