//
//  AccountGrid.m
//  SyncForce
//
//  Created by Gaeasys Admin on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountNativeGrid.h"
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
#import "CustomDataGrid.h"
#import "OpportunityNativeGrid.h"
#import "EditViewController.h"


@implementation AccountNativeGrid
@synthesize rows,columnNames,apiColumnNames,fieldInfos,rowDataMassAdd;

-(id)init{
    [super init];
    self.fieldInfos = [(Entity *)[InfoFactory getInfo:[self getEntityName]] fieldsInfo];
    return self;
}

- (void) deleteRecordById:(NSString *)recordId{
    
}
-(void) clearListEdit{
    
}

-(void) callback:(GridItem *)griditem{
    // NSString* info = [[NSString alloc] initWithFormat:@"Click %@ : %@ : %@",griditem.objectName,griditem.entityId,griditem.clickReason];
    //  UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"JavaScript called" message:  info delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    //  [alert show];
    // [alert release];
    
    if([[griditem clickReason] isEqualToString:[Datagrid getActionImg]]){
        
        NSObject <DatagridListener,DataModel> * listenerWithModel = [[OpportunityNativeGrid alloc] initWithGridItem:griditem];
        
        //        Datagrid *dataGrid = [[Datagrid alloc] initWithFrame:[UIScreen mainScreen].applicationFrame 
        //                                                    listener:listenerWithModel model:listenerWithModel 
        //                                              idlookChlidren:NO idnewChlid:NO idrecordEdit:YES];
        
        
        CustomDataGrid *dataGrid = [[CustomDataGrid alloc] initWithPopulate:listenerWithModel listener:listenerWithModel rowNumber:10];
        
        dataGrid.title = NSLocalizedString(@"OPPORTUNITY", Nil); 
        AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [delegate.theNavController pushViewController:dataGrid animated:YES];
    }
    
    else if([[griditem clickReason] isEqualToString:[Datagrid getAddImg]]){
        
        EditView *newview = [[EditView alloc] initWithMode:[Datagrid getAddImg] entity:@"Opportunity"];
        newview.title =  NSLocalizedString(@"NEW_OPPORTUNITY", Nil);
        [newview setObjectId:griditem.entityId];
        
        AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [delegate.theNavController presentModalViewController:newview animated:YES];
        
    }else if([[griditem clickReason] isEqualToString:[Datagrid getEditImg]]){
        //    NSString* info = [[NSString alloc] initWithFormat:@"Click %@ : %@ : %@",griditem.objectName,griditem.entityId,griditem.clickReason];
        //    UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"JavaScript called" message:  info delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        //    [alert show];
        //    [alert release];
    }
    
    
    
    
}


-(void) addForm:(UINavigationController*)navigation {

    EditViewController *modelView = [[EditViewController alloc] init:[[Item alloc] init:[self getEntityName] fields:nil] mode:@"add" objectId:nil relationField:nil];
    
    [navigation pushViewController:modelView animated:YES];
    [modelView release];

}

- (NSString *) getEntityName{
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
    
    //retrieve all fields
    //    NSMutableArray* rows = [[NSMutableArray alloc] initWithArray:[EntityManager list:startEntity criterias:[[NSDictionary alloc] init]]];
    //    NSObject <EntityInfo> * entityInfo = [InfoFactory getInfo:startEntity];
    //    NSMutableArray *allfields =  [NSMutableArray arrayWithArray:[entityInfo getAllFields]];
    
    NSString *stm = @"Select Id, Name As 'Account Name', BillingCity As 'City', BillingCountry As 'Country', BillingStreet As 'Address' From Account ";
    
    
    self.columnNames = [NSMutableArray arrayWithObjects:@"Account Name",@"City",@"Country",@"Address",@"Id", nil];
    
    self.apiColumnNames = [NSMutableArray arrayWithObjects:@"Name",@"BillingCity",@"BillingCountry",@"BillingStreet",@"Id", nil];
    
    self.rows = [EntityManager listBySQL:[self getEntityName] statement:stm criterias:[[NSDictionary alloc] init] fields:self.columnNames];
    
    rowDataMassAdd = [[NSMutableDictionary alloc] init];
}

- (NSString *) getIdColumn{
    return @"Id";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL) isEditable:(int)columnIndex{
    return NO;
}

- (void) setValueAt:(int)rowIndex columnIndex:(int)columnIndex oldValue:(NSString*)oldValue newValue:(NSString*)newValue{
    
    
    [[[self.rows objectAtIndex:rowIndex] fields] setValue:newValue forKey:[self getColumnName:columnIndex]];
    
}

-(NSMutableDictionary*) getValueBy:(NSString*)fieldName recordId:(NSString*)recordId {
    return nil;
}


-(void) textFieldChange :(id)sender{
        
}

-(NSArray*) getListReferenceBy:(NSString*)entity {
    return nil;
}

-(NSArray*) getPickListBy:(NSString*)fieldName recordTypeId:(NSString*)recordTypeId {
    return nil;
}

-(void) save {
    
}


-(void)dealloc{		
    [fieldInfos release];
	[rows release];
    [columnNames release];
	[apiColumnNames release];
    [super dealloc];
}


@end
