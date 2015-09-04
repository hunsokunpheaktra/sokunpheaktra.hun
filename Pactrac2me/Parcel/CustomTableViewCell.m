//
//  CustomTableViewCell.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 10/25/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.backgroundView.frame;
    frame.origin.x += 140;
    frame.size.width -= 140;
    self.backgroundView.frame = frame;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
