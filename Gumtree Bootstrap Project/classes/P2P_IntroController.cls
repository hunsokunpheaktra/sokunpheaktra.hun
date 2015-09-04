/**

GTCRM-1232 - PRO manage ads force.com console
- Splash marketing screen on customer first login
- Highlight benefits of console

**/

public class P2P_IntroController {

    public Account acc { get; set; }   
    public Advertising_Medium__c adMedium {get;set;}
    public Boolean isSplashUpdate {get;set;}
    public String adid{get;set;}
    public String images{get;set;}

    public P2P_IntroController(ApexPages.StandardController stdController){
        acc = (Account)stdController.getRecord();
        MktgSplash();
    }
       
    private void MktgSplash(){
        
        acc = [Select Id, Marketing_Splash__c
            From Account Where Id =: acc.Id];
    }
    
    
    /** Update Account.Marketing_Splash__c when changed*/
    public Pagereference SplashUpdate(){
                        
           Boolean curFeedSetup = acc.Marketing_Splash__c;
           acc.Marketing_Splash__c = !curFeedSetup;
                
           update acc;
           return null;
        }
    
    
    public PageReference advMedium(){
        
        images = adMedium.Desktop_Image__c + ',';
        images += adMedium.Mobile_Image__c + ',';
        images += adMedium.iPhone_App_Image__c + ',';
        images += adMedium.Android_App_Image__c;
        
        return null;
    }
        
}