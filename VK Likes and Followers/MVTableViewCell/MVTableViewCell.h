//
//  MVTableViewCell.h
//  VK Likes and Followers
//
//  Created by whoami on 7/12/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (strong, nonatomic) NSString *blackImageName;
@property (strong, nonatomic) NSString *whiteImageName;

@end
