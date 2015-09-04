

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DatagridListener.h"
#import "DataModel.h"

@interface Datagrid :  UIViewController <UIWebViewDelegate,UIGestureRecognizerDelegate,UIAccelerometerDelegate>{	
    //change it so our main view inherits from UIWebView
    NSObject <DatagridListener> *listener;
    NSObject <DataModel> *model;
    UIWebView *webview;
    BOOL idlookChlidren;
    BOOL idnewChlid;
    BOOL idrecordEdit;
}


@property (nonatomic,retain) NSObject <DatagridListener> *listener;
@property (nonatomic,retain) NSObject <DataModel> *model;
@property (nonatomic) BOOL idlookChlidren;
@property (nonatomic) BOOL idnewChlid;
@property (nonatomic) BOOL idrecordEdit;


-(id)initWithFrame:(CGRect)frame listener:(NSObject<DatagridListener> *)plistener model:(NSObject<DataModel> *)pmodel idlookChlidren:(BOOL)pidlookChlidren idnewChlid:(BOOL)pidnewChlid idrecordEdit:(BOOL)pidrecordEdit;
-(void)populate;
//method for attaching image to the HTML
-(NSString*)produceImage:(NSString*)imageName withType:(NSString*)imageType;	

+(NSString *) getActionImg;
+(NSString *) getCheckboxImg;
+(NSString *) getUncheckboxImg;
+(NSString *) getAddImg;
+(NSString *) getEditImg;

@end
