//
//  MVLoginViewController.h
//  VK Likes and Followers
//
//  Created by whoami on 5/14/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VKSdk.h>

@interface MVLoginViewController : UIViewController<VKSdkDelegate, VKSdkUIDelegate>

@property (nonatomic) BOOL afterSegue;

@end
