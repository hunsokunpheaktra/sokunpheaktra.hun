/**
 *	@Author : SPP
 *	@Date : 02/09/2015
 *	@Description : 	Utility class to sign relative url request in order to access Gumtree BAPI System
 *					Task #4849 : GTCRM-1292- PRO - M3 - 'My Company' module - Default ad image & packages via Gumtree BAPI
 *	@Change log : 
 *					11-02-2015 modified by Pheaktra Hun  
 */
public class P2P_SecurityUtils {
    
    public static final String ACCESS_KEY = 'apiKey';
    public static final String TIMESTAMP = 'timestamp';
    public static final String SIGNATURE = 'signature';
    public static final String AUTHENTICATION_ENABLED = 'authentication';
    public static final String uploadbyurl_service = '/api/images/byurl';
    public static final String defaultimage_service = '/api/accounts/$accountid$/defaultImage';
    
    private static final String API_SIGNATURE_ALGORITHM = 'hmacSHA256';
    private static P2P_RequestAdImage__c adImageSetting = P2P_RequestAdImage__c.getValues('Default Ad image');
    
    /**
     *	Sign service url
     */
    public static String createApiRequestSignature(String serviceurl)  {
        // params are ordered
        String newserviceurl = serviceurl + '?' + 'apiKey=' + adImageSetting.BAPI_Key__c +  '&timestamp=' + System.currentTimeMillis();
        
        // now we sign the relative - lower case 
        String urlsigned  = generateHmacSHA256Signature(newserviceurl.tolowercase(), adImageSetting.Private_Key__c);
        
        return newserviceurl + '&signature=' + urlsigned;
    }
    
    private static String generateHmacSHA256Signature(String urltoencode, String pk) {
        Blob hmacData = Crypto.generateMac(API_SIGNATURE_ALGORITHM, Blob.valueOf(urltoencode), Blob.valueOf(pk));
        return EncodingUtil.convertToHex(hmacData);
    }
    
    /**
     *	Request default ad image for account
     */
    public static void getDefaultImage(String accountNumber, GumtreeImage gm) {
    	if(accountNumber == null) return;
    		
        String u = defaultimage_service.replace('$accountid$', accountNumber);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(adImageSetting.EndPoint__c + P2P_SecurityUtils.createApiRequestSignature(u));
        req.setMethod('GET');
   
		Http http = new Http();
		HTTPResponse res = http.send(req);
		 
		//{"id":332672253,"url":"http://i.ebayimg.com/00/s/OTdYMjIw/z/m-YAAOSwe-FU2deP/$_1.JPG"} 
		parseResponseBody(res, gm);
		gm.isSuccess = true;
    }
    
    /**
     *	Upload image to Gumtree site get id
     */
    public static void uploadImageByUrl(String imageurl, GumtreeImage gm) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(adImageSetting.EndPoint__c + P2P_SecurityUtils.createApiRequestSignature(uploadbyurl_service));
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json;charset=UTF-8');
        
        JSONGenerator generator = JSON.createGenerator(true);   //instantiation of the generator
        generator.writeStartObject();               // Writes the starting marker of a JSON object '{'
        generator.writeStringField('image_url', imageurl);   
        generator.writeEndObject();                 //Writes the ending marker of a JSON object '}'
        String jsonString = generator.getAsString();
        
        req.setBody(jsonString);
   
        Http http = new Http();
        HTTPResponse res = http.send(req);
     	
     	//{"id":333127998,"url":"http://i.ebayimg.com/00/s/MzAwWDQwMA==/z/b2QAAOSwNSxU2zDJ/$_1.JPG"}    
        parseResponseBody(res, gm);
    }
    
    /**
     *	Set the image have uploaded as default ad image for account
     */
    public static void setDefaultImage(String accountNumber, GumtreeImage gm) {
        
        String u = defaultimage_service.replace('$accountid$', accountNumber);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(adImageSetting.EndPoint__c + P2P_SecurityUtils.createApiRequestSignature(u));
        req.setMethod('PUT');
        req.setHeader('Content-Type','application/json;charset=UTF-8');
        
        JSONGenerator generator = JSON.createGenerator(true);   //instantiation of the generator
        generator.writeStartObject(); // Writes the starting marker of a JSON object '{'
        generator.writeStringField('image_id', gm.imageId);   
        generator.writeEndObject();	//Writes the ending marker of a JSON object '}'
        String jsonString = generator.getAsString();
        
        req.setBody(jsonString);
   
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        //{"account":{"id":3317,"name":"Gumtree.com (Jobs)","description":"Salesforce Account","address1":"Whittaker House, Whittaker Avenue","postcode":"TW9 1EH","city":"Richmond","county":"Surrey","country":"GB","status":"ACTIVE","default_image":{"id":332672253,"url":"http://i.ebayimg.com/00/s/OTdYMjIw/z/m-YAAOSwe-FU2deP/$_79.JPG","thumbnail_url":"http://i.ebayimg.com/00/s/OTdYMjIw/z/m-YAAOSwe-FU2deP/$_77.JPG"},"usernames":["info@jobmate.co.uk","stevenjpaul7@gmail.com"],"force_post_as_agency":false,"pro":true}}
        parseResponseBody(res, gm);
    }
    
    /**
     *	Delete the default ad image
     */
    public static void deleteDefaultImage(String accountNumber, GumtreeImage gm) {
        
        String u = defaultimage_service.replace('$accountid$', accountNumber);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(adImageSetting.EndPoint__c + P2P_SecurityUtils.createApiRequestSignature(u));
        req.setMethod('PUT');
        req.setHeader('Content-Type','application/json;charset=UTF-8');
        
        // empty json
        req.setBody('{}');
   
		Http http = new Http();
		HTTPResponse res = http.send(req);
		
		//{"account":{"id":3317,"name":"Gumtree.com (Jobs)","description":"Salesforce Account","address1":"Whittaker House, Whittaker Avenue","postcode":"TW9 1EH","city":"Richmond","county":"Surrey","country":"GB","status":"ACTIVE","usernames":["info@jobmate.co.uk","stevenjpaul7@gmail.com"],"force_post_as_agency":false,"pro":true}}
		parseResponseBody(res, gm);
	}
	
	/**
	 *	Parse HttpResponse body success or error
	 */
	private static void parseResponseBody(HTTPResponse res, GumtreeImage gm){
		
		//success response body
		if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
			gm.isSuccess = true;
			
			Map<String, Object>mResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
			if(mResponse.containsKey('id')) gm.imageId = (Integer)mResponse.get('id') + '';
			if(mResponse.containsKey('url')) gm.imageURL = (String)mResponse.get('url');
		//error
		}else{
			gm.isSuccess = false;
			gm.errMsg = 'Request Error : ' + res.getBody();
		}
	}
	
	public class GumtreeImage{
		public String imageId{get;set;}
		public String imageURL{get;set;}
		public Boolean isSuccess{get;set;}
		public String errMsg{get;set;}
	}

}