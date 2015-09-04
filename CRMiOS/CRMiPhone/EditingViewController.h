#import "Configuration.h"
#import "UITools.h"
#import "PickListSelectController.h"
#import "DateSelectController.h"
#import "EntityManager.h"
#import "UpdateListener.h"
#import "ValidationTools.h"
#import "FieldsManager.h"
#import "LayoutFieldManager.h"
#import "Item.h"
#import "SelectRelatedItem.h"
#import "SyncController.h"
#import "PictureManager.h"
#import "EvaluateTools.h"

@interface EditingViewController : UITableViewController<UpdateListener, UITextFieldDelegate, UIActionSheetDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> { 

    NSString *subtype;
    Item *item;
    Item *detail;
    NSObject<UpdateListener> *currentListener;
    NSMutableArray *allEditableField;
    BOOL isCreate;
    NSArray *sections;
    NSMutableArray *sectionData;
    NSMutableArray *relatedFields;
    UIImagePickerController *imagePicker;
    UIButton *chooseimage;
    UIImage *selectedimage;
    
}
@property(nonatomic, retain) UIImage *selectedimage;
@property(nonatomic, retain) UIButton *chooseimage;
@property(nonatomic, retain) UIImagePickerController *imagePicker;
@property(nonatomic, retain) NSMutableArray *relatedFields;
@property(nonatomic, retain) NSArray *sections;
@property(nonatomic, retain) NSMutableArray *sectionData;
@property(nonatomic, retain) NSMutableArray *allEditableField;
@property(nonatomic, retain) NSObject<UpdateListener> *currentListener;
@property(nonatomic, retain) Item *item;
@property(nonatomic, retain) Item *detail;
@property(nonatomic, retain) NSString *subtype;

- (void)cancel;
- (void)save;

- (id)initWithItem:(Item *)newItem updateListener:(NSObject <UpdateListener> *)newUPdateListener isCreate:(BOOL)newIsCreate;
- (void)changeSwitch:(id)sender;
- (void)changeText:(id)sender;
- (IBAction)deleteItem:(id)sender;
- (NSArray *)fillSectionData:(int)section ;
- (NSString *)getCodeFromTag:(int)tag;
- (void)choosePic:(id)sender;
- (void)checkboxchange:(id)sender;
@end

