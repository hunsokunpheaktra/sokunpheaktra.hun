//
//  EntityInfo.h
//  kba
//
//  Created by Sy Pauv on 9/30/11.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@protocol EntityInfo <NSObject>

- (NSString *)getName;
- (NSString *)getLabel;
- (NSString *)getPluralName;
- (NSArray *)getAllFields;
- (NSArray *)getExtraFields;
- (Item *) getFieldInfoByName:(NSString*)fieldname;
- (NSString *) getFieldTypeByName:(NSString*)fieldname;


 
@end
