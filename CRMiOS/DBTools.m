//
//  DBTools.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "DBTools.h"


@implementation DBTools

+ (void)initManagers {
    [CustomRecordTypeManager initTable];
    [CustomRecordTypeManager initData];
    [EntityManager initTables];
    [EntityManager initData];
    [SublistManager initTables];
    [SublistManager initData];
    [PropertyManager initTable];
    [PropertyManager initData];
    [LastSyncManager initTable];
    [LastSyncManager initData];
    [LogManager initTable];
    [LogManager initData];
    [TabManager initTable];
    [TabManager initData];
    [PicklistManager initTable];
    [PicklistManager initData];
    [CascadingPicklistManager initTable];
    [CascadingPicklistManager initData];
    [FieldsManager initTable];
    [FieldsManager initData];
    [FieldMgmtManager initTable];
    [FieldMgmtManager initData];
    [SalesProcessManager initTable];
    [SalesProcessManager initData];
    [SalesStageManager initTable];
    [SalesStageManager initData];
    [LayoutPageManager initTable];
    [LayoutPageManager initData];
    [LayoutSectionManager initTable];
    [LayoutSectionManager initData];
    [LayoutFieldManager initTable];
    [LayoutFieldManager initData];
    [CurrencyManager initTable];
    [CurrencyManager initData];
    [CurrentUserManager initData];
    [CurrentUserManager initTable];
    [IndustryManager initTable];
    [IndustryManager initData];
    [AssessmentManager initTables];
    [QuestionManager initTables];
    [AnswerManager initTables];
}

@end
