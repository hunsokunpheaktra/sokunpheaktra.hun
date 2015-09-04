public class P2P_AlertManagementController {

public PKB_Status_Message__c m { get; set; }

private String soql {get;set;}

public String site;
public String siteName;
public String getSite() { return this.site; }
public void setSite(String s) { this.site = s; }
 
public String pstatus = 'All';
public String getPstatus() { return this.pstatus; }
public void setPstatus(String ps) { this.pstatus = ps; }

public String accstatus = 'Active';
public String getaccstatus() { return this.accstatus; }
public void setaccstatus(String accs) { this.accstatus = accs; }

public map<id,string> SiteMap = new map<id,string>();

public String sortField {
    get  { if (sortField == null) {sortField = 'lastName'; } return sortField;  }
    set;
  }
  
// format the soql for display on the visualforce page
//  public String debugSoql {
//    get { return soql + ' Package Status: ' + pstatus + ' Account Status: ' + accstatus + ' Credits Remain: ' + creditr + ' Burn Rate: ' + burnrate + ' LIMIT 20'; }
//    set;
//  }

public List<SelectOption> getSites() {
  List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('','- None -'));
        optionList.add(new SelectOption('All', 'All'));
        optionList.add(new SelectOption('Company', 'Company'));        
        optionList.add(new SelectOption('Financials', 'Financials'));
        optionList.add(new SelectOption('Metrics', 'Metrics'));
        optionList.add(new SelectOption('Store', 'Store'));
        optionList.add(new SelectOption('Support', 'Support')); 
  return optionList;     
}

public string getSiteName (){
    siteName = SiteMap.get(site);
    return siteName;
}

public List<SelectOption> getpstatuses() {
  List<SelectOption> optionList = new List<SelectOption>();
      for (OpportunityLineItem pstatus : [select Package_Status__c from OpportunityLineItem LIMIT 1])
        optionList.add(new SelectOption('All', 'All'));
        optionList.add(new SelectOption('Job accounts', 'Job accounts'));        
        optionList.add(new SelectOption('Motors accounts', 'Motors accounts'));
        optionList.add(new SelectOption('Property accounts', 'Property accounts'));
  return optionList;     
}

public List<SelectOption> getaccstatuses() {
  List<SelectOption> optionList = new List<SelectOption>();
      for (OpportunityLineItem accstatus : [select Opportunity.Account.Account_Status__c from OpportunityLineItem LIMIT 1])
        optionList.add(new SelectOption('Active', 'Active'));
        optionList.add(new SelectOption('Suspended - Bad Debt', 'Suspended'));        
        optionList.add(new SelectOption('Collection Agency', 'Collection Agency'));
  return optionList;     
}

   
           public list<PKB_Status_Message__c> getmessages() {
           return [SELECT Id, RecordType.Name, Status__c, Name, MessageText__c, Message_Type__c, Message_Start_DateTime__c, Message_End_DateTime__c, Module__c, Account__c, Account__r.Account_Type_Parent__c
                              FROM PKB_Status_Message__c
                   WHERE Status__c = 'Active'
                   AND RecordType.Name = 'PRO Console'
                   ];
      }
    
}