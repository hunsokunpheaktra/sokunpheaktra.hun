//
//  ScreenRelatedList.m
//  SyncForce
//
//  Created by Gaeasys on 11/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScreenRelatedList.h"
#import "Criteria.h"
#import "LikeCriteria.h"
#import "Item.h"
#import "DatabaseManager.h"
#import "RelatedListsInfoManager.h"
#import "RelatedListGrid.h"
#import "TestRelatedList.h"
#import "EntityManager.h"
#import "RelatedListColumnInfoManager.h"
#import "FilterFieldManager.h"

@implementation ScreenRelatedList

@synthesize pType,pId,relatedList,cType,parent,dataGrid;

-(id)initWithData:(NSString*) parentType childType:(NSString *)chType parentId:(NSString*)parentId parentController:(ObjectDetailViewController *)newParent {
    
    self = [super init];
    pType = parentType;
    pId   = parentId;
    cType = chType;
    parent = newParent;
    
    NSMutableDictionary *newCriterias = [[[NSMutableDictionary alloc] init] autorelease];
    [newCriterias setValue:[[[ValuesCriteria alloc] initWithString:pType] autorelease] forKey:@"entity"];
    [newCriterias setValue:[[[ValuesCriteria alloc] initWithString:cType] autorelease] forKey:@"sobject"];
    
    relatedList = [RelatedListsInfoManager list:newCriterias];
    [self initView];
    
    return self;
}



- (void)dealloc
{
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)initView{

    NSMutableArray* columnNames = [[NSMutableArray alloc] init];
    NSMutableArray* apiColumnNames = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *dicCriteria = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
        [dicCriteria setValue:[[[ValuesCriteria alloc] initWithString:pType] autorelease] forKey:@"entity"];
        [dicCriteria setValue:[[[ValuesCriteria alloc] initWithString:cType] autorelease] forKey:@"sobject"];

        for(Item *item in [RelatedListColumnInfoManager list:dicCriteria]){
            [columnNames addObject:[item.fields valueForKey:@"label"]];
            NSString *name = [item.fields valueForKey:@"name"];
            if([name rangeOfString:@"toLabel"].length > 0){
                name = [name stringByReplacingOccurrencesOfString:@"toLabel" withString:@""];
                name = [name stringByReplacingOccurrencesOfString:@"(" withString:@""];
                name = [name stringByReplacingOccurrencesOfString:@")" withString:@""];
            }
            [apiColumnNames addObject:name];
            if([columnNames count] == 5) break;
        }
    
    
   [columnNames addObject:@"Id"];
   [apiColumnNames addObject:@"Id"];
    
    NSMutableDictionary *criterias = [[[NSMutableDictionary alloc] init] autorelease];
    if([relatedList count] > 0){
        Item *item = [relatedList objectAtIndex:0];
        [criterias removeAllObjects]; 
        [criterias setValue:[[[ValuesCriteria alloc] initWithString:pId] autorelease] forKey:[item.fields objectForKey:@"field"]];

        NSArray* rows = [EntityManager list:cType criterias:criterias];
        NSObject <DatagridListener,DataModel> *listenerWithModel = [[TestRelatedList alloc] initWithDatas:[item.fields objectForKey:@"sobject"] colNames:columnNames apiColName:apiColumnNames rows:rows parentId:pId parentField:[item.fields objectForKey:@"field"] cType:cType];
        
        dataGrid = [[CustomDataGrid alloc] initWithPopulate:listenerWithModel listener:listenerWithModel rowNumber:10];
        
        
        dataGrid.parentType = pType;
        dataGrid.parentId   = pId;
        dataGrid.childType  = cType;
        
        NSMutableArray*tmp = [[NSMutableArray alloc] initWithArray:dataGrid.toolbarAddEdit.items];
        [tmp removeObjectAtIndex:2];
        [dataGrid.toolbarAddEdit setItems:tmp animated:NO];
        [dataGrid chooseView];
        dataGrid.parentController = parent;
        dataGrid.title = NSLocalizedString([item.fields objectForKey:@"label"], Nil);
        [self.navigationController pushViewController:dataGrid animated:YES];
        
        CGRect rect = dataGrid.view.frame;
        rect.size.height = rect.size.height - 50;
        dataGrid.view.frame = rect;
        
        rect = dataGrid.toolbarPaging.frame;
        rect.origin.y = rect.origin.y - 50;
        dataGrid.toolbarPaging.frame = rect; 
        
        self.view = dataGrid.view;
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


@end
