//
//  PurchaseAppViewController.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 12/24/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "PurchaseAppViewController.h"

@implementation PurchaseAppViewController

- (id)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"INAPPP App Purchase";
    
    self.tableView.rowHeight = 60;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString *productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct *product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
    
}

- (void)reload {
    _products = nil;
    [self.tableView reloadData];
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = [products retain];
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)buyProduct:(UIButton*)button{
    
    SKProduct *product = _products[button.tag];
    [[RageIAPHelper sharedInstance] buyProduct:product];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    SKProduct *product = [_products objectAtIndex:indexPath.row];
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = product.localizedDescription;
    
    _priceFormatter.locale = product.priceLocale;
    
    if ([[RageIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIButton *buyProduct = [UIButton buttonWithType:UIButtonTypeCustom];
        buyProduct.tag = indexPath.row;
        buyProduct.frame = CGRectMake(0, 14, 48, 22);
        [buyProduct setBackgroundImage:[UIImage imageNamed:@"green-bg.png"] forState:UIControlStateNormal];
        [buyProduct setTitle:[_priceFormatter stringFromNumber:product.price] forState:UIControlStateNormal];
        buyProduct.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [buyProduct addTarget:self action:@selector(buyProduct:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = buyProduct;
    }
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
