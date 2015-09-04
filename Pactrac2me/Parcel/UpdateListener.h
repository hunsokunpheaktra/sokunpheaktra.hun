//
//  UpdateListener.h
//  Parcel
//
//  Created by Davin Pen on 10/3/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@protocol UpdateListener <NSObject>
-(void)didUpdate:(NSString*)fName value:(NSString*)value;
-(void)mustUpdate:(Item*)item;
@end
