//
//  LanguageTool.m
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 5/10/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "LanguageTool.h"

@implementation LanguageTool

static NSBundle *bundle;

+(void)changeLanguage{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:[self getCurrentLanguage] ofType:@"lproj"];
    if(path == nil) path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
    
    bundle = [[NSBundle bundleWithPath:path] retain];
}
+(NSString*)getCurrentLanguage{
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return language;
}

+(NSString*)localizedStringForKey:(NSString *)key value:(NSString *)comment{
    if(bundle == nil){
        NSString *path = [[NSBundle mainBundle] pathForResource:[self getCurrentLanguage] ofType:@"lproj"];
        bundle = [[NSBundle bundleWithPath:path] retain];
    }
    NSString *str = [bundle localizedStringForKey:key value:comment table:nil];
    return str;
}

@end
