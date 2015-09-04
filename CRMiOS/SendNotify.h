//
//  SendNotify.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 2/1/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseRequest.h"

@interface SendNotify :BaseRequest
{
    NSString *parentId;
    NSString *comment;
}

@property (nonatomic, retain) NSString *parentId;
@property (nonatomic, retain) NSString *comment;

- (id)init:(NSString *)newParentId comment:(NSString *)newComment;
@end
