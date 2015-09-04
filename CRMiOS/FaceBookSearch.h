//
//  FaceBookSearch
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FacebookListener.h"

@interface FaceBookSearch : NSObject {
    NSMutableData *webData;  
    NSNumber *status;
    NSObject <FacebookListener> *listener;
}

@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) NSObject <FacebookListener> *listener;
@property (nonatomic, retain) NSNumber *status;

- (void)doRequest:(NSObject <FacebookListener> *)listener :(NSString *)url;
- (NSString *)generateMessage;
- (NSString *)getSuffix;


@end
