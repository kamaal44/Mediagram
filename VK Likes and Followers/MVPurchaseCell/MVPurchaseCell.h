//
//  MVPurchaseCell.h
//  VK Likes and Followers
//
//  Created by whoami on 8/5/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVPurchaseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *purchaseImage;
@property (weak, nonatomic) IBOutlet UILabel *purchaseGain;
@property (weak, nonatomic) IBOutlet UILabel *purchaseCost;
@property (weak, nonatomic) IBOutlet UILabel *attachmentMessage;
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;

@end
