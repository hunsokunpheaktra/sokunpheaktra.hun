//
//  NumberHelper.h
//  Datagrid
//
//  Created by Gaeasys Admin on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NumberHelper : NSObject {
    
}
+(NSString*) formatNumberDisplay:(double)value;
+(NSString*) formatCurrencyValue:(double)value;
+(NSString*) formatPercentValue:(double)value;
+(double) formatDoubleFromCurrency:(NSString*)value;
@end
