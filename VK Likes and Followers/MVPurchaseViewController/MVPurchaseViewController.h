//
//  MVPurchaseViewController.h
//  VK Likes and Followers
//
//  Created by whoami on 7/13/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface MVPurchaseViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@end
