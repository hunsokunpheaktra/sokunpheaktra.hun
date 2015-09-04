//
//  ConfigSubtype.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 8/2/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailLayout.h"
#import "EvaluateTools.h"
#import "Subtype.h"
#import "FormulaParser.h"


@interface ConfigSubtype : NSObject<Subtype> {
    NSString *name;
    NSString *entity;
    NSString *iconName;
    NSString *orderField;
    BOOL _orderAscending;

    NSString *displayText, *secondaryText;
    NSString *groupBy;
    NSMutableArray *mandatoryFields;
    NSString *iconField;
    NSMutableDictionary *listIcons;
    NSMutableArray *actions;
    NSMutableArray *sublists;

    DetailLayout *detailLayout;
    NSString *filterField;
    NSMutableArray *filters;
    NSMutableArray *criterias;
    NSMutableArray *disabledRelations;
    
    NSMutableDictionary *customNames;
    NSMutableArray *readonly;
    Page *pdfLayout;
    
    BOOL _canCreate;
    
}

@property (nonatomic, retain) NSMutableArray *disabledRelations;
@property (nonatomic, retain) Page *pdfLayout;
@property (nonatomic, retain) NSMutableDictionary *customNames;
@property (nonatomic, retain) NSMutableArray *readonly;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSString *iconName;
@property (nonatomic, retain) DetailLayout *detailLayout;
@property (nonatomic, retain) NSString *orderField;
@property (assign) BOOL orderAscending;
@property (nonatomic, retain) NSString *displayText, *secondaryText;
@property (nonatomic, retain) NSString *groupBy;
@property (nonatomic, retain) NSMutableArray *mandatoryFields;
@property (nonatomic, retain) NSString *iconField;
@property (nonatomic, retain) NSMutableDictionary *listIcons;
@property (nonatomic, retain) NSMutableArray *actions;
@property (nonatomic, retain) NSString *filterField;
@property (nonatomic, retain) NSMutableArray *filters;
@property (nonatomic, retain) NSMutableArray *criterias;
@property (nonatomic, retain) NSMutableArray *sublists;
@property (assign) BOOL canCreate;

- (id)initWithEntity:(NSString *)newEntity;
- (NSString *)getOrderField;


@end
