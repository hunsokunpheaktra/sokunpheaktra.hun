//
//  OpportunityGrid.m
//  SyncForce
//
//  Created by Gaeasys Admin on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpportunityNativeGrid.h"
#import "GridItem.h"
#import "Datagrid.h"
#import "AppDelegate.h"
#import "EntityManager.h"
#import "Criteria.h"
#import "LikeCriteria.h"
#import "Entity.h"
#import "EditView.h"
#import "Item.h"
#import "OpportunityNativeGrid.h"

@implementation OpportunityNativeGrid
@synthesize gridItem;

-(id)initWithGridItem:(GridItem*) pgridItem{
    self.gridItem = pgridItem;
    [super init];
    return self;
}

-(void) callback:(GridItem *)griditem{
    
    if([[griditem clickReason] isEqualToString:[Datagrid getActionImg]]){
        //    NSString* info = [[NSString alloc] initWithFormat:@"Click %@ : %@ : %@",griditem.objectName,griditem.entityId,griditem.clickReason];
        //    UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"JavaScript called" message:  info delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        //    [alert show];
        //    [alert release];
    }
    else if([[griditem clickReason] isEqualToString:[Datagrid getAddImg]]){
        
    }else if([[griditem clickReason] isEqualToString:[Datagrid getEditImg]]){
        
        EditView *editView = [[EditView alloc] initWithMode:[Datagrid getEditImg] entity:@"Opportunity"];
        editView.title = @"Edit Opportunity";
        [editView setObjectId:griditem.entityId];
        
        AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [delegate.theNavController presentModalViewController:editView animated:YES];
    }
}

- (NSString *) getEntityName{
    return @"Opportunity";
}

- (NSString *) getParentColumnName{
    return @"AccountId";
}

- (void) populate{
    NSMutableDictionary *criterias = [[NSMutableDictionary alloc] initWithCapacity:1];
    [criterias setValue:[[LikeCriteria alloc] initWithValue:[self.gridItem entityId]] forKey:[self getParentColumnName]];
    
    
    NSString *stm = @"Select Id, Name, StageName As 'Stage', Amount,TrackingNumber__c As 'Tracking Number' From Opportunity ";
    
    self.columnNames = [NSMutableArray arrayWithObjects:@"Id", @"Name",@"Stage",@"Amount",@"Tracking Number", nil];
    self.apiColumnNames = [NSMutableArray arrayWithObjects:@"Id", @"Name",@"StageName",@"Amount",@"TrackingNumber__c", nil];
    self.rows = [EntityManager listBySQL:[self getEntityName] statement:stm criterias:criterias fields:self.columnNames];
    
    
}

- (NSString *) getIdColumn{
    return @"Id";
}

- (NSString *) getLocalIdColumn{
    return @"local_id";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)dealloc{		
	[rows release];
    [columnNames release];
	[apiColumnNames release];
    [super dealloc];
}

@end
