/**
 * TODO: Test class
 *     - P2P_BraintreeServices.cls
 *     - P2P_BraintreeHelper.cls
 *     - P2P_PayToBraintree.cls
 *
 * @author Kakada Khan 
 * @date 06-Feb-2015
 */

@isTest(seeAllData=true)
public class P2P_PayToBraintree_Test {
    
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
                                                              '<bin>450060</bin>'+
                                                              '<default type="boolean">true</default>' +
                                                              '<card-type>Visa</card-type>'+
                                                              '<last-4>0061</last-4>'+
                                                              '<image-url>https://assets.braintreegateway.com/payment_method_logo/visa.png?environment=sandbox</image-url>'+
                                                              '<token>k55x6b</token>' + 
                                                            '</credit-card>' + 
                                                      '</credit-cards>' + 
                                                '</customer>' ;
                                                
    private static final String RES_TRANS = '<?xml version="1.0" encoding="UTF-8"?>'+
											'<transaction>'+
											  '<id>jk4gjy</id>'+
											  '<status>submitted_for_settlement</status>'+
											  '<type>sale</type>'+
											  '<currency-iso-code>USD</currency-iso-code>'+
											  '<amount>10.00</amount>'+											  
											  '<credit-card>'+
											    '<token>3ksw2w</token>'+
											    '<bin>411111</bin>'+
											    '<last-4>1111</last-4>'+
											    '<card-type>Visa</card-type>'+
											  '</credit-card>'+			
											  '<disputes type="array"/>'+
											  '<payment-instrument-type>credit_card</payment-instrument-type>'+
											'</transaction>';
    
    
    private static final String RES_TRANS_Err = '<?xml version="1.0" encoding="UTF-8"?>'+
													'<api-error-response>'+
													  '<errors>'+
													    '<errors type="array"/>'+
													    '<transaction>'+
													      '<errors type="array">'+
													        '<error>'+
													          '<code>81531</code>'+
													          '<attribute type="symbol">+amount</attribute>'+
													          '<message>Amount must be greater than zero.</message>'+
													        '</error>'+
													      '</errors>'+
													    '</transaction>'+
													  '</errors>'+
													  '<params>'+
													    '<transaction>'+
													      '<amount>0</amount>'+
													      '<type>sale</type>'+
													      '<customer-id>0011100000ezfem</customer-id>'+
													      '<payment-method-token>6m5c6w</payment-method-token>'+
													      '<options>'+
													        '<submit-for-settlement>true</submit-for-settlement>'+
													      '</options>'+
													    '</transaction>'+
													  '</params>'+
													  '<message>Amount must be greater than zero.</message>'+
													'</api-error-response>';
    
   
                                                
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
   
    private static testMethod void testP2P_PayToBraintree() {
        setupData();
        
        Test.setCurrentPageReference(Page.P2P_PayToBraintree);
        ApexPages.CurrentPage().getparameters().put(P2P_PayToBraintree.PARAM_ACCID, acc.id);
        ApexPages.CurrentPage().getparameters().put(P2P_PayToBraintree.PARAM_ERR, '111 - aaa');
        
        // The page first load to get client token
        P2P_PayToBraintree con = new P2P_PayToBraintree();
        response4Test = RES_TOKEN;
        con.actionMethod();
        
        // The page second load after click save button
        ApexPages.CurrentPage().getparameters().put('payment_method_nonce', 'test none');
        ApexPages.CurrentPage().getparameters().put('holderName', 'test name');
        response4Test = RES_CUSTOMER;
        con.actionMethod();       
        P2P_BraintreeServices btServices = new P2P_BraintreeServices();
        P2P_BraintreeServices.CustomerParser cuParser = btServices.getCustomer('0011100000ezfem');	
        String paymentToken = cuParser.defaultPaymentMethodToken;
	    String pURL = cuParser.paymentURL;
	    String mask = cuParser.masked;
	    Boolean def = cuParser.defaultToken;
	    String cardType = cuParser.cardType;
        
        // Test create customer error then create credit card
        response4Test = RES_CUSTOMER_Err;
        con.actionMethod();
        response4Test = RES_CREDITCARD_Err;
        con.actionMethod();
        
        response4Test = RES_TRANS;
        con.actionMethod();
        
			
		P2P_BraintreeServices.TransactionParser trParser = btServices.createTransaction('0011100000ezfem','38ds8d', '10.00');
		String err = cuParser.errorMsg;
		err = trParser.errorMsg;
        
        
        response4Test = RES_TRANS_Err;
        con.actionMethod();
    }    
    
    
    
}