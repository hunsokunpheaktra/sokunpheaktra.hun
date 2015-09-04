//
//  EditCell.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/11/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "EditCell.h"


@implementation EditCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [[self subviews] lastObject];
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, self.textLabel.frame.size.width + 80, self.textLabel.frame.size.height);
}


@end
