//
//  MVPresentPhotoViewController.h
//  VK Likes and Followers
//
//  Created by whoami on 7/16/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVOffer.h"

@interface MVPresentPhotoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeNumber;
@property (weak, nonatomic) IBOutlet UILabel *cheatStatus;
@property (strong, nonatomic) NSMutableArray<MVOffer *> *offers;
@property (strong, nonatomic) NSString *labelText;
@property (strong, nonatomic) NSString *pathToPhoto;
@property (strong, nonatomic) NSString *VKPhotoID;
@end
