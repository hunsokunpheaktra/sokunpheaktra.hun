//
//  TNTRequest.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/14/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "TNTRequest.h"
#import "TNTParser.h"
#import "NSObject+SBJson.h"

@implementation TNTRequest

-(NSString*)getMehtod{
    return @"POST";
}
-(NSString*)getBaseURL{
    
    //self.trackingNo = @"123456785"; //@"23456785";
    return [NSString stringWithFormat:@"http://www.tnt.com/webtracker/tracking.do?cons=%@&trackType=CON&genericSiteIdent=&page=1&respLang=en&respCountry=GB&sourceID=1&sourceCountry=ww&plazakey=&refs=&requestType=GEN&searchType=CON&navigation=0",self.trackingNo];

    //return @"http://www.tnt.com/webtracker/tracking.do?cons=123456785&trackType=CON&genericSiteIdent=&page=1&respLang=en&respCountry=GB&sourceID=1&sourceCountry=ww&plazakey=&refs=123456785&requestType=GEN&searchType=CON&navigation=0";
}

-(NSString*)getBody{
    return nil;
}

-(NSString *)getProviderName{
    return @"TNT";
}

-(NSString*)getRegularExpression{
    return @"^\\w{9,13}$";
}

- (NSDictionary *)htmlParser:(NSString *)htmlText {
    
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlText error:&error];
    HTMLNode *bodyNode = [parser body];
    
    NSArray *trNodes = [bodyNode findChildTags:@"tr"];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableArray* arrTr = [NSMutableArray arrayWithCapacity:1];
    for (HTMLNode *trNode in trNodes) {
        if ([[trNode getAttributeNamed:@"class"] isEqualToString:@"appTable"]) {
            NSMutableArray*arrTd = [[NSMutableArray alloc] init];
            NSArray *tdNodes = [trNode findChildTags:@"td"];
            for (HTMLNode* tdNode in tdNodes) {
               if ([tdNode contents] == nil)
                 [arrTd addObject:@""];
               else {
                   
                   NSString* st = [[tdNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                   st = [st stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                   st = [st stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                   
                   [arrTd addObject:st];

               }
            }
            
            [arrTr addObject:arrTd];
            [arrTd release];
        }
    }

    if ([arrTr count]>0) [dic setValue:arrTr forKey:@"result"];
    [parser release];
    
    return dic;

}


-(ResponseParser *)getParser{
    return [[[TNTParser alloc] init] autorelease];
}

@end
