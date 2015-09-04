#import <UIKit/UIKit.h>
#import "EntityInfo.h"
#import "Configuration.h"
#import "EntityManager.h"
#import "BigDetailViewController.h"
#import "GroupManager.h"

@interface RelatedListViewController : UITableViewController<UpdateListener> {
    
    NSArray *relatedList;
    NSString *entity;
    NSMutableArray *relatedItems;
    NSArray *groups;
    NSString *sType;
    
}
@property (nonatomic, retain) NSString *sType;
@property (nonatomic, retain) NSMutableArray *relatedItems;
@property (nonatomic, retain) NSArray *groups;
@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSArray *relatedList;

- (id) initWithEntity:(NSString *)newEntity subtype:(NSString *)subtype relatedList:(NSArray *)newRelatedList;

@end


