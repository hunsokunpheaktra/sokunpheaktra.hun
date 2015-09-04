//
//  FacebookLinkedInTools.m
//  CRMiOS
//
//  Created by Sy Pauv on 8/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "FacebookLinkedInTools.h"


@implementation FacebookLinkedInTools

//facebook script
+ (NSMutableString *)faceBookGetNameScript:(int)i{

    NSMutableString *scripteName=[[NSMutableString alloc]initWithCapacity:1];
    [scripteName appendFormat:@"document.getElementsByClassName('objectListItem uiListItem uiListLight uiListVerticalItemBorder')[%i].",i];
    [scripteName appendFormat:@"getElementsByClassName('clearfix uiImageBlock')[0]."];
    [scripteName appendFormat:@"getElementsByClassName('clearfix uiImageBlockContent')[0]."];//uiProfileBlockContent
    [scripteName appendFormat:@"getElementsByClassName('uiProfileBlockContent')[0]."];//uiInlineBlock
    [scripteName appendFormat:@"getElementsByClassName('uiInlineBlock')[0]."];//uiInlineBlock uiInlineBlockMiddle
    [scripteName appendFormat:@"getElementsByClassName('uiInlineBlock uiInlineBlockMiddle')[1]."];//fsl fwb fcb
    [scripteName appendFormat:@"getElementsByClassName('fsl fwb fcb')[0]."];
    [scripteName appendString:@"getElementsByTagName('a')[0].innerHTML"];
    
    return scripteName;
}

+ (NSMutableString *)faceBookGetLinkScript:(int)i{
    NSMutableString *scriptImage=[[NSMutableString alloc]initWithCapacity:1];
    [scriptImage appendFormat:@"document.getElementsByClassName('objectListItem uiListItem uiListLight uiListVerticalItemBorder')[%i].",i];
    //clearfix uiImageBlock
    [scriptImage appendFormat:@"getElementsByClassName('clearfix uiImageBlock')[0]."];
    [scriptImage appendFormat:@"getElementsByClassName('uiImageBlockImage uiImageBlockLargeImage lfloat')[0].href"];
    return scriptImage;
}

+ (NSMutableString *)faceBookGetImageScript:(int)i{    
    NSMutableString *scriptImage=[[NSMutableString alloc]initWithCapacity:1];
    [scriptImage appendFormat:@"document.getElementsByClassName('objectListItem uiListItem uiListLight uiListVerticalItemBorder')[%i].",i];
    [scriptImage appendFormat:@"getElementsByClassName('uiImageBlockImage uiImageBlockLargeImage lfloat')[0]."];
    [scriptImage appendString:@"getElementsByTagName('*')[0].src;"];
    return  scriptImage;
}

//link in script
+ (NSMutableString *)linkedInGetNameScript:(int)i{
    
    NSMutableString *scriptgetName=[[NSMutableString alloc]initWithCapacity:1];
    [scriptgetName appendString:@"document.getElementById(\"result-set\")."];
    [scriptgetName appendFormat:@"getElementsByClassName('vcard')[%i].",i];
    [scriptgetName appendString:@"getElementsByTagName('h2')[0]."];
    [scriptgetName appendString:@"getElementsByTagName('a')[0].title"];
    return scriptgetName;
    
}
+ (NSMutableString *)linkedInGetLinkScript:(int)i{
    
    NSMutableString *scriptgetLink=[[NSMutableString alloc]initWithCapacity:1];
    [scriptgetLink appendString:@"document.getElementById(\"result-set\")."];
    [scriptgetLink appendFormat:@"getElementsByClassName('vcard')[%i].",i];
    [scriptgetLink appendString:@"getElementsByTagName('h2')[0]."];
    [scriptgetLink appendString:@"getElementsByTagName('a')[0].href"];
    return scriptgetLink;
    
}
+ (NSMutableString *)linkedInGetImageScript:(int)i{
    NSMutableString *scriptgetImage=[[NSMutableString alloc]initWithCapacity:1];
    [scriptgetImage appendString:@"document.getElementById(\"result-set\")."];
    [scriptgetImage appendFormat:@"getElementsByClassName('vcard')[%i].",i];
    [scriptgetImage appendString:@"getElementsByClassName('profile-photo')[0]."];
    [scriptgetImage appendString:@"getElementsByTagName('img')[0].src"];
    return scriptgetImage;
}

