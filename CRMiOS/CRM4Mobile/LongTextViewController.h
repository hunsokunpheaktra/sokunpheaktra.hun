//
//  LongTextViewController.h
//  CRMiOS
//
//  Created by Arnaud on 04/03/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LongTextViewController : UIViewController {
    NSString *text;
}

@property (nonatomic, retain) NSString *text;

- (id)initWithText:(NSString *)newText title:(NSString *)newTitle;

@end
