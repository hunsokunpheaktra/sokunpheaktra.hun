//
//  AccountGrid.m
//  SyncForce
//
//  Created by Gaeasys Admin on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountGrid.h"
#import "GridItem.h"
#import "Datagrid.h"
#import "AppDelegate.h"
#import "EntityManager.h"
#import "Criteria.h"
#import "LikeCriteria.h"
#import "Entity.h"
#import "EditView.h"
#import "Item.h"
#import "OpportunityGrid.h"
#import "DataType.h"
#import "EditViewController.h"

@implementation AccountGrid

@synthesize rows,columnNames,apiColumnNames,fieldInfos;

-(id)init{
    [super init];
    
    self.fieldInfos = [(Entity *)[InfoFactory getInfo:[self getEntityName]] fieldsInfo];
    return self;
}

-(void) callback:(GridItem *)griditem{
    
    if([[griditem clickReason] isEqualToString:[Datagrid getActionImg]]){
        
        NSObject <DatagridListener,DataModel> * listenerWithModel = [[OpportunityGrid alloc] initWithGridItem:griditem];
        
        Datagrid *dataGrid = [[Datagrid alloc] initWithFrame:[UIScreen mainScreen].applicationFrame 
                                                    listener:listenerWithModel model:listenerWithModel 
                                              idlookChlidren:NO idnewChlid:NO idrecordEdit:YES];
        dataGrid.title =NSLocalizedString(@"OPPORTUNITY", Nil);        
        
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        UITabBarController *tabController = (UITabBarController*)delegate.window.rootViewController;
        UINavigationController *nav = (UINavigationController*)tabController.selectedViewController;
        
        [nav pushViewController:dataGrid animated:YES];
        
    }
    
    else if([[griditem clickReason] isEqualToString:[Datagrid getAddImg]]){

        EditViewController *newview = [[EditViewController alloc] init:[[Item alloc] init:@"Opportunity" fields:nil] mode:[Datagrid getAddImg] objectId:griditem.entityId relationField:nil];
        newview.title = NSLocalizedString(@"NEW_OPPORTUNITY", Nil);
        
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        UITabBarController *tabController = (UITabBarController*)delegate.window.rootViewController;
        UINavigationController *nav = (UINavigationController*)tabController.selectedViewController;
        
        [nav pushViewController:newview animated:YES];
        
    }else if([[griditem clickReason] isEqualToString:[Datagrid getEditImg]]){
        
    }
    
}

-(NSArray*) getListReferenceBy:(NSString*)entity {
    return nil;
}

-(NSArray*) getPickListBy:(NSString*)fieldName recordTypeId:(NSString*)recordTypeId {
    return nil;
}

-(void)addForm:(UINavigationController *)navigation {

}

-(void) clearListEdit {

}
- (void) deleteRecordById:(NSString *)recordId {

}

-(NSMutableDictionary*) getValueBy:(NSString*)fieldName recordId:(NSString*)recordId {
    return nil;
}

- (NSString *) getEntityName {
    return @"Account";
}

- (int) getColumType:(int) columnIndex{
    NSString *colname = [self.apiColumnNames objectAtIndex:columnIndex];
    for(Item *item in fieldInfos){
        if(![colname isEqualToString:[[item fields]valueForKey:@"name"]]) continue;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"datetime"]) return TYPE_DATETIME;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"date"]) return TYPE_DATE;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"currency"]) return TYPE_CURRENCY;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"double"]) return TYPE_DOUBLE;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"int"]) return TYPE_INT;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"blob"]) return TYPE_BLOB;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"boolean"]) return TYPE_BOOLEAN;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"percent"]) return TYPE_PERCENT;
    }
    return TYPE_STRING;
}

- (NSString *) getParentColumnName{
    return nil;
}

- (int) getRowCount{
    return [self.rows count];
}

- (int) getColumnCount{
    return [self.columnNames count];
}

- (NSString *) getColumnName:(int) columnIndex{
    return [self.columnNames objectAtIndex:columnIndex];
}

- (NSString *) getApiColumnName:(int) columnIndex{
    return [self.apiColumnNames objectAtIndex:columnIndex];
}

- (NSString *) getValueAt:(int)rowIndex columnIndex:(int)columnIndex{
    NSString* colname = [self getColumnName:columnIndex];
    Item *item = [self.rows objectAtIndex:rowIndex];
    return [item.fields objectForKey:colname];
}

- (void) populate{
    
    NSString *stm = @"Select Id, Name As 'Account Name', BillingCity As 'City', BillingCountry As 'Country', BillingStreet As 'Address' From Account ";

    self.columnNames = [NSMutableArray arrayWithObjects:@"Id",@"Account Name",@"City",@"Country",@"Address", nil];
    
    self.apiColumnNames = [NSMutableArray arrayWithObjects:@"Id",@"Name",@"BillingCity",@"BillingCountry",@"BillingStreet", nil];
    
    self.rows = [EntityManager listBySQL:[self getEntityName] statement:stm criterias:[[NSDictionary alloc] init] fields:self.columnNames];
}

- (NSString *) getIdColumn{
    return @"Id";
}

-(void) save{
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL) isEditable:(int)columnIndex{
    return NO;
}

- (void) setValueAt:(int)rowIndex columnIndex:(int)columnIndex  oldValue:(NSString*)oldValue newValue:(NSString*)newValue{
    
}

-(void)dealloc{		
    [fieldInfos release];
	[rows release];
    [columnNames release];
	[apiColumnNames release];
    [super dealloc];
}


@end