+ (NSMutableString *)linkedInGetTitleScript:(int)i{
    
    NSMutableString *scriptgetTitle=[[NSMutableString alloc]initWithCapacity:1];
    [scriptgetTitle appendString:@"document.getElementById(\"result-set\")."];
    [scriptgetTitle appendFormat:@"getElementsByClassName('vcard')[%i].",i];
    [scriptgetTitle appendString:@"getElementsByClassName('vcard-basic')[0]."];
    [scriptgetTitle appendString:@"getElementsByClassName('title')[0].innerHTML"];
    return scriptgetTitle;
    
}
+ (NSString *)getSearchURL:(NSString *)keyword type:(NSString *)type{
    
    if ([type isEqualToString:@"Facebook"]) {
        return [NSString stringWithFormat:@"http://www.facebook.com/search.php?q=%@",keyword]; 
    }else{
        NSArray *chunk=[keyword componentsSeparatedByString:@"%20"];
        NSString *linkedInURl=[NSString stringWithFormat:@"http://www.linkedin.com/pub/dir/?first=%@&last=%@&search=Go",[chunk objectAtIndex:0],[chunk objectAtIndex:1]];
        return linkedInURl;
    }
}

+ (NSArray *)generateFacebookResult:(UIWebView *)webView{
    
    NSMutableArray *tmpResult=[[[NSMutableArray alloc]initWithCapacity:1]autorelease];
    
    BOOL more=true;
    int i=0;
    
    //access page by execute javascript to get result    
    while (more) {
        
        NSString *Image=[webView stringByEvaluatingJavaScriptFromString:[FacebookLinkedInTools faceBookGetImageScript:i]];
        NSString *link=[webView stringByEvaluatingJavaScriptFromString:[FacebookLinkedInTools faceBookGetLinkScript:i]];
        NSLog(@"faceBookLink =%@",link);
        NSString *name=[webView stringByEvaluatingJavaScriptFromString:[FacebookLinkedInTools faceBookGetNameScript:i]];
        NSLog(@"faceBookName =%@",name);
        
        if ([Image isEqualToString:@""]&&[link isEqualToString:@""]&&[name isEqualToString:@""]) {
            more=false;
        }else{
            if (![link isEqualToString:@"http://www.facebook.com/"]) {
                [tmpResult addObject:[[NSDictionary alloc]initWithObjectsAndKeys:Image,@"image",link,@"link",name,@"name" ,nil]];
            }
        }
        i++;
    }
    
    return  tmpResult;
}
+ (NSArray *)generateLinkedInResult:(UIWebView *)webView{
    
    NSMutableArray *tmpResult=[[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    BOOL more=true;
    int i=0;

    //access page by execute javascript to get result    
  while (more) {
        
        NSString *Image=[webView stringByEvaluatingJavaScriptFromString:[FacebookLinkedInTools linkedInGetImageScript:i]];
        NSString *link=[webView stringByEvaluatingJavaScriptFromString:[FacebookLinkedInTools linkedInGetLinkScript:i]];
        NSString *name=[webView stringByEvaluatingJavaScriptFromString:[FacebookLinkedInTools linkedInGetNameScript:i]];
        NSString *title=[webView stringByEvaluatingJavaScriptFromString:[FacebookLinkedInTools linkedInGetTitleScript:i]];
        
        if (([Image isEqualToString:@""] && [link isEqualToString:@""] && [name isEqualToString:@""]) || i==20) {
            more=false;
        }else{        
            [tmpResult addObject:[[NSDictionary alloc]initWithObjectsAndKeys:Image,@"image",link,@"link",name,@"name",title,@"title" ,nil]];
        }
        i++;
    }
    if ([tmpResult count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"LinkedIn Search"
                              message:@"Person not found !" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil];
        [alert show];
        [alert release];
        
    }

    return  tmpResult;
    
}


@end
