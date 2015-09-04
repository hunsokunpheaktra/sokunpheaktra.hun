//
//  EditView.h
//  SyncForce
//
//  Created by Gaeasys Admin on 10/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface EditView : UIViewController <UIPopoverControllerDelegate, UITextFieldDelegate>{
    NSArray *fieldinfos;
    NSString *mode;
    NSString *entity;
    NSString *objectId;
    Item *currentItem;
    NSMutableDictionary *tagMapper;
    UIScrollView *scroll;
    NSString *titletext;
}
@property (nonatomic, retain) UIScrollView *scroll;
@property (nonatomic, retain) NSArray *fieldinfos;
@property (nonatomic, retain) NSString *mode;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) Item *currentItem;
@property (nonatomic, retain) NSMutableDictionary *tagMapper;
@property (nonatomic, retain) NSString *titletext;


- (id)initWithMode:(NSString *)pmode entity:(NSString *)pentity;
- (void)saveClick:(id)sender;
- (void)cancelClick:(id)sender;


@end
