//
//  LanguageTool.h
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 5/10/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LanguageTool : NSObject

+(void)changeLanguage;
+(NSString*)getCurrentLanguage;
+(NSString*)localizedStringForKey:(NSString *)key value:(NSString *)comment;

@end
