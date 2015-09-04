//
//  FilterObjectViewController.h
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateListener.h"

@interface FilterObjectViewController : UITableViewController<UpdateListener,UITextFieldDelegate>{
    
    NSString *entity;
    NSArray *listFields;
    NSMutableArray *operators;
    
    NSMutableDictionary *field;
    NSMutableDictionary *operat;
    NSMutableDictionary *value;
    
    NSArray *listItems;
    NSArray *tmparr;
    NSMutableArray *allTextField;
    NSArray* listDateLiteral;
    NSMutableDictionary* listTypeFields;
    NSMutableArray *listObjects;

    NSMutableArray* listKeyField;
    NSMutableArray* listLabel;
    NSMutableDictionary* arrayNameLabel;
    
    NSString* subOrName;
}


- (id)initWithEntity:(NSString*)newEntity;
- (void)initListItems;
- (void)saveFilter:(id)sender;
- (void)getAllListKeyFields;

@end
