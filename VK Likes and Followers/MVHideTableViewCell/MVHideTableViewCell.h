//
//  MVHideTableViewCell.h
//  VK Likes and Followers
//
//  Created by whoami on 8/8/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVHideTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) NSString *VKUserID;

@end
