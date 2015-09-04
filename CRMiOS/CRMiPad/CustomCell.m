//
//  CustomCell.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/11/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CustomCell.h"


@implementation CustomCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 4, self.textLabel.frame.size.width + 80, self.frame.size.height - 8);
    self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x + 88, 4, self.contentView.frame.size.width - self.detailTextLabel.frame.origin.x - 92, self.frame.size.height - 8);
}



@end
