//
//  MVFakeInAppViewController.h
//  VK Likes and Followers
//
//  Created by whoami on 9/4/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface MVFakeInAppViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end
