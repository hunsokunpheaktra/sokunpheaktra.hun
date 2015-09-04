//
//  AppPurchaseManager.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 1/17/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "AppPurchaseManager.h"

@implementation AppPurchaseManager
@synthesize parent;
@synthesize  hud=_hud;
#pragma -
#pragma Public methods

- (id)initwithView:(UIViewController *)view{

    self.parent=view;
    self=[super init];
    return self;
    
}
- (void)dismissHUD:(id)arg {
    
    [MBProgressHUD hideHUDForView:self.parent.view animated:YES];
    self.hud = nil;
    
}
//
// call this method once on startup
//
- (void)doRequest{
    
    self.hud = [MBProgressHUD showHUDAddedTo:parent.navigationController.view animated:YES];
    _hud.labelText = @"Loading CRM4Mobile...";
    
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:2.0];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PRODUCT_ID]];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{

    [MBProgressHUD hideHUDForView:parent.navigationController.view animated:YES];

    NSArray *products = response.products;
    responseProduct = [products count] == 1 ? [[products objectAtIndex:0] retain] : nil;
    
    if (responseProduct)
    {    
        NSString *message=[NSString stringWithFormat:@"Product description: %@ \nProduct price: %@",responseProduct.localizedDescription,responseProduct.price];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:responseProduct.localizedTitle message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        alert.tag=1;
        [alert show];
        [alert release];
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"error" message:[NSString stringWithFormat:@"Invalid product id: %@" , invalidProductId] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    //release product request
    [productsRequest release];
    [[NSNotificationCenter defaultCenter] postNotificationName:AppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (alertView.tag==1 && buttonIndex==1) {
        if ([self canMakePurchases]) {
                [self purchaseCRM4Mobile];
        }else{
            return;
        }
    }
}

#pragma -
#pragma Public methods

//
// call this method once on startup
//
- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    //[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    // get the product description
    [self doRequest];
    
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseCRM4Mobile
{
//    SKPayment *payment = [SKPayment paymentWithProductIdentifier:PRODUCT_ID];
//
//    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:PRODUCT_ID])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"TransactionReceipt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable full feature of CRM4Mobile
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:PRODUCT_ID])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCRM4MobilePurchased"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // rebuild tab to take effect for purchasing completed
        [PadTabTools buildTabs:parent.tabBarController];
        
    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:AppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:AppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
    
}

@end
