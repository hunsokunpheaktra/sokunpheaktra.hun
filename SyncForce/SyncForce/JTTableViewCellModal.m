/*
 * This file is part of the JTRevealSidebar package.
 * (c) James Tang <mystcolor@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "JTTableViewCellModal.h"

@implementation JTTableViewCellModal
@synthesize title;
@synthesize data;

- (void)dealloc {
    [data release];
    [title release];
    [super dealloc];
}

+ (id)modalWithTitle:(NSString *)title data:(NSString*)data{
    JTTableViewCellModal *modal = [[[[self class] alloc] init] autorelease];
    modal.title = title;
    modal.data = data;
    return modal;
}

@end

@implementation NSString (JTTableViewCellModal)
- (NSString *)title {
    return self;
}
-(NSString *)data {
    return self;
}
@end


#pragma mark -

@implementation JTTableViewCellModalSimpleType
@synthesize type;
+ (id)modalWithTitle:(NSString *)title data:(NSString*)data type:(NSInteger)type {
    JTTableViewCellModalSimpleType *modal = [[self class] modalWithTitle:title data:data];
    modal.type = type;
    return modal;
}
@end


#pragma mark -

@implementation JTTableViewCellModalLoadingIndicator

+ (id)modal {
    JTTableViewCellModalLoadingIndicator *modal = [[[[self class] alloc] init] autorelease];
    return modal;
}

@end


#pragma mark -

@implementation JTTableViewCellModalCustom
@synthesize info;

- (void)dealloc {
    [info release];
    [super dealloc];
}

+ (id)modalWithInfo:(NSDictionary *)info {
    JTTableViewCellModalCustom *modal = [[[[self class] alloc] init] autorelease];
    modal.info = info;
    return modal;
}

@end
