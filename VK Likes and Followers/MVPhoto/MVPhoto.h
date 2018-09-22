//
//  MVPhoto.h
//  VK Likes and Followers
//
//  Created by whoami on 7/15/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MVPhoto : NSObject

@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSString *likeNumber;
@property (strong, nonatomic) NSString *sourceURL;

@end
