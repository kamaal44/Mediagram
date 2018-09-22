//
//  MVPhotoCollectionViewCell.h
//  VK Likes and Followers
//
//  Created by whoami on 7/15/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVPhotoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *likeNumber;
@property (strong, nonatomic) NSString *sourceURL;

@end
