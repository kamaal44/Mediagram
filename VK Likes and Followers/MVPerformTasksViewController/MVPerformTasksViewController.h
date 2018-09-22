//
//  MVPerformTasksViewController.h
//  VK Likes and Followers
//
//  Created by whoami on 7/14/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVTask.h"
#import <VKSdk.h>

@interface MVPerformTasksViewController : UIViewController <VKSdkUIDelegate>

@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *gainLabel;
@property (strong, nonatomic) NSMutableArray<MVTask *> *tasks;
@property (strong, nonatomic) NSString *VKUserID;
@property (strong, nonatomic) NSMutableDictionary *reward;

@end
