
#import <Foundation/Foundation.h>
#import "Criteria.h"

@interface GreaterThanCriteria : NSObject<Criteria> {
    NSString *value;
}

@property (nonatomic, retain) NSString *value;

- (id)initWithValue:(NSString *)newValue;

@end
