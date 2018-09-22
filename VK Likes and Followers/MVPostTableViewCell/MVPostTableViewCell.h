//
//  MVPostTableViewCell.h
//  VK Likes and Followers
//
//  Created by whoami on 7/14/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVPostTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencyAmount;
@end
