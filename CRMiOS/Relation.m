//
//  Relation.m
//  CRMiPad
//
//  Created by Sy Pauv Phou on 3/30/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "Relation.h"


@implementation Relation

@synthesize srcEntity;
@synthesize srcKey;
@synthesize destEntity;
@synthesize destKey;
@synthesize srcFields;
@synthesize destFields;


static NSMutableArray *relations;

- (id)initWith:(NSString *)newSrcEntity srcKey:(NSString *)newSrcKey destEntity:(NSString *)newDestEntity destKey:(NSString *)newDestKey srcFields:(NSArray *)newSrcFields destFields:(NSArray *)newDestFields {
    self = [super init];
    self.srcEntity = newSrcEntity;
    self.srcKey = newSrcKey;
    self.destEntity = newDestEntity;
    self.destKey = newDestKey;
    self.srcFields = newSrcFields;
    self.destFields = newDestFields;
    return self;
    
}

+ (void)resetRelations {
    relations = nil;
}

+ (NSMutableArray *)allRelations {
    if (relations == nil) {
        relations = [[NSMutableArray alloc] initWithCapacity:1];

        //
        // Account relations
        //
        [relations addObject:[[Relation alloc] initWith:@"Account" srcKey:@"PrimaryContactId" destEntity:@"Contact" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"PrimaryContactFullName"] destFields:[NSArray arrayWithObject:@"ContactFullName"]]];
        [relations addObject:[[Relation alloc] initWith:@"Account" srcKey:@"OwnerId" destEntity:@"User" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"Owner", @"OwnerFullName", nil] destFields:[NSArray arrayWithObjects:@"FullName", @"FullName", nil]]];        
        [relations addObject:[[Relation alloc] initWith:@"Account" srcKey:@"SourceCampaignId" destEntity:@"Campaign" destKey:@"Id" srcFields:nil destFields:nil]];
        [relations addObject:[[Relation alloc] initWith:@"Account" srcKey:@"ParentAccountId" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"ParentAccount"] destFields:[NSArray arrayWithObject:@"AccountName"]]];
        
        //
        // Contact relations
        //
        [relations addObject:[[Relation alloc] initWith:@"Contact" srcKey:@"AccountId" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"AccountName", nil] destFields:[NSArray arrayWithObjects:@"AccountName", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Contact" srcKey:@"SourceCampaignId" destEntity:@"Campaign" destKey:@"Id" srcFields:nil destFields:nil]];
        [relations addObject:[[Relation alloc] initWith:@"Contact" srcKey:@"OwnerId" destEntity:@"User" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"Owner", @"OwnerFullName", nil] destFields:[NSArray arrayWithObjects:@"FullName", @"FullName", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Contact" srcKey:@"ManagerId" destEntity:@"Contact" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"Manager", nil] destFields:[NSArray arrayWithObjects:@"ContactFullName", nil]]];

        
        
        //
        // Activity relations
        //
        [relations addObject:[[Relation alloc] initWith:@"Activity" srcKey:@"AccountId" destEntity:@"Account" destKey:@"Id" srcFields: [NSArray arrayWithObjects:@"AccountName", nil] destFields:[NSArray arrayWithObjects:@"AccountName", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Activity" srcKey:@"PrimaryContactId" destEntity:@"Contact" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"PrimaryContact", @"PrimaryContactFirstName", @"PrimaryContactLastName", nil] destFields:[NSArray arrayWithObjects:@"ContactFullName", @"ContactFirstName", @"ContactLastName", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Activity" srcKey:@"LeadId" destEntity:@"Lead" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"Lead", nil] destFields:[NSArray arrayWithObjects:@"LeadFullName", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Activity" srcKey:@"OpportunityId" destEntity:@"Opportunity" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"OpportunityName", nil] destFields:[NSArray arrayWithObjects:@"OpportunityName", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Activity" srcKey:@"OwnerId" destEntity:@"User" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"PrimaryOwnerId", @"Alias", nil] destFields:[NSArray arrayWithObjects:@"Id", @"Alias", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Activity" srcKey:@"CampaignId" destEntity:@"Campaign" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"CampaignName", nil] destFields:[NSArray arrayWithObjects:@"CampaignName", nil]]];
        //
        // Service Request relations
        //
        [relations addObject:[[Relation alloc] initWith:@"ServiceRequest" srcKey:@"AccountId" destEntity:@"Account" destKey:@"Id" srcFields:nil destFields:nil]];
        [relations addObject:[[Relation alloc] initWith:@"ServiceRequest" srcKey:@"ContactId" destEntity:@"Contact" destKey:@"Id" srcFields:nil destFields:nil]];
        
        //
        // Opportunity relations
        //
        [relations addObject:[[Relation alloc] initWith:@"Opportunity" srcKey:@"AccountId" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"AccountName", nil] destFields:[NSArray arrayWithObjects:@"AccountName", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Opportunity" srcKey:@"OwnerId" destEntity:@"User" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"Owner", nil] destFields:[NSArray arrayWithObjects: @"FullName", nil]]];
        //[relations addObject:[[Relation alloc] initWith:@"Opportunity" srcKey:@"KeyContactId" destEntity:@"Contact" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"KeyContactLastName", nil] destFields:[NSArray arrayWithObjects:@"ContactLastName", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Opportunity" srcKey:@"SourceCampaignId" destEntity:@"Campaign" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"SourceCampaign"]  destFields:[NSArray arrayWithObject:@"CampaignName"] ]];
        [relations addObject:[[Relation alloc] initWith:@"Opportunity" srcKey:@"CustomObject1Id" destEntity:@"CustomObject1" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"CustomObject1Name"] destFields:[NSArray arrayWithObject:@"Name"]]];
        [relations addObject:[[Relation alloc] initWith:@"Opportunity" srcKey:@"ParentoptyId" destEntity:@"Opportunity" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"ParentoptyOpportunityName"] destFields:[NSArray arrayWithObject:@"OpportunityName"]]];
        
        //
        // Lead relations
        //
        [relations addObject:[[Relation alloc] initWith:@"Lead" srcKey:@"AccountId" destEntity:@"Account" destKey:@"Id" srcFields:nil destFields:nil]];
        [relations addObject:[[Relation alloc] initWith:@"Lead" srcKey:@"CampaignId" destEntity:@"Campaign" destKey:@"Id" srcFields:nil destFields:nil]];
        [relations addObject:[[Relation alloc] initWith:@"Lead" srcKey:@"ContactId" destEntity:@"Contact" destKey:@"Id" srcFields:nil destFields:nil]];
        [relations addObject:[[Relation alloc] initWith:@"Lead" srcKey:@"OpportunityId" destEntity:@"Opportunity" destKey:@"Id" srcFields:nil destFields:nil]];
        [relations addObject:[[Relation alloc] initWith:@"Lead" srcKey:@"OwnerId" destEntity:@"User" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"LeadOwner", @"Owner", nil] destFields:[NSArray arrayWithObjects:@"FullName", @"FullName", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Lead" srcKey:@"SalesRepId" destEntity:@"User" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"SalesPersonFullName", @"SalesPerson", nil] destFields:[NSArray arrayWithObjects:@"FullName", @"Alias", nil]]];
        
        //
        // Special Pricing Request relations
        //
        [relations addObject:[[Relation alloc] initWith:@"SPRequest" srcKey:@"PrincipalPartnerAccountId" destEntity:@"Account" destKey:@"Id" srcFields:nil destFields:nil]];
        [relations addObject:[[Relation alloc] initWith:@"SPRequest" srcKey:@"EndCustomerId" destEntity:@"Account" destKey:@"Id" srcFields:nil destFields:nil]];
        
        //
        // Price List Line Item relations
        //
        [relations addObject:[[Relation alloc] initWith:@"PriceListLineItem" srcKey:@"ProductId" destEntity:@"Product" destKey:@"Id" srcFields:nil destFields:nil]];
        [relations addObject:[[Relation alloc] initWith:@"PriceListLineItem" srcKey:@"PriceListId" destEntity:@"PriceList" destKey:@"Id" srcFields:nil destFields:nil]];
        
        //
        // Asset relations
        //
        [relations addObject:[[Relation alloc] initWith:@"Asset" srcKey:@"AccountId" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"AccountName", nil] destFields:[NSArray arrayWithObjects:@"AccountName", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Asset" srcKey:@"ProductId" destEntity:@"Product" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"Product", nil] destFields:[NSArray arrayWithObjects:@"Name", nil]]];
        
        //
        // Product relations
        //
        [relations addObject:[[Relation alloc] initWith:@"Product" srcKey:@"ProductCategoryId" destEntity:@"Category" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"ProductCategory", nil] destFields:[NSArray arrayWithObjects:@"Name", nil]]];
        
        //
        // Custom Object 1 relations
        //
        [relations addObject:[[Relation alloc] initWith:@"CustomObject1" srcKey:@"AccountId" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"AccountName"] destFields:[NSArray arrayWithObject:@"AccountName"]]];
        [relations addObject:[[Relation alloc] initWith:@"CustomObject1" srcKey:@"OpportunityId" destEntity:@"Opportunity" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"OpportunityName"] destFields:[NSArray arrayWithObject:@"OpportunityName"]]];
        [relations addObject:[[Relation alloc] initWith:@"CustomObject1" srcKey:@"ContactId" destEntity:@"Contact" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"ContactFirstName", @"ContactLastName", @"ContactFullName", @"ContactExternalSystemId", nil] destFields:[NSArray arrayWithObjects:@"ContactFirstName", @"ContactLastName", @"ContactFullName", @"ExternalSystemId", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"CustomObject1" srcKey:@"ProductId" destEntity:@"Product" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"ProductName"] destFields:[NSArray arrayWithObject:@"Name"]]];
        [relations addObject:[[Relation alloc] initWith:@"CustomObject1" srcKey:@"OwnerId" destEntity:@"User" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"Owner"] destFields:[NSArray arrayWithObject:@"FullName"]]];
        //
        // Custom Object 2 relations
        //
        [relations addObject:[[Relation alloc] initWith:@"CustomObject2" srcKey:@"AccountId" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"AccountName"] destFields:[NSArray arrayWithObject:@"AccountName"]]];
        [relations addObject:[[Relation alloc] initWith:@"CustomObject2" srcKey:@"OpportunityId" destEntity:@"Opportunity" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"OpportunityName"] destFields:[NSArray arrayWithObject:@"OpportunityName"]]];
        [relations addObject:[[Relation alloc] initWith:@"CustomObject2" srcKey:@"CustomObject1Id" destEntity:@"CustomObject1" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"CustomObject1Name"] destFields:[NSArray arrayWithObject:@"Name"]]];
        [relations addObject:[[Relation alloc] initWith:@"CustomObject2" srcKey:@"ContactId" destEntity:@"Contact" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"ContactFirstName", @"ContactLastName", @"ContactFullName", nil] destFields:[NSArray arrayWithObjects:@"ContactFirstName", @"ContactLastName", @"ContactFullName", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"CustomObject2" srcKey:@"ProductId" destEntity:@"Product" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"ProductName"] destFields:[NSArray arrayWithObject:@"Name"]]];
        [relations addObject:[[Relation alloc] initWith:@"CustomObject2" srcKey:@"OwnerId" destEntity:@"User" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"Owner"] destFields:[NSArray arrayWithObject:@"FullName"]]];
        //
        // Custom Object 3 relations
        //
        [relations addObject:[[Relation alloc] initWith:@"CustomObject3" srcKey:@"AccountId" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"AccountName"] destFields:[NSArray arrayWithObject:@"AccountName"]]];
        [relations addObject:[[Relation alloc] initWith:@"CustomObject3" srcKey:@"OpportunityId" destEntity:@"Opportunity" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"OpportunityName"] destFields:[NSArray arrayWithObject:@"OpportunityName"]]];
        [relations addObject:[[Relation alloc] initWith:@"CustomObject3" srcKey:@"ContactId" destEntity:@"Contact" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"ContactFirstName", @"ContactLastName", @"ContactFullName", nil] destFields:[NSArray arrayWithObjects:@"ContactFirstName", @"ContactLastName", @"ContactFullName", nil]]];
        
        //
        // Custom Object 4 relations
        //
        [relations addObject:[[Relation alloc] initWith:@"CustomObject4" srcKey:@"AccountId" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"AccountName"] destFields:[NSArray arrayWithObject:@"AccountName"]]];
        [relations addObject:[[Relation alloc] initWith:@"CustomObject4" srcKey:@"OpportunityId" destEntity:@"Opportunity" destKey:@"Id" srcFields:[NSArray arrayWithObject:@"OpportunityName"] destFields:[NSArray arrayWithObject:@"OpportunityName"]]];
        [relations addObject:[[Relation alloc] initWith:@"CustomObject4" srcKey:@"OwnerId" destEntity:@"User" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"OwnerAlias", @"OwnerFirstName", @"OwnerLastName", @"OwnerFullName", nil] destFields:[NSArray arrayWithObjects:@"Alias", @"FirstName", @"LastName", @"FullName", nil]]];

        // Opportunity contact relations
        [relations addObject:[[Relation alloc] initWith:@"Opportunity ContactRole" srcKey:@"ContactId" destEntity:@"Contact" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"ContactFirstName", @"ContactLastName", nil] destFields:[NSArray arrayWithObjects:@"ContactFirstName", @"ContactLastName", nil]]];
        
        // Activity user relations
        [relations addObject:[[Relation alloc] initWith:@"Activity User" srcKey:@"UserId" destEntity:@"User" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"UserAlias", @"UserFirstName", @"UserLastName", nil] destFields:[NSArray arrayWithObjects:@"Alias", @"FirstName", @"LastName", nil]]];
        
        // Activity contact relations
        [relations addObject:[[Relation alloc] initWith:@"Activity Contact" srcKey:@"Id" destEntity:@"Contact" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"ContactFirstName", @"ContactLastName", @"ContactFullName", nil] destFields:[NSArray arrayWithObjects:@"ContactFirstName", @"ContactLastName", @"ContactFullName", nil]]];
        
        // Account partner relations
        [relations addObject:[[Relation alloc] initWith:@"Account Partner" srcKey:@"PrimaryContactId" destEntity:@"Contact" destKey:@"Id" srcFields:nil destFields:nil]];
        [relations addObject:[[Relation alloc] initWith:@"Account Partner" srcKey:@"PartnerId" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"PartnerName", nil] destFields:[NSArray arrayWithObjects:@"AccountName", nil]]];
        
        // Account Competitor relations
        [relations addObject:[[Relation alloc] initWith:@"Account Competitor" srcKey:@"CompetitorId" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"CompetitorName", nil] destFields:[NSArray arrayWithObjects:@"AccountName", nil]]];
        
        // Opportunity Product Revenue relations
        [relations addObject:[[Relation alloc] initWith:@"Opportunity ProductRevenue" srcKey:@"ProductId" destEntity:@"Product" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"ProductName", nil] destFields:[NSArray arrayWithObjects:@"Name", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Opportunity ProductRevenue" srcKey:@"AccountId" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"AccountName", nil] destFields:[NSArray arrayWithObjects:@"AccountName", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Opportunity ProductRevenue" srcKey:@"OwnerId" destEntity:@"User" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"Owner", nil] destFields:[NSArray arrayWithObjects:@"FullName", nil]]];
        [relations addObject:[[Relation alloc] initWith:@"Opportunity ProductRevenue" srcKey:@"ProductCategoryId" destEntity:@"Category" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"ProductCategory", nil] destFields:[NSArray arrayWithObjects:@"Name", nil]]];
        
        // Opportunity Competitor relations
        [relations addObject:[[Relation alloc] initWith:@"Opportunity Competitor" srcKey:@"CompetitorId" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"CompetitorName", nil] destFields:[NSArray arrayWithObjects:@"AccountName", nil]]];
        
        // Opportunity partner relations
        [relations addObject:[[Relation alloc] initWith:@"Opportunity Partner" srcKey:@"PrimaryContactId" destEntity:@"Contact" destKey:@"Id" srcFields:nil destFields:nil]];
        [relations addObject:[[Relation alloc] initWith:@"Opportunity Partner" srcKey:@"PartnerId" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"PartnerName", nil] destFields:[NSArray arrayWithObjects:@"AccountName", nil]]];
        
        // ******** NESTLE SPECIFIC ********
        if ([Configuration isYes:@"NestleWholesaleAccount"]) {
            [relations addObject:[[Relation alloc] initWith:@"Opportunity" srcKey:@"CustomText33" destEntity:@"Account" destKey:@"Id" srcFields:[NSArray arrayWithObjects:@"CustomText34", @"CustomText0", @"CustomPickList13", nil] destFields:[NSArray arrayWithObjects:@"AccountName", @"CustomText4", @"CustomPickList8", nil]]];
        }
        
    }
    return relations;
}


+ (NSArray *)getEntityRelations:(NSString *)entity {
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:1];
    for (Relation *relation in [self allRelations]) {
        if (([relation.srcEntity isEqualToString:entity] && [relation.destEntity rangeOfString:@" "].location == NSNotFound)
            || ([relation.destEntity isEqualToString:entity] && [relation.srcEntity rangeOfString:@" "].location == NSNotFound)) {
            if ([[Configuration getInfo:relation.srcEntity] enabled]
                && [[Configuration getInfo:relation.destEntity] enabled]) {
                if ([[[Configuration getInfo:relation.srcEntity] getSubtypes] count] > 0
                    && [[[Configuration getInfo:relation.destEntity] getSubtypes] count] > 0) {
                    [results addObject:relation];
                }
            }
        }
    }
    return results;
}



@end
