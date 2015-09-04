//
//  FacebookLinkedInTools.h
//  CRMiOS
//
//  Created by Sy Pauv on 8/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FacebookLinkedInTools : NSObject {
    
}
+ (NSMutableString *)faceBookGetNameScript:(int)i;
+ (NSMutableString *)faceBookGetLinkScript:(int)i;
+ (NSMutableString *)faceBookGetImageScript:(int)i;
+ (NSMutableString *)linkedInGetNameScript:(int)i;
+ (NSMutableString *)linkedInGetLinkScript:(int)i;
+ (NSMutableString *)linkedInGetImageScript:(int)i;
+ (NSMutableString *)linkedInGetTitleScript:(int)i;

+ (NSString *)getSearchURL:(NSString *)keyword type:(NSString *)type;
+ (NSArray *)generateFacebookResult:(UIWebView *)webView;
+ (NSArray *)generateLinkedInResult:(UIWebView *)webView;

@end
