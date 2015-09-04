/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class P2P_CustomLoginController {
    global String username{get;set;}
    global String password{get;set;}
    global P2P_CustomLoginController () {}
    global PageReference forwardToCustomAuthPage() {
        return new PageReference( '/P2P_MyCompany?id=0011100000bN9SO');
    }
    global PageReference login() {
        return Site.login(username, password, null);
    }

}