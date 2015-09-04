//
//  FacebookListener.h
//  SessionLoginSample
//
//  Created by Sy Pauv on 2/4/13.
//
//

#import <Foundation/Foundation.h>

@protocol FacebookListener <NSObject>
-(void)field:(NSString *)error;
-(void)complete:(NSArray *)list;
@end
