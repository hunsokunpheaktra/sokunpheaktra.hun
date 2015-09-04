
#import "GreaterThanCriteria.h"


@implementation GreaterThanCriteria

@synthesize value;

- (id)initWithValue:(NSString *)newValue {
    self = [super init];
    self.value = newValue;
    return self;
}

- (NSString *)getCriteria {
    return @"> ?";
}

- (NSArray *)getValues {
    return [NSArray arrayWithObject:value];
}

@end
