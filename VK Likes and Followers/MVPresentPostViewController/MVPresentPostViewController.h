//
//  MVPresentPostViewController.h
//  VK Likes and Followers
//
//  Created by whoami on 7/16/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVOffer.h"

@interface MVPresentPostViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UILabel *postText;
@property (weak, nonatomic) IBOutlet UITableView *exchangeTableView;
@property (strong, nonatomic) NSMutableArray<MVOffer *> *offers;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cheatStatus;
@property (weak, nonatomic) IBOutlet UILabel *currencyAmount;
@property (weak, nonatomic) IBOutlet UIImageView *currencyImage;
@property (nonatomic) BOOL isLikeVC;
@property (strong, nonatomic) NSString *postLabelText;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *currenctAmountText;
@property (strong, nonatomic) NSString *VKPostID;
@end
