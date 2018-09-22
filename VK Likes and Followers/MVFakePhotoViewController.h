//
//  MVFakePhotoViewController.h
//  VK Likes and Followers
//
//  Created by whoami on 9/3/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>

@interface MVFakePhotoViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SFSafariViewControllerDelegate>

@property (strong, nonatomic) NSString *VKUserID;

@end
