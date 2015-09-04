/**
 * Controller for page P2P_CreditCardLandingPage
 * This class is use to create:
 *	- Customer 
 *	- Payment 
 *  - Transaction 
 *	at BrainTree site
 *
 * @author Kakada Khan
 * @date 10-Oct-2014
 */ 


public class P2P_CreditCardLandingPage {
    
    /** Parameter for get error from URL*/
    public static final String PARAM_ERR = 'BTerrors';
    /** Parameter for get account ID from URL*/ 
    public static final String PARAM_ACCID = 'ccregaccid';
    /** Parameter for get Amount from URL*/
    public static final String AMOUNT_PAR = 'amount';   
    /** Parameter for get Account ID use in Controller*/
    public String accIdParamName {get{return PARAM_ACCID;}}  
    /** Return client token to web form*/
    public String  client_Token{get;set;} 
    /** Stroe account Id to use in controller*/
    public String accId{get;set;}
    /** The message to display on page*/
    public String message{get;set;}
    /** The Amount to be create transaction*/
    public String amount{get{return getAmount();}set;}

    /**
     * Constructor
     * Initailize variables value.
     */
    public P2P_CreditCardLandingPage(){          
        // The correct accId is always embaded in the URL
        accId = ApexPages.currentPage().getParameters().get(accIdParamName);                
        // For: The page redirect and load again when creating a new customer with errors ( Reload to get new client token)
        String theErr = ApexPages.currentPage().getParameters().get(PARAM_ERR); 
        
        //Display the message on page load
        displayError(theErr);
        
    } 
    
    /**
     * This method is the ActionMethod of the Page
     * It will do one of the following:
     *    - Request ClientToken from BrainTree whenever the page first load
     *    - Request Creating a new Customer/CreditCard at BrainTree whenever the page reload after clicking the form button
     * @return Pagereference
     */
    public Pagereference actionMethod(){         
        // If the Client-Token request success, these params will exist. 
        String paymentMethodNonce = ApexPages.currentPage().getParameters().get('payment_method_nonce');
        String holderName = ApexPages.currentPage().getParameters().get('holderName');

        // Service object  
        P2P_BraintreeServices btServices = new P2P_BraintreeServices();
        
        // The page first load --------------------------  
        if(paymentMethodNonce == null || holderName == null) {
            // First request (Client Token) when the page loaded 
            P2P_BraintreeServices.ClientTokenParser ctParser = btServices.getClientToken();
            client_Token = ctParser.clientToken;
            // Handle Error
            if(ctParser.isError){
                displayError(ctParser.errorMsg);
            }
        
        // The page reload ----------------------------
        }
        else{
            Account acc = [ Select  Id, Name, Finance_contact__r.Email, Finance_contact__r.Phone, 
                            Braintree_Customer_ID__c, BraintreeActiveFrom__c, EncryptedBTCustToken__c
                            From Account Where Id = :accId];  

            
            
            // Second request (Create a customer) when the button clicked
            P2P_BraintreeServices.CustomerParser cuParser = btServices.createCustomer(paymentMethodNonce, holderName, acc);
            
            String paymentToken = cuParser.defaultPaymentMethodToken;       
            //isSuccess = !cuParser.isError;
            String errorMsg = cuParser.errorMsg;
                        
            if(cuParser.isError){
                // if Creating a customer fail, create a new payment method
                P2P_BraintreeServices.CreditCartParser ccParser = btServices.createCreditCard(paymentMethodNonce, holderName, acc.id);              
                paymentToken = ccParser.token;              
                //isSuccess = !ccParser.isError;
                errorMsg = ccParser.errorMsg;           
            }
            
            // Create transaction-------- 
           // P2P_BraintreeServices.TransactionParser trParser = btServices.createTransaction(accId, holderName, paymentToken, amount);
           // errorMsg = String.isBlank(errorMsg)? trParser.errorMsg : errorMsg + (String.isBlank(trParser.errorMsg)? '':trParser.errorMsg);
          //  if(!trParser.isError)errorMsg = 'ok';
            
            if(!cuParser.isError){
                // if Creating a customer success, update the account with the returning fields from BrainTree
                acc.Braintree_Customer_ID__c = cuParser.id; 
                acc.EncryptedBTCustToken__c = cuParser.defaultPaymentMethodToken;
                acc.BraintreeActiveFrom__c   = System.today(); 
                update acc; 
            } 

            
            //put error to URL-------
            if(!String.isBlank(errorMsg)){ 
                // If Error, reload the page again to get new client token, and add the errors
                Pagereference pg = Page.P2P_CreditCardLandingPage; 
                pg.getParameters().put(accIdParamName, acc.Id);
                pg.getParameters().put(PARAM_ERR, errorMsg);
                pg.getParameters().put(AMOUNT_PAR, amount);
                pg.setRedirect(true); 
                return pg;
            }
        }
        return null;
    }

    /**
     * Method to format Amount
     * @return String the amount formated
     */ 
    public String getAmount() {     
        String i =ApexPages.currentPage().getParameters().get(AMOUNT_PAR);      
        String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
        return s.substring(0,s.length()-1);
    }
    
    /**
     * Method to display message on page load
     * @param msg the message to be display
     */     
    private void displayError(String msg){
        message=msg;
        String status = ApexPages.currentPage().getParameters().get(PARAM_ERR);     
        if(String.isBlank(msg)) message='';
        else if(status == 'ok')message = 'Your transaction was created successfully!';
        //else if( ! msg.contains('trans-authorized'))message=msg;
        //else message = 'Your transaction was created successfully!';
        
    }
}