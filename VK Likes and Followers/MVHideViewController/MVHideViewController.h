//
//  MVHideViewController.h
//  VK Likes and Followers
//
//  Created by whoami on 8/8/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>

@interface MVHideViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSString *VKUserID;

@end
