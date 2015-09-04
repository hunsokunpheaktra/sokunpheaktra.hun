//
//  DBTools.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityManager.h"
#import "PicklistManager.h"
#import "CascadingPicklistManager.h"
#import "LogManager.h"
#import "TabManager.h"
#import "FieldsManager.h"
#import "SalesStageManager.h"
#import "SalesProcessManager.h"
#import "CustomRecordTypeManager.h"
#import "LayoutPageManager.h"
#import "LayoutSectionManager.h"
#import "LayoutFieldManager.h"
#import "CurrencyManager.h"
#import "CurrentUserManager.h"
#import "SublistManager.h"
#import "LastSyncManager.h"
#import "FieldMgmtManager.h"
#import "AssessmentManager.h"
#import "QuestionManager.h"
#import "AnswerManager.h"

@interface DBTools : NSObject {
    
}

+ (void)initManagers;

@end
