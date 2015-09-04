//
//  CustomUITextField.h
//  SyncForce
//
//  Created by Gaeasys on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUITextField : UITextField{
    NSInteger section;
}

@property (nonatomic,readwrite) NSInteger section;
@end
