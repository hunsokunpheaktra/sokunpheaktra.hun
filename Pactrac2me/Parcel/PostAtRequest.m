//
//  PostAtRequest.m
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 2/27/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "PostAtRequest.h"
#import "PostAtParser.h"

@implementation PostAtRequest

-(NSString*)getMehtod{
    return @"GET";
}
-(NSString*)getBaseURL{
    return [NSString stringWithFormat:@"http://www.post.at/sendungsverfolgung.php?pnum1=%@",self.trackingNo];
}
-(NSString*)getBody{
    return @"";
}

-(NSString *)getProviderName{
    return @"PostAt";
}

-(NSString*)getRegularExpression{
    return @"^\\d{22}$|"
            "^\\w{13}$";
}
- (NSDictionary *)htmlParser:(NSString *)htmlText {
    
    NSError *error;
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:1];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlText error:&error];
    HTMLNode *bodyNode = [parser body];
    
    HTMLNode *tableNode = [bodyNode findChildOfClass:@"contentLayer print sendung"];
    if(tableNode){
    
        NSArray *allTrs = [tableNode findChildTags:@"tr"];
        if(allTrs.count > 0){
            
            HTMLNode *trNode = [allTrs lastObject];
            NSArray *allTds = [trNode findChildTags:@"td"];
            if(allTds.count > 0){
                
                HTMLNode *tdNode = [allTds objectAtIndex:0];
                NSString *status = [tdNode.contents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                status = [status stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                status = [status stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                
                [dic setObject:status forKey:@"result"];
            }
            
        }
        
    }
    [parser release];
    return dic;
    
}

-(ResponseParser *)getParser{
    return [[[PostAtParser alloc] init] autorelease];
}


@end
