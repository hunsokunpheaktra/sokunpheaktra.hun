//
//  NumberHelper.m
//  Datagrid
//
//  Created by Gaeasys Admin on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NumberHelper.h"


@implementation NumberHelper

+(NSString*) formatNumberDisplay:(double)value
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *c = [NSNumber numberWithFloat:value];
    return [numberFormatter stringFromNumber:c];
}

+(NSString*) formatCurrencyValue:(double)value
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber *c = [NSNumber numberWithFloat:value];
    return [numberFormatter stringFromNumber:c];
}

+(NSString*) formatPercentValue:(double)value
{
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setPercentSymbol:@"%"];
    [numberFormatter setNumberStyle: NSNumberFormatterPercentStyle];
    [numberFormatter setDecimalSeparator:@"."];
    [numberFormatter setGeneratesDecimalNumbers:FALSE];
    //[numberFormatter setMinimumFractionDigits:2];
    [numberFormatter setRoundingMode: NSNumberFormatterRoundUp];
    [numberFormatter setRoundingIncrement:[[NSNumber alloc]initWithDouble:0.05]];
   
    NSNumber *c = [NSNumber numberWithInt:value];
    NSNumber *d = [NSNumber numberWithFloat:[c intValue]/100.0];
    
    return [numberFormatter stringFromNumber:d];
}

+(double) formatDoubleFromCurrency:(NSString*)value
{
    double ret ;
    if(value)
    {
        ret = [value doubleValue];
        if (ret == 0)
        {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setCurrencySymbol:@"$"];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            NSNumber *c = [numberFormatter numberFromString:value];
            ret = [c doubleValue];
        }
        return ret;
    }
    else
        return 0.0;
}
@end
