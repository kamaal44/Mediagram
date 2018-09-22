//
//  MVTask.h
//  VK Likes and Followers
//
//  Created by whoami on 8/2/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MVTask : NSObject

@property (strong, nonatomic) NSString *photoURL;
@property (strong, nonatomic) NSString *type;

@property (strong, nonatomic) NSString *fullID;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *itemID;

@property (strong, nonatomic) NSString *added;
@property (strong, nonatomic) NSString *purchased;

@property (nonatomic) BOOL alreadyCompleted;

@end
