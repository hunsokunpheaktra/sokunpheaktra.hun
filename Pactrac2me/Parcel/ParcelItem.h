//
//  ParcelItem.h
//  Parcel
//
//  Created by Davin Pen on 10/2/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParcelItem : NSObject{
    NSMutableDictionary *data;
}

-(id)initWithData:(NSMutableDictionary*)d;

@property(nonatomic, retain)NSMutableDictionary *data;

+(NSArray*)allSections;
+(NSArray*)allFieldNames;
+(NSArray*)allDataInfo;
+(NSMutableDictionary*)newItem;

@end
