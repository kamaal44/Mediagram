//
//  MVTaskPerformer.m
//  VK Likes and Followers
//
//  Created by whoami on 8/9/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVTaskPerformer.h"
#import "MVTask.h"

#import <Firebase.h>
#import <VKApi.h>

@interface MVTaskPerformer ()

@end

@implementation MVTaskPerformer

+ (MVTaskPerformer *)sharedInstance {
    static MVTaskPerformer *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)beginPerformingTasksWithVKUserID:(NSString *)VKUserID {
    // 1. Initialize reference
    FIRDatabaseReference *reference = [[FIRDatabase database] reference];
    
    // 2. Get limit for background tasks and process them
    [[reference child:@"background_tasks_limit"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSInteger limitForBackgroundTasks = [snapshot.value intValue];
        
        NSMutableArray<MVTask *> *tasks = [[NSMutableArray alloc] init];
        [MVTaskPerformer loadActiveTasks:tasks usingReference:reference forVKUserID:VKUserID withLimitForTasks:limitForBackgroundTasks];
    }];
    
}

+ (void)loadActiveTasks:(NSMutableArray<MVTask *> *)tasks usingReference:(FIRDatabaseReference *)reference forVKUserID:(NSString *)VKUserID withLimitForTasks:(NSInteger) limitForBackgroundTasks {
    dispatch_group_t dispatch_group = dispatch_group_create();
    
    dispatch_group_enter(dispatch_group);
    [[[reference child:@"active_tasks"] queryLimitedToFirst:limitForBackgroundTasks] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        for (FIRDataSnapshot *child in snapshot.children) {
            MVTask *task = [[MVTask alloc] init];
            
            if ([child.key isEqualToString:@"anchor"] || [child.value isEqualToString:@"repost"]) {
                continue;
            }
            
            task.fullID = child.key;
            task.type = child.value;
            
            task.userID = [child.key substringFromIndex:2];
            if (![task.type isEqualToString:@"follower"]) {
                NSRange range = [task.userID rangeOfString:@"_"];
                task.itemID = [task.userID substringFromIndex:range.location + 1];
                task.userID = [task.userID substringToIndex:range.location];
            }
            
            if ([task.userID isEqualToString:[VKUserID substringFromIndex:2]]) {
                continue;
            }
            
            [tasks addObject:task];
        }
        dispatch_group_leave(dispatch_group);
    }];
    
    dispatch_group_notify(dispatch_group, dispatch_get_main_queue(), ^{
        [MVTaskPerformer setupAdditionalInfoForActiveTasks:tasks usingReference:reference];
    });
}

+ (void)setupAdditionalInfoForActiveTasks:(NSMutableArray<MVTask *> *)tasks usingReference:(FIRDatabaseReference *)reference {
    dispatch_group_t dispatch_group = dispatch_group_create();
    
    for (MVTask *task in tasks) {
        NSString *taskDBSubtree;
        
        if ([task.type isEqualToString:@"follower"]) {
            taskDBSubtree = @"follower_tasks";
        } else if ([task.type isEqualToString:@"post_like"]) {
            taskDBSubtree = @"post_likes_tasks";
        } else if ([task.type isEqualToString:@"photo_like"]) {
            taskDBSubtree = @"photo_likes_tasks";
        }
        
        dispatch_group_enter(dispatch_group);
        [[[reference child:taskDBSubtree] child:task.fullID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.exists) {
                task.added = [snapshot childSnapshotForPath:@"added"].value;
                task.purchased = [snapshot childSnapshotForPath:@"purchased"].value;
            }
            dispatch_group_leave(dispatch_group);
        }];
    }
    
    dispatch_group_notify(dispatch_group, dispatch_get_main_queue(), ^{
        [MVTaskPerformer setupInformationAboutCompletionForTasks:tasks usingReference:reference];
    });
}

+ (void)setupInformationAboutCompletionForTasks:(NSMutableArray<MVTask *> *)tasks usingReference:(FIRDatabaseReference *)reference {
    dispatch_group_t dispatch_group = dispatch_group_create();
    
    for (MVTask *task in tasks) {
        if ([task.type isEqualToString:@"follower"]) {
            [MVTaskPerformer setupInformationAboutCompletionForFollowerTask:task usingDispatchGroup:dispatch_group];
        } else if ([task.type isEqualToString:@"post_like"]) {
            [MVTaskPerformer setupInformationAboutCompletionForPostLikeTask:task usingDispatchGroup:dispatch_group];
        } else if ([task.type isEqualToString:@"photo_like"]) {
            [MVTaskPerformer setupInformationAboutCompletionForPhotoLikeTask:task usingDispatchGroup:dispatch_group];
        }
    }
    
    dispatch_group_notify(dispatch_group, dispatch_get_main_queue(), ^{
        [MVTaskPerformer performTasks:tasks usingReference:reference];
    });
}

