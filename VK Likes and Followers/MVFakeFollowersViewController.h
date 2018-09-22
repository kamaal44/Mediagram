//
//  MVFakeFollowersViewController.h
//  VK Likes and Followers
//
//  Created by whoami on 9/4/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>

@interface MVFakeFollowersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate>

@property (strong, nonatomic) NSString *VKUserID;

@end
