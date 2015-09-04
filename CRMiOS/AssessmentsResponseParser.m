//
//  AssessmentsResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/21/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "AssessmentsResponseParser.h"
#import "AssessmentManager.h"
#import "QuestionManager.h"
#import "AnswerManager.h"

@implementation AssessmentsResponseParser
@synthesize assessment,quest,answer;
-(id)init{
    self = [super init];
    assessment = [[NSMutableDictionary alloc]initWithCapacity:1];
    quest = [[NSMutableDictionary alloc]initWithCapacity:1];
    answer = [[NSMutableDictionary alloc]initWithCapacity:1];
    return self;
}

-(void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level{
    if (level == 6) {
        if ([tag isEqualToString:@"Name"] || [tag isEqualToString:@"Description"]) {
            [assessment setObject:value forKey:tag];
            if ([tag isEqualToString:@"Description"]) {
                [AssessmentManager insert:assessment];
            }
        }
    }
    
    if (level == 8) {
        if ([tag isEqualToString:@"Question"] || [tag isEqualToString:@"Order"] || [tag isEqualToString:@"Weight"]) {
            if ([tag isEqualToString:@"Question"]) {
                [quest setObject:[assessment objectForKey:@"Name"] forKey:@"AssessmentName"];
            }
            if ([tag isEqualToString:@"Order"]) tag = [tag stringByAppendingString:@"1"];
            [quest setObject:value forKey:tag];
            if ([tag isEqualToString:@"Weight"]) {
                [QuestionManager insert:quest];
            }
        }
    }
    
    if (level == 10) {
        if ([tag isEqualToString:@"Answer"] || [tag isEqualToString:@"Score"] || [tag isEqualToString:@"Order"]) {
            if ([tag isEqualToString:@"Order"]) {
                [answer setObject:[assessment objectForKey:@"Name"] forKey:@"AssessmentName"];
                [answer setObject:[quest objectForKey:@"Order1"] forKey:@"QuestionOrder"];
                tag = [tag stringByAppendingString:@"1"];
            }
            
            [answer setObject:value forKey:tag];
            if ( [tag isEqualToString:@"Score"]) {
                [AnswerManager insert:answer];
            }
        }
    }
}

-(void)dealloc{
    [super dealloc];
    [assessment release];
    [quest release];
    [answer release];
}
@end
