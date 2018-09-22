//
//  MVFakePurchaseViewController.h
//  VK Likes and Followers
//
//  Created by whoami on 8/9/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface MVFakePurchaseViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver, UITableViewDelegate, UITableViewDataSource>

@end
