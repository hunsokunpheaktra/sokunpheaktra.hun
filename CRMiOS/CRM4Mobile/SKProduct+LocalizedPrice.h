//
//  SKProduct+LocalizedPrice.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 1/20/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end
