/**
 * TODO: Test class
 *     - P2P_BraintreeServices.cls
 *     - P2P_BraintreeHelper.cls
 *     - P2P_CreditCardLandingPage.cls
 *
 * @author Kakada Khan
 * @date 09-Oct-2014
 */

@isTest(seeAllData=true)
public class P2P_CreditCardTest {
    
    // This variable will be set to any response xml in test method
    public static String response4Test;
     
    private static final String RES_TOKEN = '<?xml version="1.0" encoding="UTF-8"?>'+
                                           '<client-token>'+
                                              '<value>eyJ2ZX</value>'+
                                           '</client-token>' ;
    
    private static final String RES_CUSTOMER = '<?xml version="1.0" encoding="UTF-8"?>'+
                                               '<customer>' +
                                                      '<id>16681806</id>' + 
                                                      '<credit-cards type="array">' +
                                                            '<credit-card>' + 
                                                              '<default type="boolean">true</default>' +
                                                              '<token>k55x6b</token>' + 
                                                            '</credit-card>' + 
                                                      '</credit-cards>' + 
                                                '</customer>' ;
                                                
    private static final String RES_CUSTOMER_Err =  '<?xml version="1.0" encoding="UTF-8"?>'+
                                                    '<api-error-response>'+
                                                      '<errors>'+
                                                        '<errors type="array"><error><code>111</code><message>aaa</message></error></errors>'+
                                                        '<customer>'+
                                                          '<errors type="array">'+
                                                            '<error>'+
                                                              '<code>91609</code>'+
                                                              '<attribute type="symbol">id</attribute>'+
                                                              '<message>Customer ID has already been taken.</message>'+
                                                            '</error>'+
                                                          '</errors>'+
                                                          '<credit-card>'+
                                                            '<errors type="array"><error><code>222</code><message>bbb</message></error></errors>'+
                                                          '</credit-card>'+
                                                        '</customer>'+
                                                      '</errors>'+
                                                    '</api-error-response>';
                                            
    private static final String RES_CREDITCARD_Err = '<?xml version="1.0" encoding="UTF-8"?>'+
                                                    '<api-error-response>'+
                                                          '<errors>'+
                                                                '<errors type="array"/>'+
                                                                '<credit-card>'+
                                                                      '<errors type="array">'+
                                                                            '<error>'+
                                                                                  '<code>81713</code>'+
                                                                                  '<attribute type="symbol">expiration_year</attribute>'+
                                                                                  '<message>Expiration year is invalid.</message>'+
                                                                            '</error>'+
                                                                            '<error>'+
                                                                                  '<code>81712</code>'+
                                                                                  '<attribute type="symbol">expiration_month</attribute>'+
                                                                                  '<message>Expiration month is invalid.</message>'+
                                                                            '</error>'+ 
                                                                      '</errors>'+
                                                                '</credit-card>'+
                                                          '</errors>'+ 
                                                    '</api-error-response>' ; 
     
    private static Account acc;
    
    private static void setupData(){
        Contact c= new Contact();
        c.FirstName='first';
        c.LastName='last';
        c.Email= c.FirstName + c.LastName +'@test.com';
        insert c;
        
        acc = new Account(Name = 'TestAcc', 
                        Braintree_Customer_ID__c = '16681806',
                        BillingStreet = 'DFP Fake Street',
                        BillingCity = 'DFP Fake City',
                        BillingState = 'DFP Fake State',
                        BillingPostalCode = '123',
                        BillingCountry = 'GB',
                        Country_Code__c='GB',
                        Bank_Country__c = 'GB',
                        Primary_contact__c=c.id
                        
                        ); // <id>16681806</id>
        insert acc;
    }
    
    private static void refreshAcc(){
        acc = [select id, Braintree_Customer_ID__c, EncryptedBTCustToken__c, BraintreeActiveFrom__c from Account where Id = :acc.Id ];
    }
    
    
    /*
    private static testMethod void testSchedule() {
        setupData();
        
        Test.startTest();
            response4Test = RES_CUSTOMER;   
            CreditCardScheduler sch = new CreditCardScheduler(acc.Id);
            sch.execute(null);
        Test.stopTest();
        
        refreshAcc(); // The token is synced from BrainTree to salesforce 
        System.assertEquals(acc.BraintreeCustToken__c, 'k55x6b'); //<token>k55x6b</token>
        
        // Execute webservice method for Error response 
        response4Test = RES_CUSTOMER_Err;
        CreditCardScheduler.testSchedule(acc.Id);   
    }
    */
    
    
    private static testMethod void testP2P_CreditCardLandingPage() {
        setupData();
        
        // Clear account fields since these fields will be updated
        acc.Braintree_Customer_ID__c = null;
        acc.EncryptedBTCustToken__c = null;
        acc.BraintreeActiveFrom__c   = null;
        update acc;
        
        Test.setCurrentPageReference(Page.P2P_CreditCardLandingPage);
        ApexPages.CurrentPage().getparameters().put(P2P_CreditCardLandingPage.PARAM_ACCID, acc.id);
        ApexPages.CurrentPage().getparameters().put(P2P_CreditCardLandingPage.PARAM_ERR, '111 - aaa');
        
        // The page first load to get client token
        P2P_CreditCardLandingPage con = new P2P_CreditCardLandingPage();
        response4Test = RES_TOKEN;
        con.actionMethod();
        
        // The page second load after click save button
        ApexPages.CurrentPage().getparameters().put('payment_method_nonce', 'test none');
        ApexPages.CurrentPage().getparameters().put('holderName', 'test name');
        response4Test = RES_CUSTOMER;
        con.actionMethod();
        
        refreshAcc(); // The account will be update with infor from BrainTree
        System.assertEquals(acc.Braintree_Customer_ID__c, '16681806'); //<id>16681806</id>
        System.assertEquals(acc.EncryptedBTCustToken__c, 'k55x6b'); //<token>k55x6b</token>
        System.assert(acc.BraintreeActiveFrom__c != null);  
        
        // Test create customer error then create credit card
        response4Test = RES_CUSTOMER_Err;
        con.actionMethod();
        response4Test = RES_CREDITCARD_Err;
        con.actionMethod();
    }    
    
    
    
}