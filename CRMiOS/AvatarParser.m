//
//  AvataParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "AvatarParser.h"


@implementation AvatarParser

@synthesize userId;

- (id)initWithId:(NSString *)newUserId{
    self.userId = newUserId;
    return  [super init];
}

- (void)endTag:(NSString *)tag {

    //save returned Avatar result into static dictionary
    if ([tag isEqualToString:@"avatar"] && ![currentText isEqualToString:@"null"]) {
        [FeedManager writeAvatar:currentText forUser:self.userId];
    }

}
@end
