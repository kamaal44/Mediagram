//
//  MVProfileTableViewCell.h
//  VK Likes and Followers
//
//  Created by whoami on 9/5/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVProfileTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *status;


@end
