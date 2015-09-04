//
//  DBTools.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "DBTools.h"
#import "ParcelEntityManager.h"
#import "SettingManager.h"
#import "UserManager.h"
#import "LogManager.h"
#import "SearchFields.h"
#import "AttachmentEntitymanager.h"
#import "PropertyManager.h"

@implementation DBTools

+ (void)initManagers {
    
    [[DatabaseManager getInstance] initDatabase];
    [ParcelEntityManager initTable];
    [AttachmentEntitymanager initTable];
    [UserManager initTable];
    [SettingManager initTable];
    [SearchFields initTable];
    [SearchFields initDatas];
    [LogManager initTable];
    [PropertyManager initTable];
    [PropertyManager initDatas];

}

@end
