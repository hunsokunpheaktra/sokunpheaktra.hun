//
//  ValidationController.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/1/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Configuration.h"
#import "CRMField.h"
#import "FieldsManager.h"
#import "LayoutFieldManager.h"
#import "FormulaParser.h"
#import "RelationManager.h"

@interface ValidationTools : NSObject {
    
}

+ (BOOL)check:(Item *)item;
+ (BOOL)dateTimeCheck:(NSString *)startTime end:(NSString *)endTime;
+ (void)showAlert:(NSString *)errorMessage;
+ (void)setCalculated:(Item *)item;
+ (BOOL)checkCredentials;
+ (BOOL)validateSubItem:(SublistItem *)item parent:(Item *)parentItem;

@end
