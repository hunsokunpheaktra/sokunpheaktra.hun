//
//  CRMField.h
//
//  Created by Sy Pauv Phou on 3/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CRMField : NSObject {
    NSString *code;
    NSString *displayName;
    NSString *type;
}

@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *type;

- initWithCode:(NSString *)newCode displayName:(NSString *)newDisplayName type:(NSString *)newType entity:(NSString *)entity;

@end
