//
//  CurrencyCodeParser.h
//  CRMiOS
//
//  Created by Sy Pauv on 7/1/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "CurrencyManager.h"

@interface CurrencyCodeParser : ResponseParser {
     NSMutableDictionary *currency;
}

@property (nonatomic,retain) NSMutableDictionary *currency;

- (id)init;

@end
