//
//  MailController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "MailControllerDelegate.h"


@implementation MailControllerDelegate

@synthesize item,listener;

- (id)initWithItem:(Item *)newItem update:(NSObject<UpdateListener> *)update {
    self.item = newItem;
    self.listener=update;
    return self;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        
        if ([self.item.entity isEqualToString:@"Contact"]){
            // create task when sending email complete
            NSMutableDictionary *newTask=[[NSMutableDictionary alloc]init];
            NSDateFormatter *dateformat=[[[NSDateFormatter alloc] init] autorelease];
            [dateformat setDateFormat:@"yyyy-MM-dd"];
            NSDateFormatter *timeFormat=[[[NSDateFormatter alloc] init] autorelease];
            [timeFormat setDateFormat:@"HH:mm:ss"];
            NSString *subject=[self findEmailSubject:controller.view depth:0];
            
            [newTask setObject:[dateformat stringFromDate:[NSDate date]] forKey:@"DueDate"];
            [newTask setObject:[self.item.fields objectForKey:@"AccountId"]==nil?@"":[self.item.fields objectForKey:@"AccountId"] forKey:@"AccountId"];
            [newTask setObject:[self.item.fields objectForKey:@"Id"]==nil?@"":[self.item.fields objectForKey:@"Id"] forKey:@"PrimaryContactId"];
            [newTask setObject:subject forKey:@"Subject"];
            [newTask setObject:@"Email" forKey:@"Type"];
            [newTask setObject:[self parseEmailBody:controller.view] forKey:@"Description"];
            [newTask setObject:@"Task" forKey:@"Activity"];
            [newTask setObject:@"false" forKey:@"Private"];
            [newTask setObject:@"Completed" forKey:@"Status"];
            [newTask setObject:@"3-Low" forKey:@"Priority"];
            
            // get current date
            NSDate *myDate = [NSDate date];
            NSDateFormatter *formater = [[[NSDateFormatter alloc] init] autorelease];
            [formater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            NSString *date = [formater stringFromDate:myDate];
            [newTask setObject:date forKey:@"StartTime"];
            [newTask setObject:date forKey:@"EndTime"];
            
            Item *tmpItem = [[Item alloc] init:@"Activity" fields:newTask];
            [EntityManager insert:tmpItem modifiedLocally:YES];
            [tmpItem release];
            [newTask release];
        }
        
        NSLog(@"It's away!");
    }
    if (listener!=nil) [listener mustUpdate];
    [controller dismissModalViewControllerAnimated:YES];
}

//find email subject from mail Compose View
- (NSString *)findEmailSubject:(UIView *)view depth:(NSInteger)count
{
    NSString *subject = nil;
    if (!view)
        return subject;
    
    for (int i = 0; i < count; i++)
        if ([view isKindOfClass:[UITextField class]])
        {
            if (((UITextField *)view).text)
            {
                subject = [NSString stringWithString:((UITextField *)view).text];
            }
        }
    
    NSArray *subviews = [view subviews];
    if (subviews) {
        for (UIView *view in subviews)
        {
            NSString *s = [self findEmailSubject:view depth:count+1];
            if (s) subject = s;
        }
    }
    return subject;
}

- (NSString *)findEmailBody:(UIView *)view depth:(NSInteger)count{
    
    NSString *subject = nil;
    if (!view)
        return subject;
    
    for (int i = 0; i < count; i++)
        if ([[NSString stringWithFormat:@"%@",view] rangeOfString:@"MFComposeBodyField"].length > 0)
        {
            subject = [NSString stringWithFormat:@"%@",view];
        }
    NSArray *subviews = [view subviews];
    if (subviews) {
        for (UIView *view in subviews)
        {
            NSString *s = [self findEmailBody:view depth:count+1];
            if (s) subject = s;
        }
    }
    return subject;
}

//parse body
- (NSString *)parseEmailBody:(UIView *)view{
    
    NSString *bodytag=[self findEmailBody:view depth:0];
    if (bodytag!=nil) {
        if ([bodytag rangeOfString:@"text ="].length>0) {
            return [bodytag substringWithRange:NSMakeRange([bodytag rangeOfString:@"text ="].location+8,([bodytag rangeOfString:@"';"].location)-([bodytag rangeOfString:@"text ="].location+8))];    
        }
    }
    return bodytag==nil?@"":bodytag;
}

@end
