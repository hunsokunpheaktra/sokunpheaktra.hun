
#import "Datagrid.h"
#import <objc/runtime.h>		//necessary for tweaking the UIWebView
#import "Item.h"
#import "DatetimeHelper.h"
#import "NumberHelper.h"
#import "InfoFactory.h"
#import "Entity.h"
#import "EntityManager.h"
#import "LikeCriteria.h"
#import "DataType.h"

@implementation Datagrid
@synthesize listener,model;
@synthesize idlookChlidren,idnewChlid,idrecordEdit;


-(id)initWithFrame:(CGRect)frame listener:(NSObject<DatagridListener> *)plistener model:(NSObject<DataModel> *)pmodel idlookChlidren:(BOOL)pidlookChlidren idnewChlid:(BOOL)pidnewChlid idrecordEdit:(BOOL)pidrecordEdit{
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"REFRESH", Nil) style:UIBarButtonItemStyleBordered target:self action:@selector(refreshClicked:)];
    [self.navigationItem setRightBarButtonItem:refreshButton];
    
    self.listener = plistener;
    self.model = pmodel;
    self.idlookChlidren = pidlookChlidren; 
    self.idnewChlid = pidnewChlid;
    self.idrecordEdit = pidrecordEdit;
    
    webview = [[UIWebView alloc]initWithFrame:frame];
    webview.delegate=self;
    [self.model populate];
    
    [self populate];
    [webview reload];
    self.view = webview;
    
    [super init];
    return self;
}

+(NSString *) getActionImg{
    return @"button_lupe_29x30";
}

+(NSString *) getCheckboxImg{
    return @"CheckBox";
}

+(NSString *) getUncheckboxImg{
    return @"UncheckBox";
}

+(NSString *) getAddImg{
    return @"add";
}

+(NSString *) getEditImg{
    return @"Edit";
}

-(NSString*)pathImage:(NSString*)imageName withType:(NSString*)imageType{
	NSString *filePath = [[NSBundle mainBundle]pathForResource:imageName ofType:imageType];
	if(filePath){
        return filePath;
    }
	else
		return @"";
}


-(void) refreshClicked:(id)sender{
    
    [self.model populate];
    [self populate];
    self.view = webview;    
}

