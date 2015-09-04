//
//  Fish.h
//  Nooja
//
//  Created by Arnaud Marguerat on 4/18/12.
//  Copyright (c) 2012 Fellow Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fish : NSObject {
    CGFloat position;
    CGFloat sourceX;
    CGFloat targetX;
    int type;
    int bounce;
}

@property (readwrite) CGFloat position;
@property (readwrite) CGFloat sourceX;
@property (readwrite) CGFloat targetX;
@property (readwrite) int type;
@property (readwrite) int bounce;

- (CGFloat)getX;
- (CGFloat)getY;

@end
