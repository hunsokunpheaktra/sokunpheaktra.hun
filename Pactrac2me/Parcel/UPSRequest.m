//
//  UPSRequest.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/14/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "UPSRequest.h"
#import "UPSParser.h"

@implementation UPSRequest

-(NSString*)getBaseURL{
    //self.trackingNo = @"1Z70480Y6893683198";
    return [NSString stringWithFormat:@"http://wwwapps.ups.com/etracking/tracking.cgi?InquiryNumber1=%@&loc=en_EN&TypeOfInquiryNumber=T",self.trackingNo];
}
-(NSString*)getMehtod{
    return @"GET";
}

-(NSString*)getBody{
    return @"";
}
-(NSString *)getProviderName{
    return @"UPS";
}

-(NSString*)getRegularExpression{
    return @"\\b1Z ?[\\d\\D]{3} ?[\\d\\D]{3} ?[\\d\\D]{2} ?[\\d\\D]{4} ?[\\d\\D]{4}\\b|"
    "\\b[\\dT]\\d{3} ?\\d{4} ?\\d{3}\\b";
}

- (NSDictionary *)htmlParser:(NSString *)htmlText {
    

    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlText error:&error];
    HTMLNode *bodyNode = [parser body];
    
    NSArray *trNodes = [bodyNode findChildTags:@"tr"];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableArray* arrTr = [NSMutableArray arrayWithCapacity:1];
    for (HTMLNode *trNode in trNodes) {
        if ([[trNode getAttributeNamed:@"class"] isEqualToString:@"odd"]) {
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
    
    if ([arrTr count] > 0) [dic setValue:arrTr forKey:@"result"];
    [parser release];
    return dic;
    
}



-(ResponseParser *)getParser{
    return [[[UPSParser alloc] init] autorelease];
}

@end