-(void)populate{
    // the column names will contain the Id field, but will not be displayed, but used for the callback
    
    // build the html table
	NSMutableString* string =[[NSMutableString alloc]initWithCapacity:10];	
	
    [string appendString:
     @"<html>"
     "<head>"
     "<meta name=\"viewport\" content=\"width=320\"/>"
     
     "<script>"
     
     "function imageClicked(sobject,id,reason){"
     
     "var clicked=true;"
     
     "window.location=\"/click/\"+clicked+\"/\"+sobject+\"/\"+id+\"/\"+reason;"
     
     "}"
     
     "</script>"
     
     "<style>"
     
     "body{background-color:#FFFFFF}"
     
     "th{font-family:'Helvetica Neue Light';font-size:14px;font-weight:55;padding:5 10 5 10;text-align:center;background-color:#2E8AE6;border: 0px solid #F0FAFF;border-radius: 5px;-moz-border-radius: 5px;}"
     
     ".evenrow{background-color:#FFFFFF;height:40px;}"
     
     ".oddrow{background-color:#F0FAFF;height:40px;}"
     
     "td{border-size: 0,font-family:'Helvetica Neue Light';font-size:14px;font-weight:55;font-color:#4D4D4D;padding:5,5,5,5;border: 0px solid #F0F5FF;border-radius: 5px;-moz-border-radius: 5px;}"
     
     ".tdinner{border-size: 0,font-family:'Helvetica Neue Light';font-size:14px;font-weight:55;font-color:#4D4D4D;padding:5,5,5,5;border: 0px}"
     
     "</style>"
     
     "</head>"
     "<body>"
	 ];
    
    [string appendString:@"<table border='0'>"];	
    [string appendString:@"<thead>"];	
    int columnNumber = [self.model getColumnCount];
    for(int i=0; i < columnNumber ; i++ ) {
        NSString* colName = [self.model getColumnName:i];
        if(colName == [self.model getIdColumn]){
            colName = @"Action";
        }
        [string appendString:[NSString stringWithFormat:@"<th><font color='#FFFFFF'>%@</font></th>",colName]];
    }
    [string appendString:@"</thead><tbody>"];
    
    for(int k=0 ; k < [self.model getRowCount]; k++){
        if(k % 2 == 0){
            [string appendString:@"<tr class='evenrow'>"];
        }else{
            [string appendString:@"<tr class='oddrow'>"];
        }
        
        //Item* item = [datas objectAtIndex:k];
        for(int i=0; i < columnNumber; i++ ) {
            NSString* colName = [self.model getColumnName:i];
            NSString* datastring = [self.model getValueAt:k columnIndex:i];
            if(datastring == nil) datastring = @"";
            
            if([colName isEqualToString:[self.model getIdColumn]] && [datastring length] != 0){
                
                [string appendString:[NSString stringWithFormat:@"<td><center><table><tr>"]];
                if(idlookChlidren){
                    [string appendString:[NSString stringWithFormat:@"<td class='tdinner'><a href=\"javascript:void(0)\" onMouseDown=\"imageClicked('%@','%@','%@')\">",[self.model getEntityName],datastring,[Datagrid getActionImg]]];
                    [string appendString:[self produceImage:[Datagrid getActionImg] withType:@"png"]];
                    [string appendString:@"</a></td>"];
                }
                if(idnewChlid){
                    [string appendString:[NSString stringWithFormat:@"<td class='tdinner'><a href=\"javascript:void(0)\" onMouseDown=\"imageClicked('%@','%@','%@')\">",[self.model getEntityName],datastring,[Datagrid getAddImg]]];
                    [string appendString:[self produceImage:[Datagrid getAddImg] withType:@"png"]];
                    [string appendString:@"</td></a>"];
                }
                if(idrecordEdit){
                    [string appendString:[NSString stringWithFormat:@"<td class='tdinner'><a href=\"javascript:void(0)\" onMouseDown=\"imageClicked('%@','%@','%@')\">",[self.model getEntityName],datastring,[Datagrid getEditImg]]];
                    [string appendString:[self produceImage:[Datagrid getEditImg] withType:@"png"]];
                    [string appendString:@"</a></td>"];
                }
                [string appendString:@"</tr></table></center></td>"];
                
            }else{
                NSString *dataFormatted = datastring;
                int type = [self.model getColumType:i];
                
                if(type == TYPE_DATE || type == TYPE_DATETIME ){
                    dataFormatted = [DatetimeHelper display:datastring];
                }else if(TYPE_CURRENCY ==  type){
                    dataFormatted = [NumberHelper formatCurrencyValue:[datastring doubleValue]];
                    dataFormatted = [NSString stringWithFormat:@"<div align='right'>%@</div>",dataFormatted];
                }else if(TYPE_BOOLEAN ==  type){
                    dataFormatted =[self produceImage:[Datagrid getCheckboxImg] withType:@"png"];
                    if([datastring isEqualToString:@"0"]||[datastring isEqualToString:@"false"]||[datastring isEqualToString:@"NO"]){
                        dataFormatted = [self produceImage:[Datagrid getUncheckboxImg] withType:@"png"];
                    }
                    dataFormatted = [NSString stringWithFormat:@"<center>%@</center>",dataFormatted];
                }else if(TYPE_DOUBLE ==  type || TYPE_INT == type){
                    dataFormatted = [NumberHelper formatNumberDisplay:[datastring doubleValue]];
                    dataFormatted = [NSString stringWithFormat:@"<div align='right'>%@</div>",dataFormatted];
                }
                else if(TYPE_PERCENT ==  type){
                    dataFormatted = [NumberHelper formatNumberDisplay:[datastring doubleValue]];
                    dataFormatted = [NSString stringWithFormat:@"<div align='right'>%@</div>",dataFormatted];
                }
                [string appendString:[NSString stringWithFormat:@"<td>%@</td>",dataFormatted]];
            }
        }
        [string appendString:@"</tr>"];
    }
    
    
    [string appendString:@"</tbody>"
     "</table>"];
    
	[string appendString:@"</body>"
	 "</html>"
	 ];
    
    //load the HTML String on UIWebView
    [webview loadHTMLString:string baseURL:nil];
	[string release];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	//linking the javascript to call the iPhone control
	if ( [request.mainDocumentURL.relativePath isEqualToString:@"/click/false"] ) {	
		NSLog( @"not clicked" );
		return false;
	}
    NSString* requesturl = request.mainDocumentURL.relativePath;
    if(requesturl == nil) return true;
    NSRange range = [requesturl rangeOfString:@"true"];    
    if (range.length>0) {
        NSArray *splited = [[NSArray alloc] initWithArray:[requesturl componentsSeparatedByString:@"/"]];
		// todo invoke the listener when user click on a particular row - to be defined in the html
        if (self.listener!=nil) {
            GridItem* item = [[GridItem alloc]init];
            [item setObjectName:[splited objectAtIndex:3]];
            [item setEntityId:[splited objectAtIndex:4]];
            [item setClickReason:[splited objectAtIndex:5]];
            [self.listener callback:item];
        }
        return false;
        
    }
	return true;
}


-(NSString*)produceImage:(NSString*)imageName withType:(NSString*)imageType{
	NSMutableString *returnString=[[[NSMutableString alloc]initWithCapacity:100]autorelease];
	NSString *filePath = [self pathImage:imageName withType:imageType];
	if(filePath){
		[returnString appendString:@"<IMG SRC=\"file://"];
		[returnString appendString:filePath];
		[returnString appendString:@"\" ALT=\""];
		[returnString appendString:imageName];
		[returnString appendString:@"\">"];
		return returnString;
	}
	else
		return @"";
} 


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)dealloc{		
    [model release];
    [webview release];
	[listener release];
	[super dealloc];
}




@end
