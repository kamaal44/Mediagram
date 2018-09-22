//
//  MVExchangeTableViewCell.h
//  VK Likes and Followers
//
//  Created by whoami on 7/16/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVExchangeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *serviceImage;
@property (weak, nonatomic) IBOutlet UILabel *offer;
@property (weak, nonatomic) IBOutlet UIButton *exchangeButton;
@end
