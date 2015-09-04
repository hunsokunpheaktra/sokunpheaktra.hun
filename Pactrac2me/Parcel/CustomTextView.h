//
//  CustomTextView.h
//  SMBClient4Mobile
//
//  Created by Sy Pauv Phou on 8/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomTextView : UITextView{
    NSString *placeholder;
    UIColor *placeholderColor;

    @private
    UILabel *placeHolderLabel;
}

@property (nonatomic, retain) UILabel *placeHolderLabel;
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;


@end
