//
//  MVPurchaseViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 7/13/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVPurchaseViewController.h"
#import "SWRevealViewController.h"
#import "MVPurchaseCell.h"

#import <Firebase.h>
#import <VKApi.h>

@interface MVPurchaseViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITableView *purchaseTableView;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSString *VKUserID;
@property (strong, nonatomic) NSString *balance;
@property (strong, nonatomic) NSArray *gain;

@property (strong, nonatomic) NSMutableArray<SKProduct *> *products;
@property (strong, nonatomic) SKProduct *currentProduct;

@end

static NSString *coins300 = @"com.mountain_viewer.vk_likes_and_followers.300coins";
static NSString *coins700 = @"com.mountain_viewer.vk_likes_and_followers.700coins";
static NSString *coins2000 = @"com.mountain_viewer.vk_likes_and_followers.2000coins";
static NSString *coins7000 = @"com.mountain_viewer.vk_likes_and_followers.7000coins";
static NSString *coins18000 = @"com.mountain_viewer.vk_likes_and_followers.18000coins";

@implementation MVPurchaseViewController

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Product request");
    NSArray<SKProduct *> *products = response.products;
    self.products = [[NSMutableArray alloc] init];
    
    for (SKProduct *product in products) {
        NSLog(@"Product added");
        NSLog(@"%@", product.productIdentifier);
        NSLog(@"%@", product.localizedTitle);
        NSLog(@"%@", product.localizedDescription);
        NSLog(@"%@", product.price);
        
        [self.products addObject:product];
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"Transaction restored");
    
    for (SKPaymentTransaction *transaction in queue.transactions) {
        NSString *ID = transaction.payment.productIdentifier;
        
        if ([ID isEqualToString:coins300]) {
            NSLog(@"Added coins to account: %@", coins300);
            [self addCoinsAfterButtonTappedWithIndex:0];
        } else if ([ID isEqualToString:coins700]) {
            NSLog(@"Added coins to account: %@", coins700);
            [self addCoinsAfterButtonTappedWithIndex:1];
        } else if ([ID isEqualToString:coins2000]) {
            NSLog(@"Added coins to account: %@", coins2000);
            [self addCoinsAfterButtonTappedWithIndex:2];
        } else if ([ID isEqualToString:coins7000]) {
            NSLog(@"Added coins to account: %@", coins7000);
            [self addCoinsAfterButtonTappedWithIndex:3];
        } else if ([ID isEqualToString:coins18000]){
            NSLog(@"Added coins to account: %@", coins18000);
            [self addCoinsAfterButtonTappedWithIndex:4];
        } else {
            NSLog(@"In-App Purchase not found");
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    NSLog(@"Add payment");
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch ([transaction transactionState]) {
            case SKPaymentTransactionStatePurchased:
            {
                NSLog(@"Buy ok");
                NSLog(@"%@", self.currentProduct.productIdentifier);
                
                NSString *ID = self.currentProduct.productIdentifier;
                
                if ([ID isEqualToString:coins300]) {
                    NSLog(@"Added coins to account: %@", coins300);
                    [self addCoinsAfterButtonTappedWithIndex:0];
                } else if ([ID isEqualToString:coins700]) {
                    NSLog(@"Added coins to account: %@", coins700);
                    [self addCoinsAfterButtonTappedWithIndex:1];
                } else if ([ID isEqualToString:coins2000]) {
                    NSLog(@"Added coins to account: %@", coins2000);
                    [self addCoinsAfterButtonTappedWithIndex:2];
                } else if ([ID isEqualToString:coins7000]) {
                    NSLog(@"Added coins to account: %@", coins7000);
                    [self addCoinsAfterButtonTappedWithIndex:3];
                } else if ([ID isEqualToString:coins18000]){
                    NSLog(@"Added coins to account: %@", coins18000);
                    [self addCoinsAfterButtonTappedWithIndex:4];
                } else {
                    NSLog(@"In-App Purchase not found");
                }
                [queue finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed:
            {
                NSLog(@"Buy failed");
                [queue finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStatePurchasing:
            {
                NSLog(@"Wait bro");
                break;
            }
            case SKPaymentTransactionStateRestored: {
                NSLog(@"Restored");
                break;
            }
            case SKPaymentTransactionStateDeferred: {
                NSLog(@"Deffered");
                break;
            }
        }
    }
}

#pragma mark - Configure gain array -

- (void)configureGainArray  {
    self.gain = [[NSArray alloc] initWithObjects:@"300", @"700", @"2000", @"7000", @"18000", nil];
}

#pragma mark - Purchase method -

- (IBAction)purchase:(UIButton *)sender {
    // 1. Detect which button has been tapped
    UIView *contentView = sender.superview;
    UITableViewCell *cell = (UITableViewCell *)contentView.superview;
    NSIndexPath *indexPath = [self.purchaseTableView indexPathForCell:cell];
    
    // 2. Update current product
    NSInteger index = indexPath.row;
    NSString *productID;
    
    switch (index) {
        case 0:
            productID = coins300;
            break;
        case 1:
            productID = coins700;
            break;
        case 2:
            productID = coins2000;
            break;
        case 3:
            productID = coins7000;
            break;
        case 4:
            productID = coins18000;
            break;
    }
    
    for (SKProduct *product in self.products) {
        if ([product.productIdentifier isEqualToString:productID]) {
            self.currentProduct = product;
            [self buyProduct];
        }
    }
}

- (void)addCoinsAfterButtonTappedWithIndex:(NSInteger)index {
    NSInteger oldValue = [self.balance intValue];
    NSInteger delta = [self.gain[index] intValue];
    NSString *newValue = [NSString stringWithFormat:@"%ld", oldValue + delta];
    
    [[[[self.ref child:@"users"] child: self.VKUserID] child:@"coins"] setValue:newValue];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSInteger second = [components second];
    NSInteger minute = [components minute];
    NSInteger hour = [components hour];
    
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    
    [[[self.ref child:@"payments"] child:[NSString stringWithFormat:@"%@ (%ld:%ld:%ld %ld-%ld-%ld)", self.VKUserID, hour, minute, second, day, month, year]] setValue:self.gain[index]];
}

- (void)buyProduct {
    NSLog(@"Buying product %@", self.currentProduct.productIdentifier);
    SKPayment *payment = [SKPayment paymentWithProduct:self.currentProduct];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)loadInApps {
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"Can make payments");
        
        NSSet *productIDs = [[NSSet alloc] initWithObjects:coins300, coins700, coins2000, coins7000, coins18000, nil];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIDs];
        request.delegate = self;
        [request start];
    } else {
        NSLog(@"Please enable IAPs");
    }
}

#pragma mark - Purchase Table View Delegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"PurchaseCell";
    
    MVPurchaseCell *cell = (MVPurchaseCell *)[self.purchaseTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    switch (indexPath.row) {
        case 0:
            cell.purchaseImage.image = [UIImage imageNamed:@"one_coin"];
            cell.purchaseGain.text = @"300 монет";
            cell.purchaseCost.text = @"за 15.00 ₽";
            cell.purchaseButton.layer.borderColor = [UIColor colorWithRed:94.0 / 255.0 green:168.0 / 255.0 blue:94.0 / 255.0 alpha:1.0].CGColor;
            cell.purchaseButton.layer.borderWidth = 1.0;
            cell.purchaseButton.layer.cornerRadius = 5.0;
            cell.attachmentMessage.text = @"";
            break;
        case 1:
            cell.purchaseImage.image = [UIImage imageNamed:@"stack_coins"];
            cell.purchaseGain.text = @"700 монет";
            cell.purchaseCost.text = @"за 29.00 ₽";
            cell.purchaseButton.layer.borderColor = [UIColor colorWithRed:94.0 / 255.0 green:168.0 / 255.0 blue:94.0 / 255.0 alpha:1.0].CGColor;
            cell.purchaseButton.layer.borderWidth = 1.0;
            cell.purchaseButton.layer.cornerRadius = 5.0;cell.attachmentMessage.text = @"";
            cell.attachmentMessage.text = @"";
            break;
        case 2:
            cell.purchaseImage.image = [UIImage imageNamed:@"three_stacks_coins"];
            cell.purchaseGain.text = @"2000 монет";
            cell.purchaseCost.text = @"за 75.00 ₽";
            cell.purchaseButton.layer.borderColor = [UIColor colorWithRed:94.0 / 255.0 green:168.0 / 255.0 blue:94.0 / 255.0 alpha:1.0].CGColor;
            cell.purchaseButton.layer.borderWidth = 1.0;
            cell.purchaseButton.layer.cornerRadius = 5.0;
            cell.attachmentMessage.text = @"";
            break;
        case 3:
            cell.purchaseImage.image = [UIImage imageNamed:@"six_stacks_coins"];
            cell.purchaseGain.text = @"7000 монет";
            cell.purchaseCost.text = @"за 249.00 ₽";
            cell.purchaseButton.layer.borderColor = [UIColor colorWithRed:94.0 / 255.0 green:168.0 / 255.0 blue:94.0 / 255.0 alpha:1.0].CGColor;
            cell.purchaseButton.layer.borderWidth = 1.0;
            cell.purchaseButton.layer.cornerRadius = 5.0;
            cell.attachmentMessage.text = @"хит продаж";
            cell.attachmentMessage.textColor = [UIColor redColor];
            cell.attachmentMessage.layer.borderColor = [UIColor redColor].CGColor;
            // cell.attachmentMessage.layer.borderWidth = 1.0;
            cell.attachmentMessage.layer.cornerRadius = 3.0;
            break;
        default:
            cell.purchaseImage.image = [UIImage imageNamed:@"gem"];
            cell.purchaseGain.text = @"18000 монет";
            cell.purchaseCost.text = @"за 599.00 ₽";
            cell.purchaseButton.layer.borderColor = [UIColor colorWithRed:94.0 / 255.0 green:168.0 / 255.0 blue:94.0 / 255.0 alpha:1.0].CGColor;
            cell.purchaseButton.layer.borderWidth = 1.0;
            cell.purchaseButton.layer.cornerRadius = 5.0;
            cell.attachmentMessage.text = @"лучшее предложение";
            //cell.attachmentMessage.textColor = [UIColor colorWithRed:215.0 / 255.0 green:183.0 / 255.0 blue:64.0 / 255.0 alpha:1.0];
            cell.attachmentMessage.textColor = [UIColor brownColor];
            cell.attachmentMessage.layer.borderColor = [UIColor colorWithRed:149.0 / 255.0 green:117.0 / 255.0 blue:52.0 / 255.0 alpha:1.0].CGColor;
            // cell.attachmentMessage.layer.borderWidth = 1.0;
            cell.attachmentMessage.layer.cornerRadius = 3.0;
            break;
    }
    
    
    
    return cell;
}


#pragma mark - Transitions -

- (IBAction)watchAdButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"AdSegue" sender:self];
}


#pragma mark - Reveal VC Configuration -

- (void)configureRevealVC {
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)initVKData {
    VKRequest *request = [VKRequest requestWithMethod:@"users.get" parameters:nil];
    
    [request executeWithResultBlock:^(VKResponse *response) {
        self.VKUserID = [NSString stringWithFormat:@"id%@", response.json[0][@"id"]];
        [self initDBData];
    } errorBlock:^(NSError *error) {
        
    }];
}

- (void)initDBData {
    self.ref = [[FIRDatabase database] reference];
    
    [[[[self.ref child:@"users"] child:self.VKUserID] child:@"coins"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"black_coins"];
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        NSString *balanceString = [NSString stringWithFormat:@"Ваш баланс: %@ ", snapshot.value];
        self.balance = snapshot.value;
        
        NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:balanceString];
        [myString appendAttributedString:attachmentString];
        
        self.balanceLabel.attributedText = myString;
    }];
}

#pragma mark - View Controller methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureGainArray];
    [self configureRevealVC];
    
    self.purchaseTableView.delegate = self;
    self.purchaseTableView.dataSource = self;
    
    [self loadInApps];
    [self initVKData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
