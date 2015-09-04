/**
 * Controller for page P2P_MyCVDatabase.page
 * @date 02-Dec-2014
 */

global class P2P_MyCVDatabase {

    public Account acc { get; set; }   
    public OpportunityLineItem oli { get; set; } 
     
    public P2P_MyCVDatabase(ApexPages.StandardController stdController) {
        acc = (Account)stdController.getRecord();
    }
    
    public list<OpportunityLineItem> getolicv() {
           return [SELECT Id, Opportunity.Account.Name, Opportunity.Account.Id, PricebookEntry.Product2.ProductCode, 
                              PricebookEntry.Product2.Name, Quantity, Package_Status__c, Opportunity.IsWon,
                              PricebookEntry.Product2.Product_Subtype__c, until_Date__c, PriceBookEntry.Product2.Site__r.Name
                              FROM OpportunityLineItem
                   WHERE PricebookEntry.Product2.ProductCode = 'CV'
                   AND Opportunity.IsWon = TRUE
                   AND until_date__c >= TODAY
                   AND Opportunity.Account.Id = :acc.Id
                   ];
      }
    
  // Alert banner at top of the page - Work in progress by Steve Paul
    public List<PKB_Status_Message__c> msgErr {
        get {
            List<PKB_Status_Message__c> systemMsg = new List<PKB_Status_Message__c>(); 
            for(PKB_Status_Message__c sm: [SELECT MessageText__c, Message_Type__c, Message_Start_DateTime__c, Message_End_DateTime__c, Module__c, Account__c
                                                  FROM PKB_Status_Message__c
                                                 WHERE Status__c = 'Active'
                                                  AND Module__c = 'CV Database'
                                                  AND (Account__c = :acc.Id OR Account__c = '')
                                                  AND ((Message_Start_DateTime__c < :system.now() AND
                                                        Message_End_DateTime__c   > :system.now())
                                                  OR   (Message_Start_DateTime__c = null AND
                                                        Message_End_DateTime__c   = null)) order by CreatedDate desc LIMIT 1
                                                  ]){
                   systemMsg.add(sm);
                 //System.debug('XXXXX sm-->' + sm);
            }
            return systemMsg;
        } 
        set;
    } 

}