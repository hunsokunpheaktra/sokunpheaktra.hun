//
//  DPDRequest.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/14/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "DPDRequest.h"
#import "DPDParser.h"

@implementation DPDRequest

-(NSString*)getMehtod{
    return @"GET";
}
-(NSString*)getBaseURL{
    //self.trackingNo = @"01997500942118";
    return [NSString stringWithFormat:@"https://extranet.dpd.de/cgi-bin/delistrack?pknr=%@&typ=1&lang=en",self.trackingNo];
//    return @"https://extranet.dpd.de/cgi-bin/delistrack?pknr=01997500942118&typ=1&lang=en";
}
-(NSString*)getBody{
    return @"";
}
-(NSString *)getProviderName{
    return @"DPD";
}

-(NSString*)getRegularExpression{
    return @"^\\d{14}$";
}

- (NSDictionary *)htmlParser:(NSString *)htmlText {
    
//    NSLog(@" DPD html text : %@", htmlText);
    
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlText error:&error];
    HTMLNode *bodyNode = [parser body];
    
    NSArray *tableNodes = [bodyNode findChildTags:@"table"];
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSMutableArray* arrTr = [NSMutableArray arrayWithCapacity:1];
    
    for (HTMLNode *tableNode in tableNodes) {
        
        if ([[tableNode getAttributeNamed:@"id"] isEqualToString:@"plcTable"]) {
          //  NSLog(@"---- rawContents %@", [tableNode rawContents]);
            
            NSArray *trNodes = [tableNode findChildTags:@"tr"];
            
            for (HTMLNode *trNode in trNodes) {
                if ([[trNode getAttributeNamed:@"class"] rangeOfString:@"table_content_col_grey"].location != NSNotFound) {
                    
                    NSMutableArray*arrTd = [[NSMutableArray alloc] init];
                    NSArray *tdNodes = [trNode findChildTags:@"td"];
                    for (HTMLNode* tdNode in tdNodes) {
                        
                        if ([tdNode allContents] == nil)
                            [arrTd addObject:@""];
                        else {
                            
                            NSString* st = [[tdNode allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            st = [st stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            st = [st stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                            
                            [arrTd addObject:st];
                            [st release];
                            
                        }
                    }
                    
                    [arrTr addObject:arrTd];
                    [arrTd release];
                }
            }

            
        }
    }
    
        
    if([arrTr count]>0) [dic setValue:arrTr forKey:@"result"];
    [parser release];
    
    return dic;
    
}


-(ResponseParser *)getParser{
    return [[[DPDParser alloc] init] autorelease];
}

@end
