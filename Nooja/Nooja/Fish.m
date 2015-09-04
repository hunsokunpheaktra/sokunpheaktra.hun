//
//  Fish.m
//  Nooja
//
//  Created by Arnaud Marguerat on 4/18/12.
//  Copyright (c) 2012 Fellow Consulting. All rights reserved.
//

#import "Fish.h"

@implementation Fish

@synthesize sourceX, targetX, position, type, bounce;

- (CGFloat)getX {
    CGFloat tmp = self.position;
    if (tmp > 1) tmp = 1;
    return self.sourceX + (self.targetX - self.sourceX) * tmp;
}

- (CGFloat)getY {
    CGFloat tmp = self.position;
    if (tmp > 1) tmp = 1;
    CGFloat y = (0.8 - (tmp - 0.5)*(tmp - 0.5)*3);
    if (self.position > 1) {
        y += sinf((self.position - 1) * 2 * M_PI) * .1;
    }
    return y;
}

@end
