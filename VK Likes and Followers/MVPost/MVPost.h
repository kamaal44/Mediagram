//
//  MVPost.h
//  VK Likes and Followers
//
//  Created by whoami on 7/14/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MVPost : NSObject
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *post;
@property (strong, nonatomic) NSString *likeNumber;
@property (strong, nonatomic) NSString *repostNumber;
@end
