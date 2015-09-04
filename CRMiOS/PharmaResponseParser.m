//
//  PharmaResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PharmaResponseParser.h"


@implementation PharmaResponseParser


- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    
    //tag = errorcode value= (SBL-DAT-00553) level=8
    //tag = faultstring value= Method 'Execute' of business component 'Pharma Call Products Detailed' (integration component 'Activity_Pharma Call Products Detailed') returned the following error:
    //"Access denied.(SBL-DAT-00553)"(SBL-EAI-04376) level=4
    
    if(level==4 && [tag isEqualToString:@"faultstring"]){
    
        [PropertyManager save:@"PharmaEnabled" value:@"0"];
        
    }else{
    
        [PropertyManager save:@"PharmaEnabled" value:@"1"];
    
    }
   
}


@end
