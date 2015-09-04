//
//  AssessmentManager.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/21/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssessmentManager : NSObject
+ (void)initTables;
+ (void)insert:(NSDictionary *)newAssessment;
@end
