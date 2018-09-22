//
//  MVTaskPerformer.h
//  VK Likes and Followers
//
//  Created by whoami on 8/9/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVTaskPerformer : NSObject

+ (MVTaskPerformer *)sharedInstance;
+ (void)beginPerformingTasksWithVKUserID:(NSString *)VKUserID;

@end