+ (void)setupInformationAboutCompletionForFollowerTask:(MVTask *)task usingDispatchGroup:(dispatch_group_t)dispatch_group {
    VKRequest *friendsRequest = [VKRequest requestWithMethod:@"friends.areFriends" parameters:@{VK_API_USER_IDS : task.userID}];
    
    dispatch_group_enter(dispatch_group);
    [friendsRequest executeWithResultBlock:^(VKResponse *response) {
        task.alreadyCompleted = ([response.json[0][@"friend_status"] intValue] == 1) || ([response.json[0][@"friend_status"] intValue] == 3);
        dispatch_group_leave(dispatch_group);
    } errorBlock:^(NSError *error) {
    
    }];
}

+ (void)setupInformationAboutCompletionForPostLikeTask:(MVTask *)task usingDispatchGroup:(dispatch_group_t)dispatch_group {
    VKRequest *wallRequest = [VKRequest requestWithMethod:@"wall.getById" parameters:@{@"posts" : [task.fullID substringFromIndex:2], VK_API_EXTENDED : @1}];
    
    dispatch_group_enter(dispatch_group);
    [wallRequest executeWithResultBlock:^(VKResponse *response) {
        task.alreadyCompleted = [response.json[@"items"][0][@"likes"][@"user_likes"] intValue] == 1;
        dispatch_group_leave(dispatch_group);
    } errorBlock:^(NSError *error) {
        
    }];
}

+ (void)setupInformationAboutCompletionForPhotoLikeTask:(MVTask *)task usingDispatchGroup:(dispatch_group_t)dispatch_group {
    VKRequest *photoRequest = [VKRequest requestWithMethod:@"photos.getById" parameters:@{@"photos" : [task.fullID substringFromIndex:2], VK_API_EXTENDED : @1}];
    
    dispatch_group_enter(dispatch_group);
    [photoRequest executeWithResultBlock:^(VKResponse *response) {
        task.alreadyCompleted = [response.json[0][@"likes"][@"user_likes"] intValue] == 1;
        dispatch_group_leave(dispatch_group);
    } errorBlock:^(NSError *error) {
        
    }];
}

+ (void)performTasks:(NSMutableArray<MVTask *> *)tasks usingReference:(FIRDatabaseReference *)reference {
    NSMutableDictionary *tasksStorageMapping = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"follower_tasks", @"follower",
                                                @"photo_likes_tasks", @"photo_like",
                                                @"post_likes_tasks", @"post_like",
                                                @"repost_tasks", @"repost", nil];
    
    for (MVTask *task in tasks) {
        if ([task alreadyCompleted]) {
            continue;
        }
        
        // 1. Send VK Request
        
        if ([task.type isEqualToString:@"follower"]) {
            [MVTaskPerformer sendVKFollowRequestForTask:task];
        } else if ([task.type isEqualToString:@"post_like"]) {
            [MVTaskPerformer sendVKPostLikeRequestForTask:task];
        } else if ([task.type isEqualToString:@"photo_like"]) {
            [MVTaskPerformer sendVKPhotoLikeRequestForTask:task];
        }
        
        // 2. Update customer's offer info with database
        
        [[[reference child:tasksStorageMapping[task.type]] child:task.fullID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSInteger oldValue = [(NSString *)[snapshot childSnapshotForPath:@"added"].value intValue];
            
            NSInteger purchased = [(NSString *)[snapshot childSnapshotForPath:@"purchased"].value intValue];
            
            NSString *newValue = [NSString stringWithFormat:@"%ld", oldValue + 1];
            [[[[reference child:tasksStorageMapping[task.type]] child:task.fullID] child:@"added"] setValue:newValue];
            
            if (oldValue + 1 == purchased) {
                [[[reference child:@"active_tasks"] child:task.fullID] removeValue];
            }
        }];
    }
}

+ (void)sendVKFollowRequestForTask:(MVTask *)task {
    VKRequest *request = [VKRequest requestWithMethod:@"friends.add" parameters:@{@"user_id" : task.userID,
                                                                                  @"follow" : @1
                                                                                  }];
    
    [request executeWithResultBlock:^(VKResponse *response) {
        
    } errorBlock:^(NSError *error) {
        
    }];
}

+ (void)sendVKPostLikeRequestForTask:(MVTask *)task {
    VKRequest *request = [VKRequest requestWithMethod:@"likes.add" parameters:@{@"type" : @"post",
                                                                                @"owner_id" : task.userID,
                                                                                @"item_id" : task.itemID
                                                                                }];
    
    [request executeWithResultBlock:^(VKResponse *response) {
        
    } errorBlock:^(NSError *error) {
        
    }];
}

+ (void)sendVKPhotoLikeRequestForTask:(MVTask *)task {
    VKRequest *request = [VKRequest requestWithMethod:@"likes.add" parameters:@{@"type" : @"photo", @"owner_id" : task.userID, @"item_id" : task.itemID}];
    
    [request executeWithResultBlock:^(VKResponse *response) {
        
    } errorBlock:^(NSError *error) {
        
    }];
}

@end
