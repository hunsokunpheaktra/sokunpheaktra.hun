//
//  DHLRequest.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/14/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "DHLRequest.h"
#import "DHLParser.h"

@implementation DHLRequest

-(NSString*)getMehtod{
    return @"GET";
}
-(NSString*)getBaseURL{
    //http://nolp.dhl.de/nextt-online-public/set_identcodes.do?lang=en&idc=RB180819315CN&rfn=&extendedSearch=true
    //self.trackingNo = @"RB180819315CN";
    return [NSString stringWithFormat:@"http://nolp.dhl.de/nextt-online-public/set_identcodes.do?lang=en&idc=%@&rfn=&extendedSearch=true",self.trackingNo];
}
-(NSString*)getBody{
    return @"";
}
-(NSString *)getProviderName{
    return @"DHL";
}
-(NSString*)getRegularExpression{
    return @"^\\d{12}$|"
            "^\\w{13}$";
}

- (NSDictionary *)htmlParser:(NSString *)htmlText {
        
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlText error:&error];
    HTMLNode *bodyNode = [parser body];
    
    HTMLNode *table = [bodyNode findChildOfClass:@"full eventList"];
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if(table){
        NSArray *trs = [table findChildTags:@"tr"];
        if(trs.count > 0){
            HTMLNode *lastTr = [trs lastObject];
            NSArray *tds = [lastTr findChildTags:@"td"];
            if(tds.count > 0){
                HTMLNode *lastTd = [tds lastObject];
                HTMLNode *divNode = [lastTd findChildTag:@"div"];
                if(divNode){
                    NSString* status = [divNode.contents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [dic setValue:status forKey:@"result"];
                }
            }
        }
    }
    
//    for (HTMLNode *divNode in divNodes) {
//        if ([[divNode getAttributeNamed:@"class"] isEqualToString:@"statusZugestellt"]) {
//            NSString* status = [[divNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//            [dic setValue:status forKey:@"result"];
//        }
//    }
    
    [parser release];
    
    return dic;
    
}


-(ResponseParser *)getParser{
    return [[[DHLParser alloc] init] autorelease];
}

@end
