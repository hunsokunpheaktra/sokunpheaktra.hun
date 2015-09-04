/**
* TODO: Test Class
*	- P2P_URLRewriter
*
* @author Sochettra Saing
* @date 16-Feb-2015
*/

@isTest
private class P2P_URLRewriterTest {

	//test method generateUrlFor
    static testMethod void testGenerateUrlFor() {
    	
    	P2P_URLRewriter rewriter = new P2P_URLRewriter();
    	PageReference pageRef ;//= new PageReference('/p2p_mycompany');
    	
    	List<PageReference> lsPageRef = new List<PageReference>();
    	
    	lsPageRef.add(new PageReference('/ads'));
    	lsPageRef.add(new PageReference('/p2p_mycompany'));
    	lsPageRef.add(new PageReference('/p2p_myfinancials'));
    	lsPageRef.add(new PageReference('/p2p_myfinancialspayment'));
    	lsPageRef.add(new PageReference('/p2p_mymetrics'));
    	lsPageRef.add(new PageReference('/p2p_mycheckout'));
    	lsPageRef.add(new PageReference('/p2p_mycheckoutpayment'));
    	lsPageRef.add(new PageReference('/p2p_mysupport'));
    	
    	//System.assert(test == '/company');
    	list<Pagereference> test = rewriter.generateUrlFor(lsPageRef);
        // TO DO: implement unit test
    }
    
    // method mapRequestUrl
    static testMethod void testMapNonVipUrl() {
    	
        P2P_URLRewriter rewriter = new P2P_URLRewriter();
        
        String actualResult = rewriter.mapRequestUrl(new PageReference('/company')).getUrl();
        //String expectedResult = '/testUrl';
        System.assert(actualResult == '/p2p_mycompany');
    }
    
}