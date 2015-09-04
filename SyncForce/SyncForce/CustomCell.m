//
//  CustomCell.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomCell.h"


@implementation CustomCell

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, self.textLabel.frame.size.width + 200, self.textLabel.frame.size.height);
    self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x + 220, self.detailTextLabel.frame.origin.y, self.frame.size.width - (self.detailTextLabel.frame.origin.x + 340), self.detailTextLabel.frame.size.height);

}

@end
