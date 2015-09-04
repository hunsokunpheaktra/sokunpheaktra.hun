//
//  DatagridListener.h
//  Reader
//
//  Created by Sy Pauv on 9/29/11.
//
//  This interface is called by the Datagrid component when user click on a given cell
//
//

#import <Foundation/Foundation.h>
#import "GridItem.h"
#import "Item.h"


@protocol DatagridListener <NSObject>

-(void) callback:(GridItem *)item;
-(void) addForm:(UINavigationController*)navigation;
-(void) save;
-(void) clearListEdit;
-(void) deleteRecordById:(NSString*)recordId;

-(NSMutableDictionary*) getValueBy:(NSString*)fieldName recordId:(NSString*)recordId;
-(NSArray*) getPickListBy:(NSString*)fieldName recordTypeId:(NSString*)recordTypeId;
-(NSArray*) getListReferenceBy:(NSString*)entity;


@end
